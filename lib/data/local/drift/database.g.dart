// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BoardSpecsTable extends BoardSpecs
    with TableInfo<$BoardSpecsTable, StoredBoardSpec> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardSpecsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<String> seed = GeneratedColumn<String>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _freeSpaceMeta = const VerificationMeta(
    'freeSpace',
  );
  @override
  late final GeneratedColumn<bool> freeSpace = GeneratedColumn<bool>(
    'free_space',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("free_space" IN (0, 1))',
    ),
  );
  static const VerificationMeta _catalogVersionMeta = const VerificationMeta(
    'catalogVersion',
  );
  @override
  late final GeneratedColumn<String> catalogVersion = GeneratedColumn<String>(
    'catalog_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _algoVersionMeta = const VerificationMeta(
    'algoVersion',
  );
  @override
  late final GeneratedColumn<int> algoVersion = GeneratedColumn<int>(
    'algo_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configHashMeta = const VerificationMeta(
    'configHash',
  );
  @override
  late final GeneratedColumn<String> configHash = GeneratedColumn<String>(
    'config_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winModesMeta = const VerificationMeta(
    'winModes',
  );
  @override
  late final GeneratedColumn<String> winModes = GeneratedColumn<String>(
    'win_modes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    boardId,
    seed,
    size,
    freeSpace,
    catalogVersion,
    algoVersion,
    configHash,
    winModes,
    mode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'board_specs';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredBoardSpec> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('free_space')) {
      context.handle(
        _freeSpaceMeta,
        freeSpace.isAcceptableOrUnknown(data['free_space']!, _freeSpaceMeta),
      );
    } else if (isInserting) {
      context.missing(_freeSpaceMeta);
    }
    if (data.containsKey('catalog_version')) {
      context.handle(
        _catalogVersionMeta,
        catalogVersion.isAcceptableOrUnknown(
          data['catalog_version']!,
          _catalogVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_catalogVersionMeta);
    }
    if (data.containsKey('algo_version')) {
      context.handle(
        _algoVersionMeta,
        algoVersion.isAcceptableOrUnknown(
          data['algo_version']!,
          _algoVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_algoVersionMeta);
    }
    if (data.containsKey('config_hash')) {
      context.handle(
        _configHashMeta,
        configHash.isAcceptableOrUnknown(data['config_hash']!, _configHashMeta),
      );
    } else if (isInserting) {
      context.missing(_configHashMeta);
    }
    if (data.containsKey('win_modes')) {
      context.handle(
        _winModesMeta,
        winModes.isAcceptableOrUnknown(data['win_modes']!, _winModesMeta),
      );
    } else if (isInserting) {
      context.missing(_winModesMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {boardId};
  @override
  StoredBoardSpec map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredBoardSpec(
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_id'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seed'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      freeSpace: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}free_space'],
      )!,
      catalogVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_version'],
      )!,
      algoVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}algo_version'],
      )!,
      configHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_hash'],
      )!,
      winModes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}win_modes'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BoardSpecsTable createAlias(String alias) {
    return $BoardSpecsTable(attachedDatabase, alias);
  }
}

