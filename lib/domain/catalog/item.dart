import '../board/difficulty_mix.dart';

/// One road-item in the catalog. Immutable, versioned data (ARCHITECTURE.md §2:
/// content-as-data). Localized fields are locale-keyed maps resolved only at
/// render time — never during board generation.
class Item {
  final String id;
  final String categoryId;
  final String? subCategoryId;
  final int difficulty; // 1–5
  final int weight; // integer sampling weight
  final List<String> regions;
  final bool enabled;
  final Map<String, String> name;
  final Map<String, String> description;
  final String imageHash;
  final String imageFile; // relative to assets/catalog/, e.g. tiles/<hash>.webp
  final int imageWidth;
  final int imageHeight;

  const Item({
    required this.id,
    required this.categoryId,
    required this.subCategoryId,
    required this.difficulty,
    required this.weight,
    required this.regions,
    required this.enabled,
    required this.name,
    required this.description,
    required this.imageHash,
    required this.imageFile,
    required this.imageWidth,
    required this.imageHeight,
  });

  Tier get tier => tierForDifficulty(difficulty);

  /// The generator only selects items whose image is physically present, so a
  /// board can never render a placeholder for a missing tile (§4).
  bool get hasImage => imageHash.isNotEmpty && imageFile.isNotEmpty;

  /// Full asset key for `Image.asset`.
  String get assetPath => 'assets/catalog/$imageFile';
}

/// A top-level catalog category (drives the per-category cap in generation and
/// grouping in the browse UI).
class Category {
  final String id;
  final int sortOrder;
  final int color; // ARGB (0xFFRRGGBB)
  final Map<String, String> name;

  const Category({
    required this.id,
    required this.sortOrder,
    required this.color,
    required this.name,
  });
}

/// The whole bundled item universe for one [catalogVersion]. A board pins a
/// catalogVersion so its layout stays reproducible; in the bundled MVP this
/// equals the app's shipped catalog and is immutable by construction.
class Catalog {
  final String catalogVersion;
  final int algoVersion;
  final String configHash;
  final List<Category> categories;
  final List<Item> items;
  final Map<String, Item> _byId;
  final Map<String, Category> _categoryById;

  Catalog({
    required this.catalogVersion,
    required this.algoVersion,
    required this.configHash,
    required this.categories,
    required this.items,
  })  : _byId = {for (final i in items) i.id: i},
        _categoryById = {for (final c in categories) c.id: c};

  Item? itemById(String id) => _byId[id];
  Category? categoryById(String id) => _categoryById[id];
  int get enabledCount => items.where((i) => i.enabled).length;
}
