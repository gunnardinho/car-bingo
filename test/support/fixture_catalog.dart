import 'package:carbingo/domain/board/board_spec.dart';
import 'package:carbingo/domain/catalog/item.dart';

/// A fixed, content-independent synthetic catalog so generator golden vectors
/// test the ALGORITHM, not the shipping content (which changes as art lands).
/// 5 categories × (3 easy + 3 medium + 2 hard) = 40 items — enough to fill a
/// 5×5 without relaxation, with varied weights to exercise weighted sampling.
Catalog buildFixtureCatalog() {
  const cats = ['alpha', 'bravo', 'charlie', 'delta', 'echo'];
  const tierDifficulty = {'e': 1, 'm': 3, 'h': 4};
  const perTier = {'e': 3, 'm': 3, 'h': 2};

  final items = <Item>[];
  for (var ci = 0; ci < cats.length; ci++) {
    final cat = cats[ci];
    tierDifficulty.forEach((tk, diff) {
      final count = perTier[tk]!;
      for (var n = 0; n < count; n++) {
        final id = '${cat}_$tk${n.toString().padLeft(2, '0')}';
        items.add(Item(
          id: id,
          categoryId: cat,
          subCategoryId: null,
          difficulty: diff,
          weight: 1 + ((ci + n) % 3), // 1..3
          regions: const ['*'],
          enabled: true,
          name: {'en': 'EN $id', 'nb': 'NB $id'},
          description: const {},
          imageHash: id,
          imageFile: 'tiles/$id.webp',
          imageWidth: 512,
          imageHeight: 512,
        ));
      }
    });
  }

  return Catalog(
    catalogVersion: 'test-1',
    algoVersion: 1,
    configHash: 'cfg-test',
    categories: [
      for (var i = 0; i < cats.length; i++)
        Category(id: cats[i], sortOrder: i, color: 0xFF000000, name: {'en': cats[i]}),
    ],
    items: items,
  );
}

BoardSpec fixtureSpec({
  String seed = 'SEED-1',
  int size = 5,
  List<WinMode> winModes = const [WinMode.fullBoard],
}) =>
    BoardSpec(
      seed: seed,
      size: size,
      catalogVersion: 'test-1',
      algoVersion: 1,
      configHash: 'cfg-test',
      winModes: winModes,
    );