class StoredBoardSpec extends DataClass implements Insertable<StoredBoardSpec> {
  final String boardId;
  final String seed;
  final int size;
  final bool freeSpace;
  final String catalogVersion;
  final int algoVersion;
  final String configHash;
  final String winModes;
  final String mode;
  final DateTime createdAt;
  const StoredBoardSpec({
    required this.boardId,
    required this.seed,
    required this.size,
    required this.freeSpace,
    required this.catalogVersion,
    required this.algoVersion,
    required this.configHash,
    required this.winModes,
    required this.mode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['board_id'] = Variable<String>(boardId);
    map['seed'] = Variable<String>(seed);
    map['size'] = Variable<int>(size);
    map['free_space'] = Variable<bool>(freeSpace);
    map['catalog_version'] = Variable<String>(catalogVersion);
    map['algo_version'] = Variable<int>(algoVersion);
    map['config_hash'] = Variable<String>(configHash);
    map['win_modes'] = Variable<String>(winModes);
    map['mode'] = Variable<String>(mode);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BoardSpecsCompanion toCompanion(bool nullToAbsent) {
    return BoardSpecsCompanion(
      boardId: Value(boardId),
      seed: Value(seed),
      size: Value(size),
      freeSpace: Value(freeSpace),
      catalogVersion: Value(catalogVersion),
      algoVersion: Value(algoVersion),
      configHash: Value(configHash),
      winModes: Value(winModes),
      mode: Value(mode),
      createdAt: Value(createdAt),
    );
  }

  factory StoredBoardSpec.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredBoardSpec(
      boardId: serializer.fromJson<String>(json['boardId']),
      seed: serializer.fromJson<String>(json['seed']),
      size: serializer.fromJson<int>(json['size']),
      freeSpace: serializer.fromJson<bool>(json['freeSpace']),
      catalogVersion: serializer.fromJson<String>(json['catalogVersion']),
      algoVersion: serializer.fromJson<int>(json['algoVersion']),
      configHash: serializer.fromJson<String>(json['configHash']),
      winModes: serializer.fromJson<String>(json['winModes']),
      mode: serializer.fromJson<String>(json['mode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'boardId': serializer.toJson<String>(boardId),
      'seed': serializer.toJson<String>(seed),
      'size': serializer.toJson<int>(size),
      'freeSpace': serializer.toJson<bool>(freeSpace),
      'catalogVersion': serializer.toJson<String>(catalogVersion),
      'algoVersion': serializer.toJson<int>(algoVersion),
      'configHash': serializer.toJson<String>(configHash),
      'winModes': serializer.toJson<String>(winModes),
      'mode': serializer.toJson<String>(mode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StoredBoardSpec copyWith({
    String? boardId,
    String? seed,
    int? size,
    bool? freeSpace,
    String? catalogVersion,
    int? algoVersion,
    String? configHash,
    String? winModes,
    String? mode,
    DateTime? createdAt,
  }) => StoredBoardSpec(
    boardId: boardId ?? this.boardId,
    seed: seed ?? this.seed,
    size: size ?? this.size,
    freeSpace: freeSpace ?? this.freeSpace,
    catalogVersion: catalogVersion ?? this.catalogVersion,
    algoVersion: algoVersion ?? this.algoVersion,
    configHash: configHash ?? this.configHash,
    winModes: winModes ?? this.winModes,
    mode: mode ?? this.mode,
    createdAt: createdAt ?? this.createdAt,
  );
  StoredBoardSpec copyWithCompanion(BoardSpecsCompanion data) {
    return StoredBoardSpec(
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      seed: data.seed.present ? data.seed.value : this.seed,
      size: data.size.present ? data.size.value : this.size,
      freeSpace: data.freeSpace.present ? data.freeSpace.value : this.freeSpace,
      catalogVersion: data.catalogVersion.present
          ? data.catalogVersion.value
          : this.catalogVersion,
      algoVersion: data.algoVersion.present
          ? data.algoVersion.value
          : this.algoVersion,
      configHash: data.configHash.present
          ? data.configHash.value
          : this.configHash,
      winModes: data.winModes.present ? data.winModes.value : this.winModes,
      mode: data.mode.present ? data.mode.value : this.mode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredBoardSpec(')
          ..write('boardId: $boardId, ')
          ..write('seed: $seed, ')
          ..write('size: $size, ')
          ..write('freeSpace: $freeSpace, ')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('algoVersion: $algoVersion, ')
          ..write('configHash: $configHash, ')
          ..write('winModes: $winModes, ')
          ..write('mode: $mode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    boardId,
    seed,
    size,
    freeSpace,
    catalogVersion,
    algoVersion,
    configHash,
    winModes,
    mode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredBoardSpec &&
          other.boardId == this.boardId &&
          other.seed == this.seed &&
          other.size == this.size &&
          other.freeSpace == this.freeSpace &&
          other.catalogVersion == this.catalogVersion &&
          other.algoVersion == this.algoVersion &&
          other.configHash == this.configHash &&
          other.winModes == this.winModes &&
          other.mode == this.mode &&
          other.createdAt == this.createdAt);
}

class BoardSpecsCompanion extends UpdateCompanion<StoredBoardSpec> {
  final Value<String> boardId;
  final Value<String> seed;
  final Value<int> size;
  final Value<bool> freeSpace;
  final Value<String> catalogVersion;
  final Value<int> algoVersion;
  final Value<String> configHash;
  final Value<String> winModes;
  final Value<String> mode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BoardSpecsCompanion({
    this.boardId = const Value.absent(),
    this.seed = const Value.absent(),
    this.size = const Value.absent(),
    this.freeSpace = const Value.absent(),
    this.catalogVersion = const Value.absent(),
    this.algoVersion = const Value.absent(),
    this.configHash = const Value.absent(),
    this.winModes = const Value.absent(),
    this.mode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BoardSpecsCompanion.insert({
    required String boardId,
    required String seed,
    required int size,
    required bool freeSpace,
    required String catalogVersion,
    required int algoVersion,
    required String configHash,
    required String winModes,
    required String mode,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : boardId = Value(boardId),
       seed = Value(seed),
       size = Value(size),
       freeSpace = Value(freeSpace),
       catalogVersion = Value(catalogVersion),
       algoVersion = Value(algoVersion),
       configHash = Value(configHash),
       winModes = Value(winModes),
       mode = Value(mode),
       createdAt = Value(createdAt);
  static Insertable<StoredBoardSpec> custom({
    Expression<String>? boardId,
    Expression<String>? seed,
    Expression<int>? size,
    Expression<bool>? freeSpace,
    Expression<String>? catalogVersion,
    Expression<int>? algoVersion,
    Expression<String>? configHash,
    Expression<String>? winModes,
    Expression<String>? mode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (boardId != null) 'board_id': boardId,
      if (seed != null) 'seed': seed,
      if (size != null) 'size': size,
      if (freeSpace != null) 'free_space': freeSpace,
      if (catalogVersion != null) 'catalog_version': catalogVersion,
      if (algoVersion != null) 'algo_version': algoVersion,
      if (configHash != null) 'config_hash': configHash,
      if (winModes != null) 'win_modes': winModes,
      if (mode != null) 'mode': mode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BoardSpecsCompanion copyWith({
    Value<String>? boardId,
    Value<String>? seed,
    Value<int>? size,
    Value<bool>? freeSpace,
    Value<String>? catalogVersion,
    Value<int>? algoVersion,
    Value<String>? configHash,
    Value<String>? winModes,
    Value<String>? mode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BoardSpecsCompanion(
      boardId: boardId ?? this.boardId,
      seed: seed ?? this.seed,
      size: size ?? this.size,
      freeSpace: freeSpace ?? this.freeSpace,
      catalogVersion: catalogVersion ?? this.catalogVersion,
      algoVersion: algoVersion ?? this.algoVersion,
      configHash: configHash ?? this.configHash,
      winModes: winModes ?? this.winModes,
      mode: mode ?? this.mode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (boardId.present) {
      map['board_id'] = Variable<String>(boardId.value);
    }
    if (seed.present) {
      map['seed'] = Variable<String>(seed.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (freeSpace.present) {
      map['free_space'] = Variable<bool>(freeSpace.value);
    }
    if (catalogVersion.present) {
      map['catalog_version'] = Variable<String>(catalogVersion.value);
    }
    if (algoVersion.present) {
      map['algo_version'] = Variable<int>(algoVersion.value);
    }
    if (configHash.present) {
      map['config_hash'] = Variable<String>(configHash.value);
    }
    if (winModes.present) {
      map['win_modes'] = Variable<String>(winModes.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardSpecsCompanion(')
          ..write('boardId: $boardId, ')
          ..write('seed: $seed, ')
          ..write('size: $size, ')
          ..write('freeSpace: $freeSpace, ')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('algoVersion: $algoVersion, ')
          ..write('configHash: $configHash, ')
          ..write('winModes: $winModes, ')
          ..write('mode: $mode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BoardLayoutsTable extends BoardLayouts
    with TableInfo<$BoardLayoutsTable, StoredBoardLayout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardLayoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cellItemIdsMeta = const VerificationMeta(
    'cellItemIds',
  );
  @override
  late final GeneratedColumn<String> cellItemIds = GeneratedColumn<String>(
    'cell_item_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    boardId,
    size,
    cellItemIds,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'board_layouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredBoardLayout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('cell_item_ids')) {
      context.handle(
        _cellItemIdsMeta,
        cellItemIds.isAcceptableOrUnknown(
          data['cell_item_ids']!,
          _cellItemIdsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cellItemIdsMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {boardId};
  @override
  StoredBoardLayout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredBoardLayout(
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_id'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      cellItemIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cell_item_ids'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $BoardLayoutsTable createAlias(String alias) {
    return $BoardLayoutsTable(attachedDatabase, alias);
  }
}

class StoredBoardLayout extends DataClass
    implements Insertable<StoredBoardLayout> {
  final String boardId;
  final int size;
  final String cellItemIds;
  final DateTime generatedAt;
  const StoredBoardLayout({
    required this.boardId,
    required this.size,
    required this.cellItemIds,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['board_id'] = Variable<String>(boardId);
    map['size'] = Variable<int>(size);
    map['cell_item_ids'] = Variable<String>(cellItemIds);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  BoardLayoutsCompanion toCompanion(bool nullToAbsent) {
    return BoardLayoutsCompanion(
      boardId: Value(boardId),
      size: Value(size),
      cellItemIds: Value(cellItemIds),
      generatedAt: Value(generatedAt),
    );
  }

  factory StoredBoardLayout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredBoardLayout(
      boardId: serializer.fromJson<String>(json['boardId']),
      size: serializer.fromJson<int>(json['size']),
      cellItemIds: serializer.fromJson<String>(json['cellItemIds']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'boardId': serializer.toJson<String>(boardId),
      'size': serializer.toJson<int>(size),
      'cellItemIds': serializer.toJson<String>(cellItemIds),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  StoredBoardLayout copyWith({
    String? boardId,
    int? size,
    String? cellItemIds,
    DateTime? generatedAt,
  }) => StoredBoardLayout(
    boardId: boardId ?? this.boardId,
    size: size ?? this.size,
    cellItemIds: cellItemIds ?? this.cellItemIds,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  StoredBoardLayout copyWithCompanion(BoardLayoutsCompanion data) {
    return StoredBoardLayout(
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      size: data.size.present ? data.size.value : this.size,
      cellItemIds: data.cellItemIds.present
          ? data.cellItemIds.value
          : this.cellItemIds,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredBoardLayout(')
          ..write('boardId: $boardId, ')
          ..write('size: $size, ')
          ..write('cellItemIds: $cellItemIds, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(boardId, size, cellItemIds, generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredBoardLayout &&
          other.boardId == this.boardId &&
          other.size == this.size &&
          other.cellItemIds == this.cellItemIds &&
          other.generatedAt == this.generatedAt);
}

class BoardLayoutsCompanion extends UpdateCompanion<StoredBoardLayout> {
  final Value<String> boardId;
  final Value<int> size;
  final Value<String> cellItemIds;
  final Value<DateTime> generatedAt;
  final Value<int> rowid;
  const BoardLayoutsCompanion({
    this.boardId = const Value.absent(),
    this.size = const Value.absent(),
    this.cellItemIds = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BoardLayoutsCompanion.insert({
    required String boardId,
    required int size,
    required String cellItemIds,
    required DateTime generatedAt,
    this.rowid = const Value.absent(),
  }) : boardId = Value(boardId),
       size = Value(size),
       cellItemIds = Value(cellItemIds),
       generatedAt = Value(generatedAt);
  static Insertable<StoredBoardLayout> custom({
    Expression<String>? boardId,
    Expression<int>? size,
    Expression<String>? cellItemIds,
    Expression<DateTime>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (boardId != null) 'board_id': boardId,
      if (size != null) 'size': size,
      if (cellItemIds != null) 'cell_item_ids': cellItemIds,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BoardLayoutsCompanion copyWith({
    Value<String>? boardId,
    Value<int>? size,
    Value<String>? cellItemIds,
    Value<DateTime>? generatedAt,
    Value<int>? rowid,
  }) {
    return BoardLayoutsCompanion(
      boardId: boardId ?? this.boardId,
      size: size ?? this.size,
      cellItemIds: cellItemIds ?? this.cellItemIds,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (boardId.present) {
      map['board_id'] = Variable<String>(boardId.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (cellItemIds.present) {
      map['cell_item_ids'] = Variable<String>(cellItemIds.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardLayoutsCompanion(')
          ..write('boardId: $boardId, ')
          ..write('size: $size, ')
          ..write('cellItemIds: $cellItemIds, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerMarksTable extends PlayerMarks
    with TableInfo<$PlayerMarksTable, StoredMark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cellIndexMeta = const VerificationMeta(
    'cellIndex',
  );
  @override
  late final GeneratedColumn<int> cellIndex = GeneratedColumn<int>(
    'cell_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markedMeta = const VerificationMeta('marked');
  @override
  late final GeneratedColumn<bool> marked = GeneratedColumn<bool>(
    'marked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("marked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [boardId, cellIndex, marked, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_marks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredMark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('cell_index')) {
      context.handle(
        _cellIndexMeta,
        cellIndex.isAcceptableOrUnknown(data['cell_index']!, _cellIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_cellIndexMeta);
    }
    if (data.containsKey('marked')) {
      context.handle(
        _markedMeta,
        marked.isAcceptableOrUnknown(data['marked']!, _markedMeta),
      );
    } else if (isInserting) {
      context.missing(_markedMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {boardId, cellIndex};
  @override
  StoredMark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredMark(
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_id'],
      )!,
      cellIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cell_index'],
      )!,
      marked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}marked'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlayerMarksTable createAlias(String alias) {
    return $PlayerMarksTable(attachedDatabase, alias);
  }
}

class StoredMark extends DataClass implements Insertable<StoredMark> {
  final String boardId;
  final int cellIndex;
  final bool marked;
  final DateTime updatedAt;
  const StoredMark({
    required this.boardId,
    required this.cellIndex,
    required this.marked,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['board_id'] = Variable<String>(boardId);
    map['cell_index'] = Variable<int>(cellIndex);
    map['marked'] = Variable<bool>(marked);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlayerMarksCompanion toCompanion(bool nullToAbsent) {
    return PlayerMarksCompanion(
      boardId: Value(boardId),
      cellIndex: Value(cellIndex),
      marked: Value(marked),
      updatedAt: Value(updatedAt),
    );
  }

  factory StoredMark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredMark(
      boardId: serializer.fromJson<String>(json['boardId']),
      cellIndex: serializer.fromJson<int>(json['cellIndex']),
      marked: serializer.fromJson<bool>(json['marked']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'boardId': serializer.toJson<String>(boardId),
      'cellIndex': serializer.toJson<int>(cellIndex),
      'marked': serializer.toJson<bool>(marked),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StoredMark copyWith({
    String? boardId,
    int? cellIndex,
    bool? marked,
    DateTime? updatedAt,
  }) => StoredMark(
    boardId: boardId ?? this.boardId,
    cellIndex: cellIndex ?? this.cellIndex,
    marked: marked ?? this.marked,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StoredMark copyWithCompanion(PlayerMarksCompanion data) {
    return StoredMark(
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      cellIndex: data.cellIndex.present ? data.cellIndex.value : this.cellIndex,
      marked: data.marked.present ? data.marked.value : this.marked,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredMark(')
          ..write('boardId: $boardId, ')
          ..write('cellIndex: $cellIndex, ')
          ..write('marked: $marked, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(boardId, cellIndex, marked, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredMark &&
          other.boardId == this.boardId &&
          other.cellIndex == this.cellIndex &&
          other.marked == this.marked &&
          other.updatedAt == this.updatedAt);
}

class PlayerMarksCompanion extends UpdateCompanion<StoredMark> {
  final Value<String> boardId;
  final Value<int> cellIndex;
  final Value<bool> marked;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlayerMarksCompanion({
    this.boardId = const Value.absent(),
    this.cellIndex = const Value.absent(),
    this.marked = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerMarksCompanion.insert({
    required String boardId,
    required int cellIndex,
    required bool marked,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : boardId = Value(boardId),
       cellIndex = Value(cellIndex),
       marked = Value(marked),
       updatedAt = Value(updatedAt);
  static Insertable<StoredMark> custom({
    Expression<String>? boardId,
    Expression<int>? cellIndex,
    Expression<bool>? marked,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (boardId != null) 'board_id': boardId,
      if (cellIndex != null) 'cell_index': cellIndex,
      if (marked != null) 'marked': marked,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerMarksCompanion copyWith({
    Value<String>? boardId,
    Value<int>? cellIndex,
    Value<bool>? marked,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlayerMarksCompanion(
      boardId: boardId ?? this.boardId,
      cellIndex: cellIndex ?? this.cellIndex,
      marked: marked ?? this.marked,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (boardId.present) {
      map['board_id'] = Variable<String>(boardId.value);
    }
    if (cellIndex.present) {
      map['cell_index'] = Variable<int>(cellIndex.value);
    }
    if (marked.present) {
      map['marked'] = Variable<bool>(marked.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerMarksCompanion(')
          ..write('boardId: $boardId, ')
          ..write('cellIndex: $cellIndex, ')
          ..write('marked: $marked, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  final String key;
  final String value;
  const AppMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaRow copyWith({String? key, String? value}) =>
      AppMetaRow(key: key ?? this.key, value: value ?? this.value);
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, StoredOutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<String> boardId = GeneratedColumn<String>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    boardId,
    createdAt,
    updatedAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredOutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {boardId};
  @override
  StoredOutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredOutboxEntry(
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class StoredOutboxEntry extends DataClass
    implements Insertable<StoredOutboxEntry> {
  final String boardId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int attempts;
  final String? lastError;
  const StoredOutboxEntry({
    required this.boardId,
    required this.createdAt,
    required this.updatedAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['board_id'] = Variable<String>(boardId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      boardId: Value(boardId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory StoredOutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredOutboxEntry(
      boardId: serializer.fromJson<String>(json['boardId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'boardId': serializer.toJson<String>(boardId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  StoredOutboxEntry copyWith({
    String? boardId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => StoredOutboxEntry(
    boardId: boardId ?? this.boardId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  StoredOutboxEntry copyWithCompanion(SyncOutboxCompanion data) {
    return StoredOutboxEntry(
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredOutboxEntry(')
          ..write('boardId: $boardId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(boardId, createdAt, updatedAt, attempts, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredOutboxEntry &&
          other.boardId == this.boardId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class SyncOutboxCompanion extends UpdateCompanion<StoredOutboxEntry> {
  final Value<String> boardId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.boardId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String boardId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : boardId = Value(boardId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StoredOutboxEntry> custom({
    Expression<String>? boardId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (boardId != null) 'board_id': boardId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? boardId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      boardId: boardId ?? this.boardId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (boardId.present) {
      map['board_id'] = Variable<String>(boardId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('boardId: $boardId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BoardSpecsTable boardSpecs = $BoardSpecsTable(this);
  late final $BoardLayoutsTable boardLayouts = $BoardLayoutsTable(this);
  late final $PlayerMarksTable playerMarks = $PlayerMarksTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    boardSpecs,
    boardLayouts,
    playerMarks,
    appMeta,
    syncOutbox,
  ];
}

typedef $$BoardSpecsTableCreateCompanionBuilder =
    BoardSpecsCompanion Function({
      required String boardId,
      required String seed,
      required int size,
      required bool freeSpace,
      required String catalogVersion,
      required int algoVersion,
      required String configHash,
      required String winModes,
      required String mode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BoardSpecsTableUpdateCompanionBuilder =
    BoardSpecsCompanion Function({
      Value<String> boardId,
      Value<String> seed,
      Value<int> size,
      Value<bool> freeSpace,
      Value<String> catalogVersion,
      Value<int> algoVersion,
      Value<String> configHash,
      Value<String> winModes,
      Value<String> mode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BoardSpecsTableFilterComposer
    extends Composer<_$AppDatabase, $BoardSpecsTable> {
  $$BoardSpecsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get freeSpace => $composableBuilder(
    column: $table.freeSpace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get algoVersion => $composableBuilder(
    column: $table.algoVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configHash => $composableBuilder(
    column: $table.configHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winModes => $composableBuilder(
    column: $table.winModes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BoardSpecsTableOrderingComposer
    extends Composer<_$AppDatabase, $BoardSpecsTable> {
  $$BoardSpecsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get freeSpace => $composableBuilder(
    column: $table.freeSpace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get algoVersion => $composableBuilder(
    column: $table.algoVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configHash => $composableBuilder(
    column: $table.configHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winModes => $composableBuilder(
    column: $table.winModes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoardSpecsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoardSpecsTable> {
  $$BoardSpecsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get boardId =>
      $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<String> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<bool> get freeSpace =>
      $composableBuilder(column: $table.freeSpace, builder: (column) => column);

  GeneratedColumn<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get algoVersion => $composableBuilder(
    column: $table.algoVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configHash => $composableBuilder(
    column: $table.configHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get winModes =>
      $composableBuilder(column: $table.winModes, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BoardSpecsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoardSpecsTable,
          StoredBoardSpec,
          $$BoardSpecsTableFilterComposer,
          $$BoardSpecsTableOrderingComposer,
          $$BoardSpecsTableAnnotationComposer,
          $$BoardSpecsTableCreateCompanionBuilder,
          $$BoardSpecsTableUpdateCompanionBuilder,
          (
            StoredBoardSpec,
            BaseReferences<_$AppDatabase, $BoardSpecsTable, StoredBoardSpec>,
          ),
          StoredBoardSpec,
          PrefetchHooks Function()
        > {
  $$BoardSpecsTableTableManager(_$AppDatabase db, $BoardSpecsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoardSpecsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoardSpecsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoardSpecsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> boardId = const Value.absent(),
                Value<String> seed = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<bool> freeSpace = const Value.absent(),
                Value<String> catalogVersion = const Value.absent(),
                Value<int> algoVersion = const Value.absent(),
                Value<String> configHash = const Value.absent(),
                Value<String> winModes = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BoardSpecsCompanion(
                boardId: boardId,
                seed: seed,
                size: size,
                freeSpace: freeSpace,
                catalogVersion: catalogVersion,
                algoVersion: algoVersion,
                configHash: configHash,
                winModes: winModes,
                mode: mode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String boardId,
                required String seed,
                required int size,
                required bool freeSpace,
                required String catalogVersion,
                required int algoVersion,
                required String configHash,
                required String winModes,
                required String mode,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BoardSpecsCompanion.insert(
                boardId: boardId,
                seed: seed,
                size: size,
                freeSpace: freeSpace,
                catalogVersion: catalogVersion,
                algoVersion: algoVersion,
                configHash: configHash,
                winModes: winModes,
                mode: mode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BoardSpecsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoardSpecsTable,
      StoredBoardSpec,
      $$BoardSpecsTableFilterComposer,
      $$BoardSpecsTableOrderingComposer,
      $$BoardSpecsTableAnnotationComposer,
      $$BoardSpecsTableCreateCompanionBuilder,
      $$BoardSpecsTableUpdateCompanionBuilder,
      (
        StoredBoardSpec,
        BaseReferences<_$AppDatabase, $BoardSpecsTable, StoredBoardSpec>,
      ),
      StoredBoardSpec,
      PrefetchHooks Function()
    >;
typedef $$BoardLayoutsTableCreateCompanionBuilder =
    BoardLayoutsCompanion Function({
      required String boardId,
      required int size,
      required String cellItemIds,
      required DateTime generatedAt,
      Value<int> rowid,
    });
typedef $$BoardLayoutsTableUpdateCompanionBuilder =
    BoardLayoutsCompanion Function({
      Value<String> boardId,
      Value<int> size,
      Value<String> cellItemIds,
      Value<DateTime> generatedAt,
      Value<int> rowid,
    });

class $$BoardLayoutsTableFilterComposer
    extends Composer<_$AppDatabase, $BoardLayoutsTable> {
  $$BoardLayoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cellItemIds => $composableBuilder(
    column: $table.cellItemIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BoardLayoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $BoardLayoutsTable> {
  $$BoardLayoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cellItemIds => $composableBuilder(
    column: $table.cellItemIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoardLayoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoardLayoutsTable> {
  $$BoardLayoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get boardId =>
      $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get cellItemIds => $composableBuilder(
    column: $table.cellItemIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );
}

class $$BoardLayoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoardLayoutsTable,
          StoredBoardLayout,
          $$BoardLayoutsTableFilterComposer,
          $$BoardLayoutsTableOrderingComposer,
          $$BoardLayoutsTableAnnotationComposer,
          $$BoardLayoutsTableCreateCompanionBuilder,
          $$BoardLayoutsTableUpdateCompanionBuilder,
          (
            StoredBoardLayout,
            BaseReferences<
              _$AppDatabase,
              $BoardLayoutsTable,
              StoredBoardLayout
            >,
          ),
          StoredBoardLayout,
          PrefetchHooks Function()
        > {
  $$BoardLayoutsTableTableManager(_$AppDatabase db, $BoardLayoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoardLayoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoardLayoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoardLayoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> boardId = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<String> cellItemIds = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BoardLayoutsCompanion(
                boardId: boardId,
                size: size,
                cellItemIds: cellItemIds,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String boardId,
                required int size,
                required String cellItemIds,
                required DateTime generatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BoardLayoutsCompanion.insert(
                boardId: boardId,
                size: size,
                cellItemIds: cellItemIds,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BoardLayoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoardLayoutsTable,
      StoredBoardLayout,
      $$BoardLayoutsTableFilterComposer,
      $$BoardLayoutsTableOrderingComposer,
      $$BoardLayoutsTableAnnotationComposer,
      $$BoardLayoutsTableCreateCompanionBuilder,
      $$BoardLayoutsTableUpdateCompanionBuilder,
      (
        StoredBoardLayout,
        BaseReferences<_$AppDatabase, $BoardLayoutsTable, StoredBoardLayout>,
      ),
      StoredBoardLayout,
      PrefetchHooks Function()
    >;
typedef $$PlayerMarksTableCreateCompanionBuilder =
    PlayerMarksCompanion Function({
      required String boardId,
      required int cellIndex,
      required bool marked,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PlayerMarksTableUpdateCompanionBuilder =
    PlayerMarksCompanion Function({
      Value<String> boardId,
      Value<int> cellIndex,
      Value<bool> marked,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PlayerMarksTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerMarksTable> {
  $$PlayerMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cellIndex => $composableBuilder(
    column: $table.cellIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get marked => $composableBuilder(
    column: $table.marked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerMarksTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerMarksTable> {
  $$PlayerMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cellIndex => $composableBuilder(
    column: $table.cellIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get marked => $composableBuilder(
    column: $table.marked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerMarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerMarksTable> {
  $$PlayerMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get boardId =>
      $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<int> get cellIndex =>
      $composableBuilder(column: $table.cellIndex, builder: (column) => column);

  GeneratedColumn<bool> get marked =>
      $composableBuilder(column: $table.marked, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlayerMarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerMarksTable,
          StoredMark,
          $$PlayerMarksTableFilterComposer,
          $$PlayerMarksTableOrderingComposer,
          $$PlayerMarksTableAnnotationComposer,
          $$PlayerMarksTableCreateCompanionBuilder,
          $$PlayerMarksTableUpdateCompanionBuilder,
          (
            StoredMark,
            BaseReferences<_$AppDatabase, $PlayerMarksTable, StoredMark>,
          ),
          StoredMark,
          PrefetchHooks Function()
        > {
  $$PlayerMarksTableTableManager(_$AppDatabase db, $PlayerMarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> boardId = const Value.absent(),
                Value<int> cellIndex = const Value.absent(),
                Value<bool> marked = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerMarksCompanion(
                boardId: boardId,
                cellIndex: cellIndex,
                marked: marked,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String boardId,
                required int cellIndex,
                required bool marked,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlayerMarksCompanion.insert(
                boardId: boardId,
                cellIndex: cellIndex,
                marked: marked,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerMarksTable,
      StoredMark,
      $$PlayerMarksTableFilterComposer,
      $$PlayerMarksTableOrderingComposer,
      $$PlayerMarksTableAnnotationComposer,
      $$PlayerMarksTableCreateCompanionBuilder,
      $$PlayerMarksTableUpdateCompanionBuilder,
      (
        StoredMark,
        BaseReferences<_$AppDatabase, $PlayerMarksTable, StoredMark>,
      ),
      StoredMark,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaRow,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaRow,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>,
          ),
          AppMetaRow,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaRow,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
      AppMetaRow,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String boardId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> boardId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get boardId => $composableBuilder(
    column: $table.boardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get boardId =>
      $composableBuilder(column: $table.boardId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          StoredOutboxEntry,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            StoredOutboxEntry,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, StoredOutboxEntry>,
          ),
          StoredOutboxEntry,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> boardId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                boardId: boardId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String boardId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                boardId: boardId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      StoredOutboxEntry,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        StoredOutboxEntry,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, StoredOutboxEntry>,
      ),
      StoredOutboxEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BoardSpecsTableTableManager get boardSpecs =>
      $$BoardSpecsTableTableManager(_db, _db.boardSpecs);
  $$BoardLayoutsTableTableManager get boardLayouts =>
      $$BoardLayoutsTableTableManager(_db, _db.boardLayouts);
  $$PlayerMarksTableTableManager get playerMarks =>
      $$PlayerMarksTableTableManager(_db, _db.playerMarks);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
}
