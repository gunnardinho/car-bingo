import 'package:carbingo/domain/board/board_layout.dart';
import 'package:carbingo/domain/board/board_spec.dart';
import 'package:carbingo/domain/board/difficulty_mix.dart';
import 'package:carbingo/domain/board/generator/board_generator.dart';
import 'package:carbingo/domain/board/generator/sfc32.dart';
import 'package:carbingo/domain/board/win_rules.dart';
import 'package:carbingo/domain/catalog/item.dart';
import 'package:carbingo/domain/catalog/localized_text.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixture_catalog.dart';

// Golden vectors captured from `dart run tool/gen_golden.dart` (algoVersion 1,
// fixture catalog, seed GOLD-1). If the algorithm changes intentionally, bump
// algoVersion and recapture — a change here means already-shared boards move.
const _gold3 = [
  'echo_m01', 'delta_e00', 'alpha_e02', 'charlie_m01', null, //
  'bravo_e01', 'echo_e01', 'bravo_m01', 'echo_e00',
];
const _gold4 = [
  'echo_m01', 'bravo_e01', 'alpha_e02', 'echo_e00', //
  'alpha_m02', 'charlie_m00', 'charlie_e00', 'charlie_h01', //
  'delta_e00', 'alpha_m00', 'echo_h00', 'charlie_e02', //
  'charlie_m02', 'delta_h01', 'delta_e01', 'delta_m01',
];
const _gold5 = [
  'delta_m02', 'charlie_h01', 'echo_h00', 'alpha_m02', 'echo_e00', //
  'echo_e01', 'delta_e00', 'delta_h00', 'echo_m01', 'charlie_e00', //
  'delta_m00', 'echo_m00', null, 'echo_h01', 'bravo_m00', //
  'delta_e02', 'alpha_h00', 'bravo_e01', 'charlie_m01', 'charlie_e02', //
  'bravo_e00', 'bravo_h01', 'bravo_m02', 'delta_m01', 'charlie_m00',
];

