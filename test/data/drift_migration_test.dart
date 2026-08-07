import 'dart:io';

import 'package:carbingo/data/local/drift/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Migration safety (§11): upgrading must add the new table WITHOUT wiping user
/// progress. Builds a real schema-v1 database by hand, then opens [AppDatabase]
/// (schemaVersion 2) over it and asserts the upgrade ran correctly.
void main() {
  test('v1 -> v2 adds sync_outbox and preserves existing progress', () async {
    final dir = Directory.systemTemp.createTempSync('carbingo_mig');
    final path = '${dir.path}/app.sqlite';

    // 1. Hand-build a schema-v1 database (the four v1 tables + user_version = 1).
    final raw = sqlite3.open(path);
    raw.execute('''
      CREATE TABLE board_specs (
        board_id TEXT NOT NULL PRIMARY KEY, seed TEXT NOT NULL, size INTEGER NOT NULL,
        free_space INTEGER NOT NULL, catalog_version TEXT NOT NULL, algo_version INTEGER NOT NULL,
        config_hash TEXT NOT NULL, win_modes TEXT NOT NULL, mode TEXT NOT NULL, created_at INTEGER NOT NULL);
      CREATE TABLE board_layouts (
        board_id TEXT NOT NULL PRIMARY KEY, size INTEGER NOT NULL, cell_item_ids TEXT NOT NULL,
        generated_at INTEGER NOT NULL);
      CREATE TABLE player_marks (
        board_id TEXT NOT NULL, cell_index INTEGER NOT NULL, marked INTEGER NOT NULL,
        updated_at INTEGER NOT NULL, PRIMARY KEY (board_id, cell_index));
      CREATE TABLE app_meta (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL);
    ''');
    raw.execute(
        "INSERT INTO board_specs VALUES ('b1','SEED',5,1,'2026.08.0',1,'cfg','fullBoard','solo',1700000000)");
    raw.execute("INSERT INTO board_layouts VALUES ('b1',5,'[\"x\"]',1700000000)");
    raw.execute("INSERT INTO player_marks VALUES ('b1',0,1,1700000000)");
    raw.execute("INSERT INTO app_meta VALUES ('active_board_id','b1')");
    raw.execute('PRAGMA user_version = 1');
    raw.close();

    // 2. Open with drift -> triggers MigrationStrategy.onUpgrade(1 -> 2).
    final db = AppDatabase(NativeDatabase(File(path)));

    // 3. Existing progress survives the upgrade.
    final marks = await db.select(db.playerMarks).get();
    expect(marks, hasLength(1));
    expect(marks.single.boardId, 'b1');
    final specs = await db.select(db.boardSpecs).get();
    expect(specs.single.boardId, 'b1');

    // 4. The new sync_outbox table exists and is usable.
    final ts = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    await db.into(db.syncOutbox).insert(
          SyncOutboxCompanion.insert(boardId: 'b1', createdAt: ts, updatedAt: ts),
        );
    expect(await db.select(db.syncOutbox).get(), hasLength(1));

    await db.close();
    dir.deleteSync(recursive: true);
  });

  test('v2 -> v3 adds the revision column (default 0) without losing outbox rows',
      () async {
    final dir = Directory.systemTemp.createTempSync('carbingo_mig2');
    final path = '${dir.path}/app.sqlite';

    // Hand-build a schema-v2 database: the v1 tables + a sync_outbox WITHOUT the
    // revision column, user_version = 2, and one pending outbox row.
    final raw = sqlite3.open(path);
    raw.execute('''
      CREATE TABLE board_specs (
        board_id TEXT NOT NULL PRIMARY KEY, seed TEXT NOT NULL, size INTEGER NOT NULL,
        free_space INTEGER NOT NULL, catalog_version TEXT NOT NULL, algo_version INTEGER NOT NULL,
        config_hash TEXT NOT NULL, win_modes TEXT NOT NULL, mode TEXT NOT NULL, created_at INTEGER NOT NULL);
      CREATE TABLE board_layouts (
        board_id TEXT NOT NULL PRIMARY KEY, size INTEGER NOT NULL, cell_item_ids TEXT NOT NULL,
        generated_at INTEGER NOT NULL);
      CREATE TABLE player_marks (
        board_id TEXT NOT NULL, cell_index INTEGER NOT NULL, marked INTEGER NOT NULL,
        updated_at INTEGER NOT NULL, PRIMARY KEY (board_id, cell_index));
      CREATE TABLE app_meta (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL);
      CREATE TABLE sync_outbox (
        board_id TEXT NOT NULL PRIMARY KEY, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0, last_error TEXT);
    ''');
    raw.execute(
        "INSERT INTO sync_outbox (board_id, created_at, updated_at, attempts) VALUES ('b1',1700000000,1700000000,2)");
    raw.execute('PRAGMA user_version = 2');
    raw.close();

    // Open with drift -> triggers onUpgrade(2 -> 3) = addColumn(revision).
    final db = AppDatabase(NativeDatabase(File(path)));

    final rows = await db.select(db.syncOutbox).get();
    expect(rows, hasLength(1), reason: 'pending outbox row preserved');
    expect(rows.single.attempts, 2);
    expect(rows.single.revision, 0, reason: 'new column defaults to 0');

    await db.close();
    dir.deleteSync(recursive: true);
  });
}
