import 'package:drift/drift.dart';

import '../../domain/repositories/outbox_repository.dart';
import '../../domain/sync/outbox_entry.dart';
import '../local/drift/database.dart';

/// Drift-backed [OutboxRepository]. One row per board (coalescing); when invoked
/// inside a game-repository transaction the enqueue is atomic with the mark
/// write, so a crash can't leave a persisted mark with no sync intent.
///
/// Each enqueue bumps a monotonic [revision]; ack (markSynced/markFailed) is
/// conditional on that revision, so a re-enqueue during an in-flight push can
/// never be silently acked away (the flusher only clears the exact revision it
/// pushed).
class DriftOutboxRepository implements OutboxRepository {
  final AppDatabase db;

  DriftOutboxRepository(this.db);

  @override
  Future<void> enqueue(String boardId) {
    // Read-modify-write in a transaction so revision increments atomically and
    // createdAt is preserved across coalesced changes (keeps pending() FIFO).
    return db.transaction(() async {
      final existing = await (db.select(db.syncOutbox)
            ..where((t) => t.boardId.equals(boardId)))
          .getSingleOrNull();
      final now = DateTime.now();
      await db.into(db.syncOutbox).insertOnConflictUpdate(
            SyncOutboxCompanion.insert(
              boardId: boardId,
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
              revision: Value((existing?.revision ?? 0) + 1),
              attempts: const Value(0), // a fresh change supersedes prior failures
              lastError: const Value(null),
            ),
          );
    });
  }

  @override
  Future<List<OutboxEntry>> pending() async {
    final rows = await (db.select(db.syncOutbox)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return [
      for (final r in rows)
        OutboxEntry(
          boardId: r.boardId,
          revision: r.revision,
          attempts: r.attempts,
          lastError: r.lastError,
        ),
    ];
  }

  @override
  Future<void> markSynced(String boardId, int revision) => (db.delete(db.syncOutbox)
        ..where((t) => t.boardId.equals(boardId) & t.revision.equals(revision)))
      .go();

  @override
  Future<void> markFailed(String boardId, int revision, String error) {
    return db.transaction(() async {
      final row = await (db.select(db.syncOutbox)
            ..where((t) => t.boardId.equals(boardId) & t.revision.equals(revision)))
          .getSingleOrNull();
      // Gone or superseded by a newer enqueue → leave the newer job untouched.
      if (row == null) return;
      await (db.update(db.syncOutbox)
            ..where((t) => t.boardId.equals(boardId) & t.revision.equals(revision)))
          .write(SyncOutboxCompanion(
        attempts: Value(row.attempts + 1),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ));
    });
  }

  @override
  Future<void> clear() => db.delete(db.syncOutbox).go();
}
