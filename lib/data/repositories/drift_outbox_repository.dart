import 'package:drift/drift.dart';

import '../../domain/repositories/outbox_repository.dart';
import '../../domain/sync/outbox_entry.dart';
import '../local/drift/database.dart';

/// Drift-backed [OutboxRepository]. One row per board (coalescing); when invoked
/// inside a game-repository transaction the enqueue is atomic with the mark
/// write, so a crash can't leave a persisted mark with no sync intent.
class DriftOutboxRepository implements OutboxRepository {
  final AppDatabase db;

  DriftOutboxRepository(this.db);

  @override
  Future<void> enqueue(String boardId) {
    final now = DateTime.now();
    return db.into(db.syncOutbox).insertOnConflictUpdate(
          SyncOutboxCompanion.insert(
            boardId: boardId,
            createdAt: now,
            updatedAt: now,
            attempts: const Value(0), // a fresh change supersedes prior failures
            lastError: const Value(null),
          ),
        );
  }

  @override
  Future<List<OutboxEntry>> pending() async {
    final rows = await (db.select(db.syncOutbox)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return [
      for (final r in rows)
        OutboxEntry(boardId: r.boardId, attempts: r.attempts, lastError: r.lastError),
    ];
  }

  @override
  Future<void> markSynced(String boardId) =>
      (db.delete(db.syncOutbox)..where((t) => t.boardId.equals(boardId))).go();

  @override
  Future<void> markFailed(String boardId, String error) async {
    final row = await (db.select(db.syncOutbox)
          ..where((t) => t.boardId.equals(boardId)))
        .getSingleOrNull();
    if (row == null) return;
    await (db.update(db.syncOutbox)..where((t) => t.boardId.equals(boardId)))
        .write(SyncOutboxCompanion(
      attempts: Value(row.attempts + 1),
      lastError: Value(error),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> clear() => db.delete(db.syncOutbox).go();
}
