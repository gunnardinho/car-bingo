/// Anonymous authentication, opportunistic and non-gating (§4, §6). Play NEVER
/// waits on this: a board is fully playable with no UID, and progress stays
/// durable in Drift until a real UID lets the outbox flush to Firestore.
abstract interface class AuthService {
  /// The current signed-in uid, or null if there isn't one yet.
  String? get currentUid;

  /// Try to ensure an anonymous session and return its uid, or null if sign-in
  /// isn't possible right now (offline, or Firebase not configured). Safe to
  /// call repeatedly; must never throw in a way that reaches gameplay.
  Future<String?> ensureSignedIn();
}
