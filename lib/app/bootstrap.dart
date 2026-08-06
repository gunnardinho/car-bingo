import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/drift/database.dart';
import '../data/repositories/drift_game_repository.dart';
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
  final active = await DriftGameRepository(db).loadActiveGame();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        gameControllerProvider.overrideWith(
          () => GameController(
            initial: active == null ? null : GameState.fromPersisted(active),
          ),
        ),
      ],
      child: const CarBingoApp(),
    ),
  );
}
