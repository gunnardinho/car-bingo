import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/drift/database.dart';
import '../data/repositories/drift_game_repository.dart';
import '../data/repositories/drift_outbox_repository.dart';
import '../features/play/game_controller.dart';
import 'app.dart';
import 'di/providers.dart';

/// Bootstrap: open Drift, restore the active game (so an in-flight board — and
/// all its progress — survives a restart with zero connectivity, §4), then mount
/// the app with the live database and rehydrated game injected. Firestore/auth
/// (the sync outbox) land in the next increment. Catalog loading stays lazy via
/// `catalogProvider`.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase.open();
  final initial = await _restoreActiveGame(db);

  runApp(
    ProviderScope(
      overrides: [
        // Override with a closure (not a bare value) so the handle is still
        // released if this scope is ever disposed (e.g. in tests).
        appDatabaseProvider.overrideWith((ref) {
          ref.onDispose(db.close);
          return db;
        }),
        gameControllerProvider.overrideWith(() => GameController(initial: initial)),
      ],
      child: const CarBingoApp(),
    ),
  );
}

/// Restoring the active game is BEST-EFFORT: a corrupt or unreadable local store
/// must never stop the app from launching into a fresh, winnable game (P1 / §4).
Future<GameState?> _restoreActiveGame(AppDatabase db) async {
  try {
    final repo = DriftGameRepository(db, outbox: DriftOutboxRepository(db));
    final active = await repo.loadActiveGame();
    return active == null ? null : GameState.fromPersisted(active);
  } catch (e) {
    debugPrint('active-game restore failed; launching fresh: $e');
    return null;
  }
}
