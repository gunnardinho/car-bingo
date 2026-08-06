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

/// On-device store (Drift/SQLite). Local source of truth for in-flight board
/// spec, layout, and progress until the Firestore outbox lands (§4). The outbox
/// and catalog tables from §5 are deferred to their own increments.
@DriftDatabase(tables: [BoardSpecs, BoardLayouts, PlayerMarks, AppMeta])
class AppDatabase extends _$AppDatabase {
  /// Test/DI seam: inject an executor (e.g. `NativeDatabase.memory()`).
  AppDatabase(super.executor);

  /// The app's on-disk database.
  AppDatabase.open() : super(driftDatabase(name: 'car_bingo'));

  @override
  int get schemaVersion => 1;
}
