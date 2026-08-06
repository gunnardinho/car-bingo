import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/theme/bingo_tokens.dart';
import '../../../domain/catalog/localized_text.dart';
import '../../../l10n/app_localizations.dart';
import '../game_controller.dart';

/// One board cell: image, caption, marked overlay, a11y toggle. State is never
/// encoded by colour alone — a marked cell gets a check icon + scrim (§3).
class BingoCell extends ConsumerWidget {
  final int index;
  final int cellPx; // physical px for decode-at-cell-size
  final void Function(int index)? onRequestDetail;

  const BingoCell({
    super.key,
    required this.index,
    required this.cellPx,
    this.onRequestDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BingoTokens>()!;
    final locale = Localizations.localeOf(context).toString();

    final game = ref.watch(gameControllerProvider);
    if (game == null) return const SizedBox.shrink();
    final catalog = ref.watch(catalogProvider).asData?.value;

    final itemId = game.layout.itemIdAt(index);
    final isFree = itemId == null;
    final userMarked = game.marks.contains(index);
    final marked = isFree || userMarked;
    final item = (itemId == null || catalog == null) ? null : catalog.itemById(itemId);
    final name = isFree
        ? l.freeSpace
        : (item == null ? '' : resolveLocalized(item.name, locale, fallbackId: item.id));
    final selected = ref.watch(selectedCellProvider) == index;

    Widget image;
    if (isFree) {
      image = Container(
        color: tokens.cellFree,
        child: const Center(child: Icon(Icons.auto_awesome_rounded, size: 40, color: Colors.white)),
      );
    } else if (item != null) {
      image = Image.asset(
        item.assetPath,
        fit: BoxFit.cover,
        cacheWidth: cellPx,
        filterQuality: FilterQuality.medium,
        errorBuilder: (c, e, s) => Container(
          color: scheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image_outlined),
        ),
      );
    } else {
      image = Container(color: scheme.surfaceContainerHighest);
    }

    return Semantics(
      button: !isFree,
      toggled: isFree ? null : marked,
      label: isFree ? l.freeSpace : '$name, ${marked ? l.cellMarked : l.cellNotMarked}',
      child: GestureDetector(
        onTap: isFree
            ? null
            : () {
                ref.read(gameControllerProvider.notifier).toggle(index);
                ref.read(selectedCellProvider.notifier).select(index);
              },
        onLongPress: () {
          ref.read(selectedCellProvider.notifier).select(index);
          onRequestDetail?.call(index);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.cellRadius),
            border: selected ? Border.all(color: scheme.primary, width: 3) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: tokens.cellShadowOpacity),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.cellRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ExcludeSemantics(child: image),
                // caption is decorative; the name is already in the cell's
                // Semantics label, so exclude it to avoid a double announcement
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ExcludeSemantics(child: _Caption(text: name)),
                ),
                if (userMarked)
                  ColoredBox(
                    color: tokens.cellMarked.withValues(alpha: 0.5),
                    child: const Center(
                      child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 44),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  final String text;
  const _Caption({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xCC000000), Color(0x00000000)],
        ),
      ),
      // Clamp scaling inside cells only so large accessibility fonts can't
      // shatter a 5×5 grid; the name is still available via the detail pane.
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
