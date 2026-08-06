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

  /// Acknowledge a successful push — removes the board's pending job.
  Future<void> markSynced(String boardId);

  /// Record a failed push so it retries later (bumps attempts, stores the error).
  Future<void> markFailed(String boardId, String error);

  /// Drop all pending jobs (e.g. when the single active board is replaced).
  Future<void> clear();
}
