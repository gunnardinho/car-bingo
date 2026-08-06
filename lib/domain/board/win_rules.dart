/// Win detection is DERIVED from (spec, marks) and never stored authoritatively
/// (ARCHITECTURE.md §8). The free centre counts as marked toward any line.
library;

import 'board_spec.dart';

bool cellMarked(int index, int? freeIndex, Set<int> marks) =>
    index == freeIndex || marks.contains(index);

/// Every winning line for a board of [size]: each row, each column, both
/// diagonals (indices are row-major).
List<List<int>> winningLines(int size) {
  final lines = <List<int>>[];
  for (var r = 0; r < size; r++) {
    lines.add([for (var c = 0; c < size; c++) r * size + c]);
  }
  for (var c = 0; c < size; c++) {
    lines.add([for (var r = 0; r < size; r++) r * size + c]);
  }
  lines.add([for (var i = 0; i < size; i++) i * size + i]);
  lines.add([for (var i = 0; i < size; i++) i * size + (size - 1 - i)]);
  return lines;
}

bool isFullBoard(int size, int? freeIndex, Set<int> marks) {
  for (var i = 0; i < size * size; i++) {
    if (!cellMarked(i, freeIndex, marks)) return false;
  }
  return true;
}

bool hasLine(int size, int? freeIndex, Set<int> marks) {
  for (final line in winningLines(size)) {
    if (line.every((i) => cellMarked(i, freeIndex, marks))) return true;
  }
  return false;
}

/// True if any of the board's [BoardSpec.winModes] is satisfied.
bool hasWon(BoardSpec spec, Set<int> marks) {
  for (final mode in spec.winModes) {
    switch (mode) {
      case WinMode.fullBoard:
        if (isFullBoard(spec.size, spec.freeIndex, marks)) return true;
      case WinMode.lines:
        if (hasLine(spec.size, spec.freeIndex, marks)) return true;
    }
  }
  return false;
}
