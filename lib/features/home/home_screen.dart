import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/di/providers.dart';
import '../../domain/catalog/item.dart';
import '../../l10n/app_localizations.dart';
import '../play/game_controller.dart';

/// Home: pick a board size and start a solo game. Gates on the catalog being
/// loaded so `newGame` always has the item universe.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(padding: const EdgeInsets.all(24), child: Text(l.loadFailed(e.toString()))),
        ),
        data: (cat) => _HomeBody(catalog: cat),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  final Catalog catalog;
  const _HomeBody({required this.catalog});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // A restored (or in-flight) game makes "Resume" available; otherwise the
    // screen is purely a new-game launcher.
    final active = ref.watch(gameControllerProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.homeHeadline, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(l.homeSubtitle(catalog.enabledCount),
                  style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              if (active != null) ...[
                FilledButton.icon(
                  onPressed: () => context.go('/play'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('${l.resumeGame}  ·  ${active.spec.size} × ${active.spec.size}',
                        style: theme.textTheme.titleMedium),
                  ),
                ),
                const SizedBox(height: 24),
                Text(l.startNewGame,
                    style: theme.textTheme.labelMedium, textAlign: TextAlign.center),
                const SizedBox(height: 12),
              ],
              for (final size in const [3, 4, 5]) ...[
                FilledButton(
                  onPressed: () {
                    ref.read(selectedCellProvider.notifier).select(null);
                    ref.read(gameControllerProvider.notifier).newGame(size);
                    context.go('/play');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(l.boardSize(size), style: theme.textTheme.titleMedium),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
