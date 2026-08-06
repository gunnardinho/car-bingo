// ignore_for_file: avoid_print
// Prints golden board vectors (spec -> cell ids) from the fixture catalog.
// Run once to capture the expected values embedded in
// test/domain/board/generator_test.dart:
//
//   dart run tool/gen_golden.dart
import 'package:carbingo/domain/board/generator/board_generator.dart';

import '../test/support/fixture_catalog.dart';

void main() {
  final catalog = buildFixtureCatalog();
  for (final size in [3, 4, 5]) {
    final layout = generateBoard(fixtureSpec(seed: 'GOLD-1', size: size), catalog);
    print('size $size: ${layout.cellItemIds}');
  }
}
