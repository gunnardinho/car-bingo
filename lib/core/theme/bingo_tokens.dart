import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Game-specific design tokens as a typed [ThemeExtension]: a theme that forgets
/// a token won't compile (ARCHITECTURE.md §7). `cellShadowOpacity` is
/// per-brightness because light-mode shadows wash out in dark.
@immutable
class BingoTokens extends ThemeExtension<BingoTokens> {
  final Color cellBackground; // dynamic backdrop the die-cut sticker floats on
  final Color cellMarked; // scrim over a checked cell
  final Color cellFree; // the free-centre tile
  final Color celebration; // win accent
  final Color difficultyEasy;
  final Color difficultyMedium;
  final Color difficultyHard;
  final double cellRadius;
  final double cellShadowOpacity;

  const BingoTokens({
    required this.cellBackground,
    required this.cellMarked,
    required this.cellFree,
    required this.celebration,
    required this.difficultyEasy,
    required this.difficultyMedium,
    required this.difficultyHard,
    required this.cellRadius,
    required this.cellShadowOpacity,
  });

  static const light = BingoTokens(
    // Dynamic backdrop the die-cut stickers float on. Default = white; a seasonal
    // theme overrides just this token (e.g. Christmas red — see STYLE.md §7).
    cellBackground: Color(0xFFFFFFFF),
    cellMarked: Color(0xE6111827),
    cellFree: Color(0xFFF6BD60),
    celebration: Color(0xFF2E7D32),
    difficultyEasy: Color(0xFF2E7D32),
    difficultyMedium: Color(0xFFE08A00),
    difficultyHard: Color(0xFFC62828),
    cellRadius: AppRadii.md,
    // Softer, minimal single-layer shadow (STYLE.md §5). Stickers sit on a
    // light `Cloud` grid, so a heavy shadow would read as clutter.
    cellShadowOpacity: 0.12,
  );

  static const dark = BingoTokens(
    cellBackground: Color(0xFF1E2A34), // deep slate; white-outlined stickers pop
    cellMarked: Color(0xE6000000),
    cellFree: Color(0xFFD9A441),
    celebration: Color(0xFF66BB6A),
    difficultyEasy: Color(0xFF81C784),
    difficultyMedium: Color(0xFFFFB74D),
    difficultyHard: Color(0xFFEF9A9A),
    cellRadius: AppRadii.md,
    cellShadowOpacity: 0.30,
  );

  @override
  BingoTokens copyWith({
    Color? cellBackground,
    Color? cellMarked,
    Color? cellFree,
    Color? celebration,
    Color? difficultyEasy,
    Color? difficultyMedium,
    Color? difficultyHard,
    double? cellRadius,
    double? cellShadowOpacity,
  }) {
    return BingoTokens(
      cellBackground: cellBackground ?? this.cellBackground,
      cellMarked: cellMarked ?? this.cellMarked,
      cellFree: cellFree ?? this.cellFree,
      celebration: celebration ?? this.celebration,
      difficultyEasy: difficultyEasy ?? this.difficultyEasy,
      difficultyMedium: difficultyMedium ?? this.difficultyMedium,
      difficultyHard: difficultyHard ?? this.difficultyHard,
      cellRadius: cellRadius ?? this.cellRadius,
      cellShadowOpacity: cellShadowOpacity ?? this.cellShadowOpacity,
    );
  }

  @override
  BingoTokens lerp(covariant ThemeExtension<BingoTokens>? other, double t) {
    if (other is! BingoTokens) return this;
    return BingoTokens(
      cellBackground: Color.lerp(cellBackground, other.cellBackground, t)!,
      cellMarked: Color.lerp(cellMarked, other.cellMarked, t)!,
      cellFree: Color.lerp(cellFree, other.cellFree, t)!,
      celebration: Color.lerp(celebration, other.celebration, t)!,
      difficultyEasy: Color.lerp(difficultyEasy, other.difficultyEasy, t)!,
      difficultyMedium: Color.lerp(difficultyMedium, other.difficultyMedium, t)!,
      difficultyHard: Color.lerp(difficultyHard, other.difficultyHard, t)!,
      cellRadius: lerpDouble(cellRadius, other.cellRadius, t)!,
      cellShadowOpacity: lerpDouble(cellShadowOpacity, other.cellShadowOpacity, t)!,
    );
  }
}

/// App-wide design-language constants (STYLE.md §2/§4/§6). Kept as plain consts —
/// they don't vary by brightness, so they don't belong in [BingoTokens].
///
/// The vibrant/playful direction lives in the *stickers*; the app chrome stays
/// calm (white + `cloud` + one brand blue). Category colors are retained here for
/// future use (filters, legends) but are intentionally NOT painted as backgrounds
/// in v2.
abstract final class BingoPalette {
  // Neutrals (the canvas).
  static const white = Color(0xFFFFFFFF);
  static const cloud = Color(0xFFF5F7F9); // app background / grid gaps
  static const line = Color(0xFFE3E8EC); // hairline dividers / tile edge
  static const slate = Color(0xFF5B6B78); // secondary text
  static const ink = Color(0xFF16212B); // primary text / glyph outlines

  /// Brand blue — also the Material `ColorScheme` seed (see `app_theme.dart`).
  static const brand = Color(0xFF2E86AB);

  // Playful accent palette (STYLE.md §2). Vibrant, high-contrast on white.
  // The first five double as the legacy category colors.
  static const blue = Color(0xFF2E86AB);
  static const coral = Color(0xFFE4572E);
  static const grass = Color(0xFF6A994E);
  static const teal = Color(0xFF4C956C);
  static const terracotta = Color(0xFFC1666B);
  static const sunshine = Color(0xFFF6BD60);
  static const grape = Color(0xFF8E44AD);
  static const sky = Color(0xFF1B9AAA);

  /// The curated accent set, in a stable order.
  static const accents = <Color>[
    blue,
    coral,
    grass,
    teal,
    terracotta,
    sunshine,
    grape,
    sky,
  ];
}

/// Corner-radius scale (STYLE.md §4). `md` is the tile/cell radius.
abstract final class AppRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16; // cells, tiles, primary buttons
  static const double lg = 24; // cards, sheets, detail pane
  static const double xl = 32;
  static const double pill = 999;
}

/// Spacing scale (STYLE.md §6).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16; // default gutter
  static const double xl = 24; // screen padding
  static const double xxl = 32;
  static const double xxxl = 48;
}
