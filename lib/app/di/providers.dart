import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/asset_catalog_repository.dart';
import '../../domain/catalog/item.dart';
import '../../domain/repositories/catalog_repository.dart';

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
