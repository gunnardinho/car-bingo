import '../auth/auth_service.dart';
import '../board/win_rules.dart';
import '../repositories/outbox_repository.dart';
import 'progress_gateway.dart';
import 'progress_reader.dart';

/// Drains the offline outbox to the [ProgressGateway] once a real UID exists
/// (§4). Everything here is best-effort and never gates play: with no UID
/// (offline / Firebase not configured) it simply leaves jobs queued in Drift, so
/// no progress is ever lost — it just syncs later. A failed push is recorded for
/// retry, not dropped.
class SyncCoordinator {
  final OutboxRepository outbox;
  final AuthService auth;
  final ProgressGateway gateway;
  final ProgressReader reader;

  bool _flushing = false;

  SyncCoordinator({
    required this.outbox,
    required this.auth,
    required this.gateway,
    required this.reader,
  });

  /// Attempt to push every pending board. Reentrancy-guarded so overlapping
  /// triggers (a tap while a flush runs) don't double-send; the queued row
  /// survives for the next flush, so nothing is missed permanently.
  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final pending = await outbox.pending();
      if (pending.isEmpty) return;

      // Opportunistic sign-in; if we can't get a UID we keep everything queued.
      final uid = await auth.ensureSignedIn();
      if (uid == null) return;

      for (final entry in pending) {
        try {
          final progress = await reader.readProgress(entry.boardId);
          if (progress == null) {
            // Board was discarded locally (new game replaced it) — nothing to
            // sync; drop the stale job.
            await outbox.markSynced(entry.boardId);
            continue;
          }
          final markedCells = {
            for (final e in progress.marks.entries)
              if (e.value) e.key,
          };
          await gateway.pushBoardProgress(
            boardId: entry.boardId,
            spec: progress.spec,
            uid: uid,
            marks: progress.marks,
            completed: hasWon(progress.spec, markedCells),
          );
          await outbox.markSynced(entry.boardId);
        } catch (e) {
          // Keep the job for a later retry; move on to the next board.
          await outbox.markFailed(entry.boardId, e.toString());
        }
      }
    } finally {
      _flushing = false;
    }
  }
}
