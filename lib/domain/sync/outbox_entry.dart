/// A pending progress-sync job for one board (§4 outbox). Carries the key, a
/// monotonic [revision] used for safe compare-and-ack, and retry bookkeeping.
/// The payload is read live from Drift at flush time so the latest marks are
/// always sent.
class OutboxEntry {
  final String boardId;
  final int revision;
  final int attempts;
  final String? lastError;

  const OutboxEntry({
    required this.boardId,
    required this.revision,
    this.attempts = 0,
    this.lastError,
  });
}
