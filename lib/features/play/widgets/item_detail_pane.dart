import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/theme/bingo_tokens.dart';
import '../../../domain/board/difficulty_mix.dart';
import '../../../domain/catalog/localized_text.dart';
import '../../../l10n/app_localizations.dart';
import '../game_controller.dart';

/// Master–detail pane (expanded layout) / bottom sheet (compact): shows the
/// selected cell's item and a mark toggle.
class ItemDetailPane extends ConsumerWidget {
  final bool inSheet;
  const ItemDetailPane({super.key, this.inSheet = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<BingoTokens>()!;
    final locale = Localizations.localeOf(context).toString();

    final game = ref.watch(gameControllerProvider);
    final selected = ref.watch(selectedCellProvider);
    final catalog = ref.watch(catalogProvider).asData?.value;

    if (game == null || selected == null || catalog == null) {
      return _Frame(inSheet: inSheet, child: _empty(context, l.detailEmpty));
    }

    final id = game.layout.itemIdAt(selected);
    if (id == null) {
      return _Frame(
        inSheet: inSheet,
        child: Center(child: Text(l.freeSpace, style: theme.textTheme.headlineSmall)),
      );
    }
    final item = catalog.itemById(id);
    if (item == null) {
      return _Frame(inSheet: inSheet, child: _empty(context, l.detailEmpty));
    }

    final name = resolveLocalized(item.name, locale, fallbackId: item.id);
    final desc = resolveLocalized(item.description, locale);
    final marked = game.marks.contains(selected);
    final (diffLabel, diffColor) = switch (item.tier) {
      Tier.easy => (l.difficultyEasy, tokens.difficultyEasy),
      Tier.medium => (l.difficultyMedium, tokens.difficultyMedium),
      Tier.hard => (l.difficultyHard, tokens.difficultyHard),
    };

    return _Frame(
      inSheet: inSheet,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tokens.cellRadius),
              // Same themed backdrop as the board cell, so the transparent
              // die-cut sticker reads identically here (STYLE.md §7).
              child: Container(
                width: 160,
                height: 160,
                color: tokens.cellBackground,
                child: Image.asset(item.assetPath, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Chip(
            label: Text(diffLabel),
            backgroundColor: diffColor.withValues(alpha: 0.18),
            side: BorderSide(color: diffColor),
            visualDensity: VisualDensity.compact,
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(desc, style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => ref.read(gameControllerProvider.notifier).toggle(selected),
            icon: Icon(marked ? Icons.remove_done_rounded : Icons.check_rounded),
            label: Text(marked ? l.unmarkIt : l.markIt),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context, String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
}

class _Frame extends StatelessWidget {
  final Widget child;
  final bool inSheet;
  const _Frame({required this.child, required this.inSheet});

  @override
  Widget build(BuildContext context) {
    if (inSheet) {
      return Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), child: child);
    }
    return Card(
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}
