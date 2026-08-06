import 'package:carbingo/app/app.dart';
import 'package:carbingo/app/di/providers.dart';
import 'package:carbingo/features/play/widgets/board_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/in_memory_game_repository.dart';

void main() {
  testWidgets('loads bundled catalog, starts a 5×5, and renders the board',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRepositoryProvider.overrideWithValue(InMemoryGameRepository()),
        ],
        child: const CarBingoApp(),
      ),
    );
    // let the catalog FutureProvider resolve from the bundled asset
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Home offers all three board sizes.
    expect(find.text('3 × 3'), findsOneWidget);
    expect(find.text('5 × 5'), findsOneWidget);

    await tester.tap(find.text('5 × 5'));
    await tester.pumpAndSettle();

    // The board is on screen.
    expect(find.byType(BoardGrid), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
