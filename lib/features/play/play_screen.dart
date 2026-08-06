import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/bingo_tokens.dart';
import '../../l10n/app_localizations.dart';
import 'game_controller.dart';
import 'widgets/board_grid.dart';
import 'widgets/item_detail_pane.dart';

/// The play screen: adaptive board + detail (two-pane on wide, sheet on
/// compact), a progress bar, and an inline win banner.
class PlayScreen extends ConsumerWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameControllerProvider);

    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.appTitle)),
        body: Center(
          child: FilledButton(onPressed: () => context.go('/'), child: Text(l.newGame)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${game.spec.size} × ${game.spec.size}   ·   ${game.spec.seed}'),
        actions: [
          IconButton(
            tooltip: l.playAgain,
            onPressed: () {
              ref.read(selectedCellProvider.notifier).select(null);
              ref.read(gameControllerProvider.notifier).newGame(game.spec.size, winModes: game.spec.winModes);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: l.backHome,
            onPressed: () {
              ref.read(gameControllerProvider.notifier).clear();
              context.go('/');
            },
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: const [
            _ProgressBar(),
            _WinBanner(),
            Expanded(child: _PlayArea()),
          ],
        ),
      ),
    );
  }
}

class _PlayArea extends ConsumerWidget {
  const _PlayArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (ctx, c) {
        const minDetail = 360.0, gap = 16.0;
        final canSplit = c.maxWidth - c.maxHeight >= minDetail + gap;
        final boardSide = canSplit ? c.maxHeight : (c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight);
        final side = (boardSide - 24) < 0 ? 0.0 : boardSide - 24; // never negative

        final board = Padding(
          padding: const EdgeInsets.all(12),
          child: BoardGrid(
            side: side,
            onRequestDetail: canSplit ? null : (i) => _openSheet(ctx),
          ),
        );

        if (canSplit) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: boardSide, child: board),
              const SizedBox(width: gap),
              const Expanded(
                child: Padding(padding: EdgeInsets.all(12), child: ItemDetailPane()),
              ),
            ],
          );
        }
        return board;
      },
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const ItemDetailPane(inSheet: true),
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameControllerProvider);
    if (game == null) return const SizedBox.shrink();
    final total = game.totalCells;
    final done = game.markedCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: total == 0 ? 0 : done / total, minHeight: 8),
            ),
          ),
          const SizedBox(width: 12),
          Text(l.progress(done, total), style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _WinBanner extends ConsumerWidget {
  const _WinBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<BingoTokens>()!;
    final game = ref.watch(gameControllerProvider);
    if (game == null || !game.won) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: tokens.celebration, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(l.youWon,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(selectedCellProvider.notifier).select(null);
              ref.read(gameControllerProvider.notifier).newGame(game.spec.size, winModes: game.spec.winModes);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(l.playAgain),
          ),
        ],
      ),
    );
  }
}
