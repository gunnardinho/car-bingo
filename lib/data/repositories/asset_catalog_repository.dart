import '../../domain/catalog/item.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../local/assets/catalog_asset_loader.dart';

/// [CatalogRepository] backed by the bundled asset manifest. When Drift arrives
/// it seeds from this same loader and this impl swaps to a Drift-backed one with
/// no change to the domain or state layers.
class AssetCatalogRepository implements CatalogRepository {
  final CatalogAssetLoader loader;

  AssetCatalogRepository({CatalogAssetLoader? loader})
      : loader = loader ?? CatalogAssetLoader();

  @override
  Future<Catalog> loadCatalog() => loader.load();
}
