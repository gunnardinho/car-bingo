import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../../domain/catalog/item.dart';

/// Reads the bundled catalog manifest (build output of `npm run build`) and maps
/// it to the domain [Catalog]. This is the whole item universe, present offline
/// from first launch (ARCHITECTURE.md §4).
class CatalogAssetLoader {
  final AssetBundle bundle;
  final String assetKey;

  CatalogAssetLoader({AssetBundle? bundle, this.assetKey = 'assets/catalog/items.json'})
      : bundle = bundle ?? rootBundle;

  Future<Catalog> load() async {
    final raw = await bundle.loadString(assetKey);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final categories = [
      for (final c in (json['categories'] as List))
        _category(c as Map<String, dynamic>),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final items = [
      for (final i in (json['items'] as List)) _item(i as Map<String, dynamic>),
    ];

    return Catalog(
      catalogVersion: json['catalogVersion'] as String,
      algoVersion: json['algoVersion'] as int,
      configHash: json['configHash'] as String,
      categories: categories,
      items: items,
    );
  }

  Category _category(Map<String, dynamic> c) => Category(
        id: c['id'] as String,
        sortOrder: c['sortOrder'] as int,
        color: _parseColor(c['color'] as String?),
        name: _localized(c['name']),
      );

  Item _item(Map<String, dynamic> i) {
    final image = i['image'] as Map<String, dynamic>;
    return Item(
      id: i['id'] as String,
      categoryId: i['categoryId'] as String,
      subCategoryId: i['subCategoryId'] as String?,
      difficulty: i['difficulty'] as int,
      weight: i['weight'] as int,
      regions: [for (final r in (i['regions'] as List? ?? const ['*'])) r as String],
      enabled: i['enabled'] as bool,
      name: _localized(i['name']),
      description: _localized(i['description']),
      imageHash: image['hash'] as String,
      imageFile: image['file'] as String,
      imageWidth: image['width'] as int,
      imageHeight: image['height'] as int,
    );
  }

  Map<String, String> _localized(dynamic v) => v == null
      ? const {}
      : {
          for (final e in (v as Map<String, dynamic>).entries)
            e.key: e.value as String,
        };

  int _parseColor(String? hex) {
    if (hex == null) return 0xFF888888;
    var h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    return int.parse(h, radix: 16);
  }
}
