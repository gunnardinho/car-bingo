import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/drift/database.dart';
import '../../data/repositories/asset_catalog_repository.dart';
import '../../data/repositories/drift_game_repository.dart';
import '../../data/repositories/drift_outbox_repository.dart';
import '../../data/repositories/drift_progress_reader.dart';
import '../../data/sync/noop_auth_service.dart';
import '../../data/sync/noop_progress_gateway.dart';
import '../../domain/auth/auth_service.dart';
import '../../domain/catalog/item.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/outbox_repository.dart';
import '../../domain/sync/progress_gateway.dart';
import '../../domain/sync/progress_reader.dart';
import '../../domain/sync/sync_coordinator.dart';

/// The catalog repository (bundled-asset impl for MVP). Overridable at the
/// [ProviderScope] and in tests.
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => AssetCatalogRepository(),
);

/// The loaded catalog. `AsyncValue` naturally models the (brief) load; kept
/// alive so it loads once. Screens gate play on `.hasValue`.
final catalogProvider = FutureProvider<Catalog>(
  (ref) => ref.watch(catalogRepositoryProvider).loadCatalog(),
);

/// The on-device Drift database. Opened once and overridden with the concrete
/// instance in [bootstrap] (so the same handle preloads the active game); tests
/// override [gameRepositoryProvider] with an in-memory fake instead.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) {
    final db = AppDatabase.open();
    ref.onDispose(db.close);
    return db;
  },
);

/// The offline progress-sync outbox (Drift-backed).
final outboxRepositoryProvider = Provider<OutboxRepository>(
  (ref) => DriftOutboxRepository(ref.watch(appDatabaseProvider)),
);

/// Persistence for the active solo game. Enqueues sync intent atomically with
/// mark writes via [outboxRepositoryProvider] (§4).
final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => DriftGameRepository(
    ref.watch(appDatabaseProvider),
    outbox: ref.watch(outboxRepositoryProvider),
  ),
);

/// Reads live board progress from Drift for the sync flusher.
final progressReaderProvider = Provider<ProgressReader>(
  (ref) => DriftProgressReader(ref.watch(appDatabaseProvider)),
);

// --- sync seam (Firebase-backed impls land in Phase 2; see docs/FIREBASE_SETUP.md) ---

/// Anonymous auth. No-op placeholder until Firebase is configured — yields no
/// UID, so the outbox stays queued and play is never gated.
final authServiceProvider = Provider<AuthService>((ref) => const NoopAuthService());

/// Remote progress sink. No-op placeholder until Firestore is configured.
final progressGatewayProvider =
    Provider<ProgressGateway>((ref) => const NoopProgressGateway());

/// Drains the outbox to the gateway once a real UID exists (§4).
final syncCoordinatorProvider = Provider<SyncCoordinator>(
  (ref) => SyncCoordinator(
    outbox: ref.watch(outboxRepositoryProvider),
    auth: ref.watch(authServiceProvider),
    gateway: ref.watch(progressGatewayProvider),
    reader: ref.watch(progressReaderProvider),
  ),
);
