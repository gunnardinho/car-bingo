import 'package:carbingo/domain/sync/board_progress.dart';
import 'package:carbingo/domain/sync/sync_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_sync.dart';

void main() {
  late InMemoryOutboxRepository outbox;
  late FakeAuthService auth;
  late RecordingProgressGateway gateway;
  late FakeProgressReader reader;
  late SyncCoordinator coordinator;

  setUp(() {
    outbox = InMemoryOutboxRepository();
    auth = FakeAuthService(uid: 'user-1');
    gateway = RecordingProgressGateway();
    reader = FakeProgressReader();
    coordinator = SyncCoordinator(
      outbox: outbox,
      auth: auth,
      gateway: gateway,
      reader: reader,
    );
  });

  test('flushes a pending board to the gateway and clears the queue', () async {
    reader.boards['b1'] = BoardProgress(
      spec: fakeSpec(size: 5),
      marks: {0: true, 1: true, 2: false},
    );
    await outbox.enqueue('b1');

    await coordinator.flush();

    expect(gateway.pushes, hasLength(1));
    final push = gateway.pushes.single;
    expect(push.boardId, 'b1');
    expect(push.uid, 'user-1');
    expect(push.marks, {0: true, 1: true, 2: false},
        reason: 'un-marks are pushed as false, not omitted');
    expect(outbox.entries, isEmpty, reason: 'job acknowledged');
  });

  test('completed flag is derived from the board win rules', () async {
    // 3x3 full-board win: every non-free cell (free centre = 4) marked.
    reader.boards['win'] = BoardProgress(
      spec: fakeSpec(size: 3),
      marks: {for (final i in [0, 1, 2, 3, 5, 6, 7, 8]) i: true},
    );
    await outbox.enqueue('win');

    await coordinator.flush();

    expect(gateway.pushes.single.completed, isTrue);
  });

  test('offline (no uid) keeps everything queued and never calls the gateway',
      () async {
    auth.uid = null;
    reader.boards['b1'] = BoardProgress(spec: fakeSpec(), marks: {0: true});
    await outbox.enqueue('b1');

    await coordinator.flush();

    expect(gateway.pushes, isEmpty);
    expect(outbox.entries.keys, ['b1'], reason: 'progress stays durable, syncs later');
  });

  test('a failed push is retained and its retry counters bump', () async {
    gateway.throwOnPush = true;
    reader.boards['b1'] = BoardProgress(spec: fakeSpec(), marks: {0: true});
    await outbox.enqueue('b1');

    await coordinator.flush();

    expect(gateway.pushes, isEmpty);
    final entry = outbox.entries['b1'];
    expect(entry, isNotNull, reason: 'kept for retry');
    expect(entry!.attempts, 1);
    expect(entry.lastError, contains('network down'));
  });

  test('a stale job (board gone locally) is dropped, not pushed', () async {
    await outbox.enqueue('ghost'); // no reader entry for it

    await coordinator.flush();

    expect(gateway.pushes, isEmpty);
    expect(outbox.entries, isEmpty, reason: 'stale job removed');
  });

  test('does nothing (and does not sign in) when the queue is empty', () async {
    await coordinator.flush();
    expect(gateway.pushes, isEmpty);
    expect(auth.ensureCalls, 0, reason: 'no sign-in attempt with nothing to sync');
  });
}
