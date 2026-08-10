import 'package:flutter/material.dart';

import 'bingo_tokens.dart';

/// Material 3 theming from one seed (light + dark for MVP) plus the typed
/// [BingoTokens] extension. High-contrast/Material You are deferred (§7).
const Color _seed = Color(0xFF2E86AB);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final tokens = brightness == Brightness.dark ? BingoTokens.dark : BingoTokens.light;
  final isLight = brightness == Brightness.light;

  // Rounded, friendly component shapes from the one radius scale (STYLE.md §4).
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadii.md),
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    extensions: <ThemeExtension<dynamic>>[tokens],
    // Calm, near-monochrome chrome so the sticker art carries the color
    // (STYLE.md §1/§7). Keep the dark scheme's own surface in dark mode.
    scaffoldBackgroundColor: isLight ? BingoPalette.cloud : scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: isLight ? BingoPalette.cloud : scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: buttonShape),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(color: isLight ? BingoPalette.line : scheme.outlineVariant),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
    ),
  );
}
