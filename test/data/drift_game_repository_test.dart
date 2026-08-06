import 'package:carbingo/data/local/drift/database.dart';
import 'package:carbingo/data/repositories/drift_game_repository.dart';
import 'package:carbingo/domain/board/board_layout.dart';
import 'package:carbingo/domain/board/board_spec.dart';
import 'package:carbingo/domain/game/persisted_game.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

PersistedGame _game({
  String boardId = 'b1',
  int size = 5,
  Set<int> marks = const {},
}) {
  final spec = BoardSpec(
    seed: 'ROADTRIP-TEST',
    size: size,
    catalogVersion: '2026.08.0',
    algoVersion: 1,
    configHash: 'cfg-1',
    winModes: const [WinMode.fullBoard, WinMode.lines],
  );
  final ids = List<String?>.generate(size * size, (i) => 'item_$i');
  if (spec.freeIndex != null) ids[spec.freeIndex!] = null;
  final layout =
      BoardLayout(size: size, cellItemIds: ids, freeIndex: spec.freeIndex);
  return PersistedGame(boardId: boardId, spec: spec, layout: layout, marks: marks);
}

void main() {
  late AppDatabase db;
  late DriftGameRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftGameRepository(db);
  });
  tearDown(() => db.close());

  test('no active game on a fresh database', () async {
    expect(await repo.loadActiveGame(), isNull);
  });

  test('startGame round-trips spec, layout, win modes, and seed marks', () async {
    final g = _game(marks: {1, 2});
    await repo.startGame(g);

    final loaded = await repo.loadActiveGame();
    expect(loaded, isNotNull);
    expect(loaded!.boardId, g.boardId);
    expect(loaded.spec.seed, g.spec.seed);
    expect(loaded.spec.size, 5);
    expect(loaded.spec.catalogVersion, '2026.08.0');
    expect(loaded.spec.winModes, [WinMode.fullBoard, WinMode.lines]);
    expect(loaded.spec.freeSpace, isTrue);
    expect(loaded.layout.cellItemIds, g.layout.cellItemIds);
    expect(loaded.layout.freeIndex, g.spec.freeIndex);
    expect(loaded.marks, {1, 2});
  });

  test('setMark upserts; un-mark is stored as false, never deleted', () async {
    final g = _game();
    await repo.startGame(g);

    await repo.setMark(boardId: g.boardId, cellIndex: 3, marked: true);
    expect((await repo.loadActiveGame())!.marks, {3});

    await repo.setMark(boardId: g.boardId, cellIndex: 3, marked: false);
    expect((await repo.loadActiveGame())!.marks, isEmpty);

    final rows = (await (db.select(db.playerMarks)
              ..where((t) => t.boardId.equals(g.boardId)))
            .get())
        .where((r) => r.cellIndex == 3)
        .toList();
    expect(rows, hasLength(1), reason: 'row persists');
    expect(rows.single.marked, isFalse, reason: 'value flipped, not removed');
  });

  test('startGame replaces the previous board with no orphaned rows', () async {
    await repo.startGame(_game(boardId: 'old', size: 3, marks: {0}));
    await repo.setMark(boardId: 'old', cellIndex: 1, marked: true);

    await repo.startGame(_game(boardId: 'new', size: 5));

    final loaded = await repo.loadActiveGame();
    expect(loaded!.boardId, 'new');
    expect(loaded.spec.size, 5);
    expect(loaded.marks, isEmpty);

    expect((await db.select(db.boardSpecs).get()).map((s) => s.boardId), ['new']);
    expect((await db.select(db.boardLayouts).get()).map((s) => s.boardId), ['new']);
    expect(
      (await db.select(db.playerMarks).get()).every((m) => m.boardId == 'new'),
      isTrue,
    );
  });

  test('even-sized board round-trips with a null free index (no free centre)',
      () async {
    // 4x4 has no free centre: cellItemIds has no null element, so freeIndex is
    // reconstructed as null from JSON (the `indexOf(null) == -1` branch).
    final g = _game(size: 4, marks: {0, 15});
    await repo.startGame(g);

    final loaded = await repo.loadActiveGame();
    expect(loaded!.spec.size, 4);
    expect(loaded.spec.freeIndex, isNull);
    expect(loaded.layout.freeIndex, isNull);
    expect(loaded.layout.cellItemIds, hasLength(16));
    expect(loaded.layout.cellItemIds.whereType<Null>(), isEmpty);
    expect(loaded.marks, {0, 15});
  });

  test('a dangling active pointer (missing rows) yields no game', () async {
    await db
        .into(db.appMeta)
        .insert(AppMetaCompanion.insert(key: 'active_board_id', value: 'ghost'));
    expect(await repo.loadActiveGame(), isNull);
  });

  test('win-mode decoding tolerates unknown/whitespace entries (no throw)',
      () async {
    final g = _game();
    await repo.startGame(g);

    // Simulate a spec written by a future/renamed schema: unknown and blank
    // entries must be ignored, not throw and block startup.
    await _rewriteWinModes(db, g, 'fullBoard,  , bogusMode , lines');
    expect((await repo.loadActiveGame())!.spec.winModes,
        [WinMode.fullBoard, WinMode.lines]);

    // Nothing valid -> fall back to the default win mode, still no throw.
    await _rewriteWinModes(db, g, 'nonsense');
    expect((await repo.loadActiveGame())!.spec.winModes, [WinMode.fullBoard]);
  });
}

/// Upserts the persisted spec row for [g] with a raw [winModes] CSV, to exercise
/// tolerant decoding of values the app itself would never write.
Future<void> _rewriteWinModes(
    AppDatabase db, PersistedGame g, String winModes) {
  return db.into(db.boardSpecs).insertOnConflictUpdate(
        BoardSpecsCompanion.insert(
          boardId: g.boardId,
          seed: g.spec.seed,
          size: g.spec.size,
          freeSpace: g.spec.freeSpace,
          catalogVersion: g.spec.catalogVersion,
          algoVersion: g.spec.algoVersion,
          configHash: g.spec.configHash,
          winModes: winModes,
          mode: g.spec.mode,
          createdAt: DateTime.now(),
        ),
      );
}
