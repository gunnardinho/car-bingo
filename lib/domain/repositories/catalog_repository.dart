import '../catalog/item.dart';

/// Repository interface for the item catalog. The domain depends only on this;
/// the data layer supplies an implementation (bundled asset now, Drift-backed
/// later) with no change to callers.
abstract interface class CatalogRepository {
  Future<Catalog> loadCatalog();
}
