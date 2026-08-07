import 'board_progress.dart';

/// Reads a board's current syncable progress from the local source of truth
/// (Drift). Returns null if the board no longer exists locally (e.g. it was
/// discarded when a new game started), so the flusher can drop a stale job.
abstract interface class ProgressReader {
  Future<BoardProgress?> readProgress(String boardId);
}
