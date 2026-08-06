import 'package:carbingo/domain/board/board_layout.dart';
import 'package:carbingo/domain/board/board_spec.dart';
import 'package:carbingo/domain/game/persisted_game.dart';
import 'package:carbingo/domain/repositories/game_repository.dart';

/// A dependency-free [GameRepository] for widget/controller tests — no Drift,
/// no native sqlite, no path_provider. Mutations run synchronously in the method
/// body (before any await), so a fire-and-forget call from the controller is
/// observable immediately after it returns.
class InMemoryGameRepository implements GameRepository {
  String? _activeBoardId;
  final Map<String, BoardSpec> _specs = {};
  final Map<String, BoardLayout> _layouts = {};
  // boardId -> (cellIndex -> marked)
  final Map<String, Map<int, bool>> _marks = {};

  @override
  Future<PersistedGame?> loadActiveGame() async {
    final id = _activeBoardId;
    if (id == null) return null;
    final spec = _specs[id];
    final layout = _layouts[id];
    if (spec == null || layout == null) return null;
    final marks = {
      for (final e in (_marks[id] ?? const <int, bool>{}).entries)
        if (e.value) e.key,
    };
    return PersistedGame(boardId: id, spec: spec, layout: layout, marks: marks);
  }

  @override
  Future<void> startGame(PersistedGame game) async {
    // Single active board: replace any previous one (mirrors the Drift impl).
    _specs.clear();
    _layouts.clear();
    _marks.clear();
    _specs[game.boardId] = game.spec;
    _layouts[game.boardId] = game.layout;
    _marks[game.boardId] = {for (final i in game.marks) i: true};
    _activeBoardId = game.boardId;
  }

  @override
  Future<void> setMark({
    required String boardId,
    required int cellIndex,
    required bool marked,
  }) async {
    (_marks[boardId] ??= {})[cellIndex] = marked;
  }
}
