import '../game/persisted_game.dart';

/// Persistence boundary for the active solo game. The domain depends only on
/// this; the data layer supplies a Drift-backed implementation. Progress is the
/// local source of truth (§4) — writes land here immediately, before any cloud
/// contact, so a whole session survives a restart with zero connectivity.
abstract interface class GameRepository {
  /// The active game (spec + frozen layout + marks), or null if none is active.
  Future<PersistedGame?> loadActiveGame();

  /// Persist a freshly started game and make it the single active board.
  Future<void> startGame(PersistedGame game);

  /// Persist one cell toggle. An un-mark is recorded as `marked = false`, never
  /// a delete, so it can't be silently resurrected once sync exists (§4).
  Future<void> setMark({
    required String boardId,
    required int cellIndex,
    required bool marked,
  });
}
