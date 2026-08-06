import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/board/board_layout.dart';
import '../../domain/board/board_spec.dart';
import '../../domain/game/persisted_game.dart';
import '../../domain/repositories/game_repository.dart';
import '../local/drift/database.dart';

/// [GameRepository] backed by Drift/SQLite — the local source of truth for the
/// active board and its progress (§4). Single-active-board for the MVP: starting
/// a game replaces any previous one (a local history is a later increment), so
/// the game tables never grow beyond one board.
class DriftGameRepository implements GameRepository {
  static const _activeBoardKey = 'active_board_id';

  final AppDatabase db;

  DriftGameRepository(this.db);

  @override
  Future<PersistedGame?> loadActiveGame() async {
    final boardId = await _getMeta(_activeBoardKey);
    if (boardId == null) return null;

    final spec = await (db.select(db.boardSpecs)
          ..where((t) => t.boardId.equals(boardId)))
        .getSingleOrNull();
    final layout = await (db.select(db.boardLayouts)
          ..where((t) => t.boardId.equals(boardId)))
        .getSingleOrNull();
    // A dangling pointer (spec or layout missing) means no restorable game.
    if (spec == null || layout == null) return null;

    final markRows = await (db.select(db.playerMarks)
          ..where((t) => t.boardId.equals(boardId) & t.marked.equals(true)))
        .get();

    return PersistedGame(
      boardId: boardId,
      spec: _toSpec(spec),
      layout: _toLayout(layout),
      marks: {for (final m in markRows) m.cellIndex},
    );
  }

  @override
  Future<void> startGame(PersistedGame game) {
    return db.transaction(() async {
      // Single active board: clear the previous one so storage stays bounded and
      // no orphaned rows survive. Revisit when a completed-board history ships.
      await db.delete(db.playerMarks).go();
      await db.delete(db.boardLayouts).go();
      await db.delete(db.boardSpecs).go();

      await db.into(db.boardSpecs).insert(_specCompanion(game));
      await db.into(db.boardLayouts).insert(_layoutCompanion(game));

      // Seed marks that arrive with the game (fresh games have none).
      for (final index in game.marks) {
        await _upsertMark(game.boardId, index, true);
      }

      await _setMeta(_activeBoardKey, game.boardId);
    });
  }

  @override
  Future<void> setMark({
    required String boardId,
    required int cellIndex,
    required bool marked,
  }) {
    return _upsertMark(boardId, cellIndex, marked);
  }

  Future<void> _upsertMark(String boardId, int cellIndex, bool marked) {
    return db.into(db.playerMarks).insertOnConflictUpdate(
          PlayerMarksCompanion.insert(
            boardId: boardId,
            cellIndex: cellIndex,
            marked: marked,
            updatedAt: DateTime.now(),
          ),
        );
  }

  // --- meta helpers ---

  Future<String?> _getMeta(String key) async {
    final row = await (db.select(db.appMeta)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _setMeta(String key, String value) {
    return db.into(db.appMeta).insertOnConflictUpdate(
          AppMetaCompanion.insert(key: key, value: value),
        );
  }

  // --- mapping ---

  BoardSpecsCompanion _specCompanion(PersistedGame game) {
    final s = game.spec;
    return BoardSpecsCompanion.insert(
      boardId: game.boardId,
      seed: s.seed,
      size: s.size,
      freeSpace: s.freeSpace,
      catalogVersion: s.catalogVersion,
      algoVersion: s.algoVersion,
      configHash: s.configHash,
      winModes: _encodeWinModes(s.winModes),
      mode: s.mode,
      createdAt: DateTime.now(),
    );
  }

  BoardLayoutsCompanion _layoutCompanion(PersistedGame game) {
    return BoardLayoutsCompanion.insert(
      boardId: game.boardId,
      size: game.layout.size,
      cellItemIds: jsonEncode(game.layout.cellItemIds),
      generatedAt: DateTime.now(),
    );
  }

  BoardSpec _toSpec(StoredBoardSpec r) => BoardSpec(
        seed: r.seed,
        size: r.size,
        freeSpace: r.freeSpace,
        catalogVersion: r.catalogVersion,
        algoVersion: r.algoVersion,
        configHash: r.configHash,
        winModes: _decodeWinModes(r.winModes),
        mode: r.mode,
      );

  BoardLayout _toLayout(StoredBoardLayout r) {
    final ids = [
      for (final e in jsonDecode(r.cellItemIds) as List) e as String?,
    ];
    final free = ids.indexOf(null); // -1 on even boards (no free centre)
    return BoardLayout(
      size: r.size,
      cellItemIds: ids,
      freeIndex: free == -1 ? null : free,
    );
  }

  String _encodeWinModes(List<WinMode> modes) =>
      modes.map((m) => m.name).join(',');

  List<WinMode> _decodeWinModes(String csv) {
    final modes = [
      for (final name in csv.split(',').where((s) => s.isNotEmpty))
        WinMode.values.byName(name),
    ];
    return modes.isEmpty ? const [WinMode.fullBoard] : modes;
  }
}
