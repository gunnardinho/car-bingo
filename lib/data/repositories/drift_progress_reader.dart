import '../../domain/sync/board_progress.dart';
import '../../domain/sync/progress_reader.dart';
import '../local/drift/database.dart';
import '../mappers/board_mappers.dart';

/// Reads a board's live spec + marks from Drift for the sync flusher. Returns
/// null if the board's spec is gone (discarded locally), so a stale outbox job
/// is dropped rather than pushed.
class DriftProgressReader implements ProgressReader {
  final AppDatabase db;

  DriftProgressReader(this.db);

  @override
  Future<BoardProgress?> readProgress(String boardId) async {
    final specRow = await (db.select(db.boardSpecs)
          ..where((t) => t.boardId.equals(boardId)))
        .getSingleOrNull();
    if (specRow == null) return null;

    final markRows = await (db.select(db.playerMarks)
          ..where((t) => t.boardId.equals(boardId)))
        .get();

    return BoardProgress(
      spec: boardSpecFromRow(specRow),
      marks: {for (final m in markRows) m.cellIndex: m.marked},
    );
  }
}
