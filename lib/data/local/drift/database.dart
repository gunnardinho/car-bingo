import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// The immutable board spec (ARCHITECTURE.md §5). `board_id` is the storage /
/// sharing key (Firestore doc id later); the five reproducibility fields plus
/// win modes are the shareable spec itself. Persisted so an in-flight board's
/// identity survives a restart.
@DataClassName('StoredBoardSpec')
class BoardSpecs extends Table {
  TextColumn get boardId => text()();
  TextColumn get seed => text()();
  IntColumn get size => integer()();
  BoolColumn get freeSpace => boolean()();
  TextColumn get catalogVersion => text()();
  IntColumn get algoVersion => integer()();
  TextColumn get configHash => text()();
  TextColumn get winModes => text()(); // CSV of WinMode.name
  TextColumn get mode => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {boardId};
}

/// The generated layout, AUTHORITATIVE once a board has progress (§4): a later
/// catalog change can never silently remap checked cells onto different items,
/// because the placed ids are frozen here rather than regenerated.
@DataClassName('StoredBoardLayout')
class BoardLayouts extends Table {
  TextColumn get boardId => text()();
  IntColumn get size => integer()();
  TextColumn get cellItemIds => text()(); // JSON array; null element = free cell
  DateTimeColumn get generatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {boardId};
}

/// Per-cell progress and the LOCAL SOURCE OF TRUTH for marks (§4). One row per
/// touched cell; an un-mark is stored as `marked = false`, never a row delete,
/// so a stale re-mark can't resurrect a cell once the Firestore outbox exists.
@DataClassName('StoredMark')
class PlayerMarks extends Table {
  TextColumn get boardId => text()();
  IntColumn get cellIndex => integer()();
  BoolColumn get marked => boolean()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {boardId, cellIndex};
}

/// Small key/value store for app-level pointers (e.g. the active board id).
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// One pending progress-sync job per board — the offline outbox (§4). The
/// flusher reads the board's current spec + marks from Drift at push time, so
/// repeated taps coalesce into this single row and always sync the latest state
/// (an un-mark is already a `marked = false` row, so the pushed map is complete).
/// Explicit ack/retry: on success the row is deleted; on failure `attempts` and
/// `lastError` bump so a rejected write is detectable and re-drivable, not
/// silently dropped.
@DataClassName('StoredOutboxEntry')
class SyncOutbox extends Table {
  TextColumn get boardId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  /// Monotonic per-board change counter, bumped on every enqueue. The flusher
  /// captures it before pushing and acks only the exact revision it sent, so a
  /// mark made mid-push (which bumps the revision) is never acked away.
  IntColumn get revision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {boardId};
}

/// On-device store (Drift/SQLite). Local source of truth for in-flight board
/// spec, layout, progress, and the progress-sync outbox (§4). The catalog
/// tables from §5 remain deferred to their own increment.
@DriftDatabase(tables: [BoardSpecs, BoardLayouts, PlayerMarks, AppMeta, SyncOutbox])
class AppDatabase extends _$AppDatabase {
  /// Test/DI seam: inject an executor (e.g. `NativeDatabase.memory()`).
  AppDatabase(super.executor);

  /// The app's on-disk database.
  AppDatabase.open() : super(driftDatabase(name: 'car_bingo'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // Additive only; existing progress is never wiped on upgrade (§11).
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(syncOutbox); // fresh table has revision
          // Only pre-v3 tables (created without it) need the column added.
          if (from >= 2 && from < 3) {
            await m.addColumn(syncOutbox, syncOutbox.revision);
          }
        },
      );
}
