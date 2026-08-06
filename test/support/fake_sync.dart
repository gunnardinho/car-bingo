import 'package:carbingo/domain/auth/auth_service.dart';
import 'package:carbingo/domain/board/board_spec.dart';
import 'package:carbingo/domain/repositories/outbox_repository.dart';
import 'package:carbingo/domain/sync/board_progress.dart';
import 'package:carbingo/domain/sync/outbox_entry.dart';
import 'package:carbingo/domain/sync/progress_gateway.dart';
import 'package:carbingo/domain/sync/progress_reader.dart';

/// Dependency-free fakes for the sync seam so [SyncCoordinator] can be tested
/// without Drift or Firebase.

class InMemoryOutboxRepository implements OutboxRepository {
  final Map<String, OutboxEntry> entries = {}; // boardId -> entry

  @override
  Future<void> enqueue(String boardId) async {
    entries[boardId] = OutboxEntry(boardId: boardId); // reset attempts on a new change
  }

  @override
  Future<List<OutboxEntry>> pending() async => entries.values.toList();

  @override
  Future<void> markSynced(String boardId) async => entries.remove(boardId);

  @override
  Future<void> markFailed(String boardId, String error) async {
    final e = entries[boardId];
    if (e == null) return;
    entries[boardId] =
        OutboxEntry(boardId: boardId, attempts: e.attempts + 1, lastError: error);
  }

  @override
  Future<void> clear() async => entries.clear();
}

class FakeAuthService implements AuthService {
  String? uid;
  int ensureCalls = 0;

  FakeAuthService({this.uid});

  @override
  String? get currentUid => uid;

  @override
  Future<String?> ensureSignedIn() async {
    ensureCalls++;
    return uid;
  }
}

class RecordingProgressGateway implements ProgressGateway {
  final List<PushedProgress> pushes = [];
  bool throwOnPush = false;

  @override
  Future<void> pushBoardProgress({
    required String boardId,
    required BoardSpec spec,
    required String uid,
    required Map<int, bool> marks,
    required bool completed,
  }) async {
    if (throwOnPush) throw Exception('network down');
    pushes.add(PushedProgress(
      boardId: boardId,
      uid: uid,
      marks: Map.of(marks),
      completed: completed,
    ));
  }
}

class PushedProgress {
  final String boardId;
  final String uid;
  final Map<int, bool> marks;
  final bool completed;
  PushedProgress({
    required this.boardId,
    required this.uid,
    required this.marks,
    required this.completed,
  });
}

class FakeProgressReader implements ProgressReader {
  final Map<String, BoardProgress> boards = {};

  @override
  Future<BoardProgress?> readProgress(String boardId) async => boards[boardId];
}

BoardSpec fakeSpec({
  int size = 5,
  List<WinMode> winModes = const [WinMode.fullBoard],
}) =>
    BoardSpec(
      seed: 'SEED',
      size: size,
      catalogVersion: '2026.08.0',
      algoVersion: 1,
      configHash: 'cfg-1',
      winModes: winModes,
    );
