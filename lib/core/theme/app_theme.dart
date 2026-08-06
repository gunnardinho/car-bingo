import 'package:flutter/material.dart';

import 'bingo_tokens.dart';

/// Material 3 theming from one seed (light + dark for MVP) plus the typed
/// [BingoTokens] extension. High-contrast/Material You are deferred (§7).
const Color _seed = Color(0xFF2E86AB);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final tokens = brightness == Brightness.dark ? BingoTokens.dark : BingoTokens.light;
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}
