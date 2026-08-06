import '../../domain/auth/auth_service.dart';

/// Placeholder auth until Firebase is wired (see docs/FIREBASE_SETUP.md). It
/// never produces a UID, so the outbox simply stays queued and progress remains
/// durable in Drift — the correct offline-first behaviour. Phase 2 swaps this
/// for a `firebase_auth`-backed implementation.
class NoopAuthService implements AuthService {
  const NoopAuthService();

  @override
  String? get currentUid => null;

  @override
  Future<String?> ensureSignedIn() async => null;
}
