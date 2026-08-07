import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/game/persisted_game.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/outbox_repository.dart';
import '../local/drift/database.dart';
import '../mappers/board_mappers.dart';

/// [GameRepository] backed by Drift/SQLite — the local source of truth for the
/// active board and its progress (§4). Single-active-board for the MVP: starting
/// a game replaces any previous one (a local history is a later increment), so
/// the game tables never grow beyond one board.
///
/// Progress writes also record sync intent in the [OutboxRepository] within the
/// same transaction, so a persisted mark can never exist without a pending sync.
class DriftGameRepository implements GameRepository {
  static const _activeBoardKey = 'active_board_id';

  final AppDatabase db;
  final OutboxRepository outbox;

  DriftGameRepository(this.db, {required this.outbox});

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
      spec: boardSpecFromRow(spec),
      layout: boardLayoutFromRow(layout),
      marks: {for (final m in markRows) m.cellIndex},
    );
  }

  @override
  Future<void> startGame(PersistedGame game) {
    return db.transaction(() async {
      // Single active board: clear the previous one (and its pending sync) so
      // storage stays bounded and no orphaned rows survive. Revisit when a
      // completed-board history ships.
      await db.delete(db.playerMarks).go();
      await db.delete(db.boardLayouts).go();
      await db.delete(db.boardSpecs).go();
      await outbox.clear();

      await db.into(db.boardSpecs).insert(_specCompanion(game));
      await db.into(db.boardLayouts).insert(_layoutCompanion(game));

      // Seed marks that arrive with the game (fresh games have none).
      for (final index in game.marks) {
        await _upsertMark(game.boardId, index, true);
      }
      if (game.marks.isNotEmpty) await outbox.enqueue(game.boardId);

      await _setMeta(_activeBoardKey, game.boardId);
    });
  }

  @override
  Future<void> setMark({
    required String boardId,
    required int cellIndex,
    required bool marked,
  }) {
    // Persist the mark and record sync intent atomically — a mark can never be
    // durable without a queued sync, and vice versa.
    return db.transaction(() async {
      await _upsertMark(boardId, cellIndex, marked);
      await outbox.enqueue(boardId);
    });
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

  // --- mapping (row <- domain; row -> domain lives in board_mappers.dart) ---

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
      winModes: encodeWinModes(s.winModes),
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
}
