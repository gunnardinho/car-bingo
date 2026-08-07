import 'package:carbingo/data/local/drift/database.dart';
import 'package:carbingo/data/repositories/drift_outbox_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftOutboxRepository outbox;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    outbox = DriftOutboxRepository(db);
  });
  tearDown(() => db.close());

  Future<int> revisionOf(String boardId) async =>
      (await outbox.pending()).firstWhere((e) => e.boardId == boardId).revision;

  test('enqueue coalesces to one row per board and bumps revision', () async {
    await outbox.enqueue('b1');
    await outbox.enqueue('b1');
    await outbox.enqueue('b2');

    final pending = await outbox.pending();
    expect(pending.map((e) => e.boardId).toSet(), {'b1', 'b2'});
    expect(pending.where((e) => e.boardId == 'b1'), hasLength(1));
    expect(await revisionOf('b1'), 2, reason: 're-enqueue bumps revision');
    expect(await revisionOf('b2'), 1);
    expect(pending.every((e) => e.attempts == 0), isTrue);
  });

  test('markFailed bumps attempts and records the error', () async {
    await outbox.enqueue('b1');
    final rev = await revisionOf('b1');
    await outbox.markFailed('b1', rev, 'boom');
    await outbox.markFailed('b1', rev, 'boom again');

    final entry = (await outbox.pending()).single;
    expect(entry.attempts, 2);
    expect(entry.lastError, 'boom again');
  });

  test('a fresh enqueue resets the retry counters and supersedes the revision',
      () async {
    await outbox.enqueue('b1');
    await outbox.markFailed('b1', await revisionOf('b1'), 'boom');
    await outbox.enqueue('b1'); // a new change supersedes prior failures

    final entry = (await outbox.pending()).single;
    expect(entry.attempts, 0);
    expect(entry.lastError, isNull);
    expect(entry.revision, 2);
  });

  test('ack is a no-op against a stale revision (mid-push safety)', () async {
    await outbox.enqueue('b1'); // revision 1
    await outbox.enqueue('b1'); // revision 2 — a change arrived mid-push

    await outbox.markSynced('b1', 1); // ack of the revision that was pushed
    expect(await outbox.pending(), hasLength(1),
        reason: 'the rev-2 job survives a stale ack');

    await outbox.markFailed('b1', 1, 'late'); // stale failure ignored too
    expect((await outbox.pending()).single.attempts, 0);

    await outbox.markSynced('b1', 2); // ack of the current revision clears it
    expect(await outbox.pending(), isEmpty);
  });

  test('markSynced removes the current job; clear empties the queue', () async {
    await outbox.enqueue('b1');
    await outbox.enqueue('b2');

    await outbox.markSynced('b1', await revisionOf('b1'));
    expect((await outbox.pending()).map((e) => e.boardId), ['b2']);

    await outbox.clear();
    expect(await outbox.pending(), isEmpty);
  });
}
