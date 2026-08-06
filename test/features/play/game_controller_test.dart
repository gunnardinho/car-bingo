import 'dart:math';

import 'package:carbingo/app/di/providers.dart';
import 'package:carbingo/domain/game/persisted_game.dart';
import 'package:carbingo/domain/repositories/game_repository.dart';
import 'package:carbingo/features/play/game_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixture_catalog.dart';
import '../../support/in_memory_game_repository.dart';

/// Builds a container wired to the fixture catalog and a shared in-memory game
/// repository, with the game controller seeded from [initialActiveGame] to
/// simulate a relaunch.
Future<ProviderContainer> _container(
  GameRepository repo, {
  bool restore = false,
}) async {
  final initial = restore ? await repo.loadActiveGame() : null;
  final container = ProviderContainer(
    overrides: [
      catalogProvider.overrideWith((ref) async => buildFixtureCatalog()),
      gameRepositoryProvider.overrideWithValue(repo),
      gameControllerProvider.overrideWith(
        () => GameController(
          random: Random(1),
          initial: initial == null ? null : GameState.fromPersisted(initial),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container.read(catalogProvider.future); // so requireValue is safe
  return container;
}

void main() {
  test('newGame persists the active board (spec + layout, no marks)', () async {
    final repo = InMemoryGameRepository();
    final container = await _container(repo);
    container.read(gameControllerProvider.notifier).newGame(5);

    final state = container.read(gameControllerProvider)!;
    final saved = await repo.loadActiveGame();
    expect(saved, isNotNull);
    expect(saved!.boardId, state.boardId);
    expect(saved.spec.size, 5);
    expect(saved.spec.seed, state.spec.seed);
    expect(saved.layout.cellItemIds, state.layout.cellItemIds);
    expect(saved.marks, isEmpty);
  });

  // Scope: this asserts un-mark removes a cell from the ACTIVE marked set. The
  // stronger §4 invariant (an un-mark is persisted as marked=false, never a row
  // delete) is enforced against real SQLite in drift_game_repository_test.dart —
  // it can't be observed through the repository interface here.
  test('toggle marks a cell; un-toggle removes it from the active marked set',
      () async {
    final repo = InMemoryGameRepository();
    final container = await _container(repo);
    final ctrl = container.read(gameControllerProvider.notifier)..newGame(5);
    final boardId = container.read(gameControllerProvider)!.boardId;

    ctrl.toggle(0);
    ctrl.toggle(1);
    expect((await repo.loadActiveGame())!.marks, {0, 1});

    ctrl.toggle(0); // un-mark
    final saved = await repo.loadActiveGame();
    expect(saved!.marks, {1}, reason: 'cell 0 no longer in the active marked set');
    expect(saved.boardId, boardId);
  });

  test('the free centre is never marked or persisted', () async {
    final repo = InMemoryGameRepository();
    final container = await _container(repo);
    final ctrl = container.read(gameControllerProvider.notifier)..newGame(5);
    final free = container.read(gameControllerProvider)!.spec.freeIndex!;

    ctrl.toggle(free);
    expect(container.read(gameControllerProvider)!.marks, isEmpty);
    expect((await repo.loadActiveGame())!.marks, isEmpty);
  });

  test('a restored game rehydrates board + marks on relaunch', () async {
    final repo = InMemoryGameRepository();
    final first = await _container(repo);
    final ctrl = first.read(gameControllerProvider.notifier)..newGame(4);
    final original = first.read(gameControllerProvider)!;
    ctrl
      ..toggle(2)
      ..toggle(5)
      ..toggle(9);

    // Simulate a relaunch: fresh container, controller seeded from Drift.
    final second = await _container(repo, restore: true);
    final restored = second.read(gameControllerProvider);
    expect(restored, isNotNull);
    expect(restored!.boardId, original.boardId);
    expect(restored.spec.size, 4);
    expect(restored.layout.cellItemIds, original.layout.cellItemIds);
    expect(restored.marks, {2, 5, 9});
  });

  test('starting a new game replaces the previous active board', () async {
    final repo = InMemoryGameRepository();
    final container = await _container(repo);
    final ctrl = container.read(gameControllerProvider.notifier)..newGame(3);
    final firstId = container.read(gameControllerProvider)!.boardId;
    ctrl.toggle(0);

    ctrl.newGame(5);
    final secondId = container.read(gameControllerProvider)!.boardId;
    expect(secondId, isNot(firstId));

    final active = await repo.loadActiveGame();
    expect(active!.boardId, secondId);
    expect(active.spec.size, 5);
    expect(active.marks, isEmpty, reason: 'previous board and its marks cleared');
  });

  test('a failed board switch reconciles to the persisted board (no silent loss)',
      () async {
    final repo = _FailingStartRepo(InMemoryGameRepository());
    final container = await _container(repo);
    final ctrl = container.read(gameControllerProvider.notifier)..newGame(3);
    final boardA = container.read(gameControllerProvider)!;
    ctrl
      ..toggle(0)
      ..toggle(1);
    expect((await repo.loadActiveGame())!.boardId, boardA.boardId);

    // The next board switch fails to persist (e.g. disk-full). The optimistic
    // board must NOT survive on screen — state reconciles to what Drift holds.
    repo.failNextStart = true;
    ctrl.newGame(5);
    await pumpEventQueue(); // deterministically drain the unawaited persist + reconcile

    final restored = container.read(gameControllerProvider)!;
    expect(restored.boardId, boardA.boardId, reason: 'reconciled to the persisted board');
    expect(restored.spec.size, 3);
    expect(restored.marks, {0, 1}, reason: 'board A progress is intact');
    expect((await repo.loadActiveGame())!.boardId, boardA.boardId);
  });
}

/// Wraps the in-memory repo but can be armed to fail the next [startGame] once,
/// simulating a local-write failure (disk-full / SQLITE_BUSY) during a board
/// switch — the scenario the reconcile path must recover from.
class _FailingStartRepo implements GameRepository {
  final InMemoryGameRepository _inner;
  bool failNextStart = false;

  _FailingStartRepo(this._inner);

  @override
  Future<PersistedGame?> loadActiveGame() => _inner.loadActiveGame();

  @override
  Future<void> setMark({
    required String boardId,
    required int cellIndex,
    required bool marked,
  }) =>
      _inner.setMark(boardId: boardId, cellIndex: cellIndex, marked: marked);

  @override
  Future<void> startGame(PersistedGame game) async {
    if (failNextStart) {
      failNextStart = false;
      throw Exception('simulated disk-full');
    }
    return _inner.startGame(game);
  }
}
