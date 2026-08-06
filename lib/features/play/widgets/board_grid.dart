import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game_controller.dart';
import 'bingo_cell.dart';

/// The square board: an N×N grid sized to [side] logical px. Cells never scroll
/// or distort (fixed physics), and images decode at cell size.
class BoardGrid extends ConsumerWidget {
  final double side;
  final void Function(int index)? onRequestDetail;

  const BoardGrid({super.key, required this.side, this.onRequestDetail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    if (game == null || side <= 0) return const SizedBox.shrink();

    final size = game.spec.size;
    const spacing = 6.0;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cellLogical = (side - (size - 1) * spacing) / size;
    final cellPx = (cellLogical * dpr).round().clamp(64, 1024);

    return Center(
      child: SizedBox(
        width: side,
        height: side,
        child: GridView.count(
          crossAxisCount: size,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          children: [
            for (var i = 0; i < size * size; i++)
              BingoCell(index: i, cellPx: cellPx, onRequestDetail: onRequestDetail),
          ],
        ),
      ),
    );
  }
}
