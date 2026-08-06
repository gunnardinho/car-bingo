import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/providers.dart';
import '../../domain/board/board_layout.dart';
import '../../domain/board/board_spec.dart';
import '../../domain/board/generator/board_generator.dart';
import '../../domain/board/win_rules.dart';
import '../../domain/game/persisted_game.dart';
import '../../domain/repositories/game_repository.dart';

/// One active solo game: the immutable [BoardSpec] + frozen [BoardLayout] plus
/// the mutable set of marked cell indices, keyed by a durable [boardId].
/// Progress is persisted to Drift as it changes and restored on launch (§4).
class GameState {
  final String boardId;
  final BoardSpec spec;
  final BoardLayout layout;
  final Set<int> marks; // user-marked cell indices (excludes the free centre)

  const GameState({
    required this.boardId,
    required this.spec,
    required this.layout,
    required this.marks,
  });

  factory GameState.fromPersisted(PersistedGame g) => GameState(
        boardId: g.boardId,
        spec: g.spec,
        layout: g.layout,
        marks: g.marks,
      );

  PersistedGame toPersisted() =>
      PersistedGame(boardId: boardId, spec: spec, layout: layout, marks: marks);

  bool get won => hasWon(spec, marks);

  int get totalCells => spec.cellCount;

  /// Marked count including the auto-marked free centre.
  int get markedCount => marks.length + (spec.freeIndex != null ? 1 : 0);

  GameState copyWith({Set<int>? marks}) => GameState(
        boardId: boardId,
        spec: spec,
        layout: layout,
        marks: marks ?? this.marks,
      );
}

class GameController extends Notifier<GameState?> {
  final Random _random;
  final GameState? _initial;

  /// [initial] rehydrates the active game restored from Drift at launch; tests
  /// can inject a deterministic [random].
  GameController({Random? random, GameState? initial})
      : _random = random ?? Random(),
        // Named params can't be private, so an initializing formal isn't possible.
        // ignore: prefer_initializing_formals
        _initial = initial;

  GameRepository get _repo => ref.read(gameRepositoryProvider);

  @override
  GameState? build() => _initial;

  /// Start a new solo board of [size] (3/4/5) from a fresh random seed. The
  /// seed is the only nondeterministic input; generation from it is pure. The
  /// board becomes the single active game and is persisted immediately.
  void newGame(int size, {List<WinMode> winModes = const [WinMode.fullBoard]}) {
    final catalog = ref.read(catalogProvider).requireValue;
    final spec = BoardSpec(
      seed: _randomSeed(),
      size: size,
      catalogVersion: catalog.catalogVersion,
      algoVersion: catalog.algoVersion,
      configHash: catalog.configHash,
      winModes: winModes,
    );
    final layout = generateBoard(spec, catalog);
    final game = GameState(
      boardId: _randomBoardId(),
      spec: spec,
      layout: layout,
      marks: <int>{},
    );
    // Optimistic: show the new board immediately, then persist the switch. But
    // switching boards is not an infallible best-effort write like a single
    // toggle — if the durable write fails, keeping an unpersisted board on
    // screen would silently lose the whole session on relaunch (§4). So on
    // failure we reconcile in-memory state to whatever Drift actually holds.
    state = game;
    unawaited(_persistStart(game));
  }

  Future<void> _persistStart(GameState game) async {
    try {
      await _repo.startGame(game.toPersisted());
    } catch (e) {
      debugPrint('startGame persistence failed: $e');
      await _reconcileFromStorage();
    }
  }

  /// Reload in-memory state from the durable store so the UI can never diverge
  /// from what actually persisted (the fix for the swallowed-write data-loss
  /// class in §4). Best-effort: a failure here leaves the optimistic state.
  Future<void> _reconcileFromStorage() async {
    try {
      final active = await _repo.loadActiveGame();
      state = active == null ? null : GameState.fromPersisted(active);
    } catch (e) {
      debugPrint('reconcile from storage failed: $e');
    }
  }

  void toggle(int index) {
    final s = state;
    if (s == null || index == s.spec.freeIndex) return;
    final marks = Set<int>.of(s.marks);
    final nowMarked = !marks.remove(index);
    if (nowMarked) marks.add(index);
    state = s.copyWith(marks: marks);
    _persist(() =>
        _repo.setMark(boardId: s.boardId, cellIndex: index, marked: nowMarked));
  }

  /// Fire-and-forget a local write. Drift serializes statements in call order,
  /// so per-cell writes converge to the latest value; a failure is logged
  /// rather than surfaced (a local SQLite write should not fail in practice).
  void _persist(Future<void> Function() op) {
    op().catchError((Object e, StackTrace st) {
      debugPrint('game persistence failed: $e');
    });
  }

  String _randomSeed() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no ambiguous 0/O/1/I
    final code = List.generate(4, (_) => chars[_random.nextInt(chars.length)]).join();
    return 'ROADTRIP-$code';
  }

  String _randomBoardId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(20, (_) => chars[_random.nextInt(chars.length)]).join();
  }
}

final gameControllerProvider =
    NotifierProvider<GameController, GameState?>(GameController.new);

/// The cell whose detail is shown in the master–detail pane / sheet.
class SelectedCell extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? index) => state = index;
}

final selectedCellProvider = NotifierProvider<SelectedCell, int?>(SelectedCell.new);
