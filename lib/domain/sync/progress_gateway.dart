import '../board/board_spec.dart';

/// The remote sink for progress (Firestore, later). Keeps the domain free of the
/// SDK: `boards/{boardId}` (immutable spec, created idempotently) and this
/// player's `players/{uid}` marks doc are both written merge-style so different
/// edits union and a re-push never clobbers (§4, §5).
abstract interface class ProgressGateway {
  Future<void> pushBoardProgress({
    required String boardId,
    required BoardSpec spec,
    required String uid,
    required Map<int, bool> marks, // cell index -> marked (false == un-marked)
    required bool completed,
  });
}
