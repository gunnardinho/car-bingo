import '../board/board_layout.dart';
import '../board/board_spec.dart';

/// A durable game: the board's storage key + immutable [BoardSpec] + the frozen
/// [BoardLayout] (authoritative, §4) + the set of marked cell indices. This is
/// the shape the [GameRepository] round-trips through local storage; the feature
/// layer maps it to/from its richer `GameState`.
class PersistedGame {
  final String boardId;
  final BoardSpec spec;
  final BoardLayout layout;
  final Set<int> marks; // user-marked cell indices (excludes the free centre)

  const PersistedGame({
    required this.boardId,
    required this.spec,
    required this.layout,
    required this.marks,
  });
}
