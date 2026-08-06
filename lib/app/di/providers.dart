import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/drift/database.dart';
import '../../data/repositories/asset_catalog_repository.dart';
import '../../data/repositories/drift_game_repository.dart';
import '../../domain/catalog/item.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/game_repository.dart';

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

/// Persistence for the active solo game (Drift-backed local source of truth, §4).
final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => DriftGameRepository(ref.watch(appDatabaseProvider)),
);
