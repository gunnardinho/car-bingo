import '../sync/outbox_entry.dart';

/// The offline progress-sync outbox (§4): local, durable intent to push a
/// board's progress to Firestore once a real UID exists. Writes go here (via the
/// game repository, atomically with the mark) so a rejected/queued sync is
/// detectable and re-drivable rather than fire-and-forget.
abstract interface class OutboxRepository {
  /// Record (or refresh) that [boardId] needs syncing. Coalescing: one row per
  /// board; a new change resets the retry counters.
  Future<void> enqueue(String boardId);

  /// All boards awaiting a sync, oldest first.
  Future<List<OutboxEntry>> pending();

  /// Acknowledge a successful push of [revision]. No-op if the board was
  /// re-enqueued since (its revision moved on), so a mark made mid-push is never
  /// acked away.
  Future<void> markSynced(String boardId, int revision);

  /// Record a failed push of [revision] (bumps attempts, stores the error).
  /// No-op if the board was re-enqueued since — the newer job supersedes it.
  Future<void> markFailed(String boardId, int revision, String error);

  /// Drop all pending jobs (e.g. when the single active board is replaced).
  Future<void> clear();
}
