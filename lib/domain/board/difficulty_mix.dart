/// Difficulty tiers and the per-board-size quota table.
///
/// Kept byte-for-byte in sync with `scripts/validate-catalog.mjs` (the build-time
/// content-sufficiency gate). See ARCHITECTURE.md §8.
library;

enum Tier { easy, medium, hard }

/// Maps a 1–5 authoring difficulty onto a generator tier: 1–2 easy, 3 medium,
/// 4–5 hard. (See STYLE.md — difficulty is real-world spot-rarity.)
Tier tierForDifficulty(int difficulty) {
  if (difficulty <= 2) return Tier.easy;
  if (difficulty == 3) return Tier.medium;
  return Tier.hard;
}

/// How many easy/medium/hard cells a board of [size] draws. Small boards skew
/// easy. Sum always equals the pick count (cells minus the free centre).
Map<Tier, int> quotaForSize(int size) {
  switch (size) {
    case 3:
      return const {Tier.easy: 5, Tier.medium: 3, Tier.hard: 0}; // 8 picks
    case 4:
      return const {Tier.easy: 7, Tier.medium: 6, Tier.hard: 3}; // 16 picks
    case 5:
      return const {Tier.easy: 8, Tier.medium: 10, Tier.hard: 6}; // 24 picks
    default:
      throw ArgumentError('Unsupported board size: $size (supported: 3, 4, 5)');
  }
}
