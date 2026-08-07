# Progress sync — offline outbox + anonymous auth

How solo progress reaches Firestore without ever gating play (ARCHITECTURE.md
§4). Built in two phases:

- **Phase 1 (done, this branch):** the whole offline-first engine behind clean
  seams — no Firebase packages, fully unit-tested, merge-safe.
- **Phase 2 (activation):** drop in two thin Firebase adapters + init + flush
  triggers, once `flutterfire configure` has run (docs/FIREBASE_SETUP.md).

## Design

```
GameController.toggle
  └─ GameRepository.setMark ──(one Drift transaction)──┐
        • upsert player_marks row (local source of truth)
        • OutboxRepository.enqueue(boardId)   ← sync intent, atomic with the mark
                                                        │
SyncCoordinator.flush()  (triggered opportunistically) │
  ├─ OutboxRepository.pending()  ◄──────────────────────┘
  ├─ AuthService.ensureSignedIn()      → null ⇒ stay queued (never gates play)
  ├─ ProgressReader.readProgress(id)   → live spec + marks from Drift (coalesced)
  ├─ ProgressGateway.pushBoardProgress → boards/{id}(+players/{uid})
  └─ OutboxRepository.markSynced / markFailed   (explicit ack / retry)
```

Key properties:
- **Progress is durable before any cloud contact.** The mark and its sync intent
  are written in one Drift transaction — a mark can't exist without a queued sync.
- **Never gates play.** No UID (offline / Firebase not configured) ⇒ `flush()`
  returns early and the job stays queued. Nothing is lost; it syncs later.
- **Coalesced.** One outbox row per board; the flusher reads the *latest* marks at
  push time, so many taps become one write. Un-marks are kept as `false`.
- **Safe ack.** Each enqueue bumps a monotonic per-board `revision`; the flusher
  captures it before pushing and acks (deletes) only that exact revision. A mark
  made during an in-flight push bumps the revision, so its job survives and syncs
  on the next flush — the ack can never race a concurrent change away.
- **Explicit retry.** A failed push bumps `attempts` + `lastError` and is retried;
  a job for a board that no longer exists locally is dropped.

### Files (Phase 1)

| Layer | File |
|---|---|
| domain | `domain/repositories/outbox_repository.dart`, `domain/sync/{outbox_entry,progress_gateway,progress_reader,board_progress,sync_coordinator}.dart`, `domain/auth/auth_service.dart` |
| data | `data/local/drift/database.dart` (`SyncOutbox` table, schema **v2** + migration), `data/repositories/{drift_outbox_repository,drift_progress_reader,drift_game_repository}.dart`, `data/sync/{noop_auth_service,noop_progress_gateway}.dart`, `data/mappers/board_mappers.dart` |
| DI | `app/di/providers.dart` — `outboxRepositoryProvider`, `progressReaderProvider`, `authServiceProvider`, `progressGatewayProvider`, `syncCoordinatorProvider` |

Tests: outbox repo, migration (real v1→v2), progress reader, coordinator (happy /
offline / retry / stale / completed), plus the existing game-repo integration.

---

## Phase 2 — activation (after `flutterfire configure`)

### 1. Add packages
```bash
flutter pub add firebase_core cloud_firestore firebase_auth
```

### 2. `FirebaseAuthService` (replaces `NoopAuthService`)
```dart
// lib/data/sync/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/auth/auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  FirebaseAuthService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Future<String?> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing.uid;
    try {
      final cred = await _auth.signInAnonymously();
      return cred.user?.uid;
    } catch (_) {
      return null; // offline / unavailable — never gate play
    }
  }
}
```

### 3. `FirestoreProgressGateway` (replaces `NoopProgressGateway`)
Note the rules: `boards/{id}` is **create-once** (`allow update: if false`), while
each player writes only their own `players/{uid}` doc. So create the board doc in
a transaction if missing, then merge the player doc.
```dart
// lib/data/sync/firestore_progress_gateway.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/board/board_spec.dart';
import '../../domain/sync/progress_gateway.dart';

class FirestoreProgressGateway implements ProgressGateway {
  final FirebaseFirestore _db;
  FirestoreProgressGateway([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<void> pushBoardProgress({
    required String boardId,
    required BoardSpec spec,
    required String uid,
    required Map<int, bool> marks,
    required bool completed,
  }) async {
    final board = _db.doc('boards/$boardId');
    // Idempotent create-once (rules forbid updating the frozen spec).
    await _db.runTransaction((tx) async {
      final snap = await tx.get(board);
      if (!snap.exists) {
        tx.set(board, {
          'seed': spec.seed, 'size': spec.size, 'freeSpace': spec.freeSpace,
          'catalogVersion': spec.catalogVersion, 'algoVersion': spec.algoVersion,
          'configHash': spec.configHash,
          'winModes': [for (final m in spec.winModes) m.name],
          'mode': spec.mode, 'visibility': 'private',
          'createdBy': uid, 'memberUids': [uid],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
    // Per-cell marks map; un-mark stays m:false (never a delete).
    await board.collection('players').doc(uid).set({
      'uid': uid,
      'marks': {for (final e in marks.entries) '${e.key}': {'m': e.value}},
      'completedAt': completed ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
```

### 4. Swap the providers (`app/di/providers.dart`)
```dart
final authServiceProvider = Provider<AuthService>((ref) => FirebaseAuthService());
final progressGatewayProvider =
    Provider<ProgressGateway>((ref) => FirestoreProgressGateway());
```

### 5. Init Firebase + persistent cache in `bootstrap()`
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
FirebaseFirestore.instance.settings =
    const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
```

### 6. Trigger `flush()` opportunistically (the only thing Phase 1 leaves unwired)
- On app start (e.g. in `CarBingoApp.initState`: `ref.read(syncCoordinatorProvider).flush()`).
- After a mark (`GameController.toggle` → `ref.read(syncCoordinatorProvider).flush()`, fire-and-forget).
- On connectivity regained (add `connectivity_plus` and flush on the online event).

> Widget/controller tests that pump the app or toggle cells will then need to
> override `syncCoordinatorProvider` (or the leaf sync providers) with fakes from
> `test/support/fake_sync.dart`, the same way the smoke test overrides the game repo.

### 7. Verify (real-device offline QA, §11)
First-ever launch in airplane mode → play a full board → reconnect → confirm the
`players/{uid}` doc appears in the console with the right `marks`, and progress
survives an uninstall/reinstall once account-linking (v2) lands.
