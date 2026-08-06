import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Game-specific design tokens as a typed [ThemeExtension]: a theme that forgets
/// a token won't compile (ARCHITECTURE.md §7). `cellShadowOpacity` is
/// per-brightness because light-mode shadows wash out in dark.
@immutable
class BingoTokens extends ThemeExtension<BingoTokens> {
  final Color cellMarked; // scrim over a checked cell
  final Color cellFree; // the free-centre tile
  final Color celebration; // win accent
  final Color difficultyEasy;
  final Color difficultyMedium;
  final Color difficultyHard;
  final double cellRadius;
  final double cellShadowOpacity;

  const BingoTokens({
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
    cellMarked: Color(0xE6111827),
    cellFree: Color(0xFFF6BD60),
    celebration: Color(0xFF2E7D32),
    difficultyEasy: Color(0xFF2E7D32),
    difficultyMedium: Color(0xFFE08A00),
    difficultyHard: Color(0xFFC62828),
    cellRadius: 16,
    cellShadowOpacity: 0.18,
  );

  static const dark = BingoTokens(
    cellMarked: Color(0xE6000000),
    cellFree: Color(0xFFD9A441),
    celebration: Color(0xFF66BB6A),
    difficultyEasy: Color(0xFF81C784),
    difficultyMedium: Color(0xFFFFB74D),
    difficultyHard: Color(0xFFEF9A9A),
    cellRadius: 16,
    cellShadowOpacity: 0.42,
  );

  @override
  BingoTokens copyWith({
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
