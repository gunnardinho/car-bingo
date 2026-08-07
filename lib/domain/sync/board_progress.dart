import '../board/board_spec.dart';

/// A board's syncable state read live from the local store: the immutable spec
/// plus every touched cell keyed by index. [marks] includes un-marks as `false`
/// (never omitted) so the pushed map is complete and a stale re-mark can't
/// resurrect a cell (§4).
class BoardProgress {
  final BoardSpec spec;
  final Map<int, bool> marks;

  const BoardProgress({required this.spec, required this.marks});
}