void main() {
  final catalog = buildFixtureCatalog();

  group('sfc32 PRNG', () {
    test('is deterministic from a seed', () {
      final a = Sfc32.fromSeed('hello');
      final b = Sfc32.fromSeed('hello');
      for (var i = 0; i < 20; i++) {
        expect(a.nextU32(), b.nextU32());
      }
    });

    test('different seeds diverge', () {
      final a = Sfc32.fromSeed('hello');
      final b = Sfc32.fromSeed('world');
      final different = List.generate(10, (_) => a.nextU32() != b.nextU32());
      expect(different.where((x) => x).length, greaterThan(5));
    });

    test('nextInt stays in range and nextInt(1) == 0', () {
      final rng = Sfc32.fromSeed('range');
      expect(rng.nextInt(1), 0);
      for (var i = 0; i < 1000; i++) {
        final v = rng.nextInt(7);
        expect(v, inInclusiveRange(0, 6));
      }
    });

    test('nextInt is roughly unbiased', () {
      final rng = Sfc32.fromSeed('bias');
      final buckets = List.filled(6, 0);
      const n = 60000;
      for (var i = 0; i < n; i++) {
        buckets[rng.nextInt(6)]++;
      }
      for (final b in buckets) {
        expect(b, closeTo(n / 6, n / 6 * 0.1)); // within 10%
      }
    });
  });

  group('generator determinism', () {
    test('same spec yields byte-identical layout', () {
      final s = fixtureSpec(size: 5);
      final a = generateBoard(s, catalog);
      final b = generateBoard(s, catalog);
      expect(a.cellItemIds, b.cellItemIds);
    });

    test('reproducible across fresh catalog instances', () {
      final a = generateBoard(fixtureSpec(size: 5), buildFixtureCatalog());
      final b = generateBoard(fixtureSpec(size: 5), buildFixtureCatalog());
      expect(a.cellItemIds, b.cellItemIds);
    });

    test('different seed changes the board', () {
      final a = generateBoard(fixtureSpec(seed: 'GOLD-1', size: 5), catalog);
      final b = generateBoard(fixtureSpec(seed: 'GOLD-2', size: 5), catalog);
      expect(a.cellItemIds, isNot(b.cellItemIds));
    });

    test('unknown algoVersion throws', () {
      final s = BoardSpec(
        seed: 'x',
        size: 5,
        catalogVersion: 'test-1',
        algoVersion: 99,
        configHash: 'cfg-test',
      );
      expect(() => generateBoard(s, catalog), throwsArgumentError);
    });
  });

  group('golden vectors (algoVersion 1)', () {
    test('3x3', () => expect(generateBoard(fixtureSpec(seed: 'GOLD-1', size: 3), catalog).cellItemIds, _gold3));
    test('4x4', () => expect(generateBoard(fixtureSpec(seed: 'GOLD-1', size: 4), catalog).cellItemIds, _gold4));
    test('5x5', () => expect(generateBoard(fixtureSpec(seed: 'GOLD-1', size: 5), catalog).cellItemIds, _gold5));
  });

  group('structural invariants', () {
    for (final size in [3, 4, 5]) {
      test('${size}x$size is well-formed', () {
        final spec = fixtureSpec(seed: 'STRUCT-$size', size: size);
        _validateLayout(generateBoard(spec, catalog), spec, catalog);
      });
    }

    test('odd board with the free centre disabled fills every cell', () {
      const spec = BoardSpec(
        seed: 'NOFREE',
        size: 3,
        freeSpace: false,
        catalogVersion: 'test-1',
        algoVersion: 1,
        configHash: 'cfg-test',
      );
      final layout = generateBoard(spec, catalog);
      expect(layout.cellItemIds.length, 9);
      expect(layout.cellItemIds.whereType<Null>(), isEmpty, reason: 'no free cell');
      expect(layout.itemIds.toSet().length, 9, reason: 'no duplicates');
    });
  });

  group('locale independence', () {
    test('generation ignores locale; only rendering resolves it', () {
      final layout = generateBoard(fixtureSpec(size: 5), catalog);
      final item = catalog.itemById(layout.itemIds.first)!;
      // ids are identical (no locale input); resolved names differ per locale.
      expect(resolveLocalized(item.name, 'en'), startsWith('EN '));
      expect(resolveLocalized(item.name, 'nb'), startsWith('NB '));
      expect(resolveLocalized(item.name, 'de'), startsWith('EN ')); // English fallback
    });
  });

  group('difficulty mix', () {
    for (final size in [3, 4, 5]) {
      test('${size}x$size quota sums to pick count', () {
        final q = quotaForSize(size);
        final sum = (q[Tier.easy] ?? 0) + (q[Tier.medium] ?? 0) + (q[Tier.hard] ?? 0);
        expect(sum, fixtureSpec(size: size).pickCount);
      });
    }
  });

  group('win rules', () {
    test('full board win requires every non-free cell', () {
      final spec = fixtureSpec(size: 3, winModes: [WinMode.fullBoard]);
      final all = {0, 1, 2, 3, 5, 6, 7, 8}; // free centre = 4
      expect(hasWon(spec, all), isTrue);
      expect(hasWon(spec, all.difference({6})), isFalse);
    });

    test('line win on a row', () {
      final spec = fixtureSpec(size: 3, winModes: [WinMode.lines]);
      expect(hasWon(spec, {0, 1, 2}), isTrue);
      expect(hasWon(spec, {0, 1}), isFalse);
    });

    test('free centre counts toward a diagonal', () {
      final spec = fixtureSpec(size: 3, winModes: [WinMode.lines]);
      // diagonal 0,4,8 with 4 auto-marked (free)
      expect(hasWon(spec, {0, 8}), isTrue);
    });

    test('a line does not satisfy full-board mode', () {
      final spec = fixtureSpec(size: 3, winModes: [WinMode.fullBoard]);
      expect(hasWon(spec, {0, 1, 2}), isFalse);
    });

    test('winning lines count is 2*size + 2', () {
      expect(winningLines(5).length, 12);
      expect(winningLines(3).length, 8);
    });
  });
}

void _validateLayout(BoardLayout layout, BoardSpec spec, Catalog catalog) {
  expect(layout.cellItemIds.length, spec.cellCount);
  if (spec.hasFreeCenter) {
    expect(layout.cellItemIds[spec.freeIndex!], isNull, reason: 'free centre');
  } else {
    expect(layout.cellItemIds.whereType<Null>(), isEmpty, reason: 'no free cell on even sizes');
  }

  final ids = layout.itemIds;
  expect(ids.length, spec.pickCount);
  expect(ids.toSet().length, ids.length, reason: 'no duplicate items');

  final quota = quotaForSize(spec.size);
  final counts = {Tier.easy: 0, Tier.medium: 0, Tier.hard: 0};
  final catCount = <String, int>{};
  for (final id in ids) {
    final item = catalog.itemById(id);
    expect(item, isNotNull, reason: 'placed id $id exists in catalog');
    expect(item!.hasImage, isTrue, reason: 'placed items must have an image');
    counts[item.tier] = counts[item.tier]! + 1;
    catCount.update(item.categoryId, (v) => v + 1, ifAbsent: () => 1);
  }
  for (final t in Tier.values) {
    expect(counts[t], quota[t] ?? 0, reason: 'tier $t count');
  }

  final nCats = catalog.items.map((e) => e.categoryId).toSet().length;
  final cap = (spec.pickCount / nCats).ceil() + 1;
  for (final e in catCount.entries) {
    expect(e.value, lessThanOrEqualTo(cap), reason: 'category ${e.key} within cap $cap');
  }
}
