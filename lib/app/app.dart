import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'router/router.dart';

/// Root widget. Light + dark from one seed, system theme mode, nb + en locales.
class CarBingoApp extends ConsumerStatefulWidget {
  const CarBingoApp({super.key});

  @override
  ConsumerState<CarBingoApp> createState() => _CarBingoAppState();
}

class _CarBingoAppState extends ConsumerState<CarBingoApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
