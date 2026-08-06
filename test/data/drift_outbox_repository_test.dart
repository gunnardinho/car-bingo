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

  test('enqueue creates a pending job; the same board coalesces to one', () async {
    await outbox.enqueue('b1');
    await outbox.enqueue('b1');
    await outbox.enqueue('b2');

    final pending = await outbox.pending();
    expect(pending.map((e) => e.boardId).toSet(), {'b1', 'b2'});
    expect(pending.where((e) => e.boardId == 'b1'), hasLength(1));
    expect(pending.every((e) => e.attempts == 0), isTrue);
  });

  test('markFailed bumps attempts and records the error', () async {
    await outbox.enqueue('b1');
    await outbox.markFailed('b1', 'boom');
    await outbox.markFailed('b1', 'boom again');

    final entry = (await outbox.pending()).single;
    expect(entry.attempts, 2);
    expect(entry.lastError, 'boom again');
  });

  test('a fresh enqueue after a failure resets the retry counters', () async {
    await outbox.enqueue('b1');
    await outbox.markFailed('b1', 'boom');
    await outbox.enqueue('b1'); // a new change supersedes prior failures

    final entry = (await outbox.pending()).single;
    expect(entry.attempts, 0);
    expect(entry.lastError, isNull);
  });

  test('markSynced removes the job; clear empties the queue', () async {
    await outbox.enqueue('b1');
    await outbox.enqueue('b2');

    await outbox.markSynced('b1');
    expect((await outbox.pending()).map((e) => e.boardId), ['b2']);

    await outbox.clear();
    expect(await outbox.pending(), isEmpty);
  });
}
