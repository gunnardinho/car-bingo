/// A pending progress-sync job for one board (§4 outbox). Carries just the key
/// plus retry bookkeeping; the payload is read live from Drift at flush time so
/// the latest marks are always sent.
class OutboxEntry {
  final String boardId;
  final int attempts;
  final String? lastError;

  const OutboxEntry({
    required this.boardId,
    this.attempts = 0,
    this.lastError,
  });
}
