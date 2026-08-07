import '../../domain/board/board_spec.dart';
import '../../domain/sync/progress_gateway.dart';

/// Placeholder gateway until Firestore is wired (see docs/FIREBASE_SETUP.md).
/// It's unreachable while [NoopAuthService] yields no UID (the coordinator
/// returns before calling it); if it ever were reached it throws so the job is
/// recorded as failed and retried — it must NEVER pretend success and silently
/// drop a pending sync. Phase 2 swaps this for a `cloud_firestore` implementation.
class NoopProgressGateway implements ProgressGateway {
  const NoopProgressGateway();

  @override
  Future<void> pushBoardProgress({
    required String boardId,
    required BoardSpec spec,
    required String uid,
    required Map<int, bool> marks,
    required bool completed,
  }) async {
    throw StateError('No progress gateway configured (Firebase not wired yet)');
  }
}
