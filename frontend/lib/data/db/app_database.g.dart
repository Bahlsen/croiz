// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GeneratedPuzzlesTable extends GeneratedPuzzles
    with TableInfo<$GeneratedPuzzlesTable, GeneratedPuzzle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeneratedPuzzlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _puzzleIdMeta = const VerificationMeta(
    'puzzleId',
  );
  @override
  late final GeneratedColumn<String> puzzleId = GeneratedColumn<String>(
    'puzzle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _jsonPayloadMeta = const VerificationMeta(
    'jsonPayload',
  );
  @override
  late final GeneratedColumn<String> jsonPayload = GeneratedColumn<String>(
    'json_payload',
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
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    puzzleId,
    jsonPayload,
    createdAt,
    difficulty,
    language,
    title,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generated_puzzles';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeneratedPuzzle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('puzzle_id')) {
      context.handle(
        _puzzleIdMeta,
        puzzleId.isAcceptableOrUnknown(data['puzzle_id']!, _puzzleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleIdMeta);
    }
    if (data.containsKey('json_payload')) {
      context.handle(
        _jsonPayloadMeta,
        jsonPayload.isAcceptableOrUnknown(
          data['json_payload']!,
          _jsonPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jsonPayloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeneratedPuzzle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeneratedPuzzle(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      puzzleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}puzzle_id'],
          )!,
      jsonPayload:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}json_payload'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      difficulty:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}difficulty'],
          )!,
      language:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}language'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
    );
  }

  @override
  $GeneratedPuzzlesTable createAlias(String alias) {
    return $GeneratedPuzzlesTable(attachedDatabase, alias);
  }
}

class GeneratedPuzzle extends DataClass implements Insertable<GeneratedPuzzle> {
  final int id;
  final String puzzleId;
  final String jsonPayload;
  final DateTime createdAt;
  final int difficulty;
  final String language;
  final String title;
  const GeneratedPuzzle({
    required this.id,
    required this.puzzleId,
    required this.jsonPayload,
    required this.createdAt,
    required this.difficulty,
    required this.language,
    required this.title,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['puzzle_id'] = Variable<String>(puzzleId);
    map['json_payload'] = Variable<String>(jsonPayload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['difficulty'] = Variable<int>(difficulty);
    map['language'] = Variable<String>(language);
    map['title'] = Variable<String>(title);
    return map;
  }

  GeneratedPuzzlesCompanion toCompanion(bool nullToAbsent) {
    return GeneratedPuzzlesCompanion(
      id: Value(id),
      puzzleId: Value(puzzleId),
      jsonPayload: Value(jsonPayload),
      createdAt: Value(createdAt),
      difficulty: Value(difficulty),
      language: Value(language),
      title: Value(title),
    );
  }

  factory GeneratedPuzzle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeneratedPuzzle(
      id: serializer.fromJson<int>(json['id']),
      puzzleId: serializer.fromJson<String>(json['puzzleId']),
      jsonPayload: serializer.fromJson<String>(json['jsonPayload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      language: serializer.fromJson<String>(json['language']),
      title: serializer.fromJson<String>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'puzzleId': serializer.toJson<String>(puzzleId),
      'jsonPayload': serializer.toJson<String>(jsonPayload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'difficulty': serializer.toJson<int>(difficulty),
      'language': serializer.toJson<String>(language),
      'title': serializer.toJson<String>(title),
    };
  }

  GeneratedPuzzle copyWith({
    int? id,
    String? puzzleId,
    String? jsonPayload,
    DateTime? createdAt,
    int? difficulty,
    String? language,
    String? title,
  }) => GeneratedPuzzle(
    id: id ?? this.id,
    puzzleId: puzzleId ?? this.puzzleId,
    jsonPayload: jsonPayload ?? this.jsonPayload,
    createdAt: createdAt ?? this.createdAt,
    difficulty: difficulty ?? this.difficulty,
    language: language ?? this.language,
    title: title ?? this.title,
  );
  GeneratedPuzzle copyWithCompanion(GeneratedPuzzlesCompanion data) {
    return GeneratedPuzzle(
      id: data.id.present ? data.id.value : this.id,
      puzzleId: data.puzzleId.present ? data.puzzleId.value : this.puzzleId,
      jsonPayload:
          data.jsonPayload.present ? data.jsonPayload.value : this.jsonPayload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      language: data.language.present ? data.language.value : this.language,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedPuzzle(')
          ..write('id: $id, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('jsonPayload: $jsonPayload, ')
          ..write('createdAt: $createdAt, ')
          ..write('difficulty: $difficulty, ')
          ..write('language: $language, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    puzzleId,
    jsonPayload,
    createdAt,
    difficulty,
    language,
    title,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeneratedPuzzle &&
          other.id == this.id &&
          other.puzzleId == this.puzzleId &&
          other.jsonPayload == this.jsonPayload &&
          other.createdAt == this.createdAt &&
          other.difficulty == this.difficulty &&
          other.language == this.language &&
          other.title == this.title);
}

class GeneratedPuzzlesCompanion extends UpdateCompanion<GeneratedPuzzle> {
  final Value<int> id;
  final Value<String> puzzleId;
  final Value<String> jsonPayload;
  final Value<DateTime> createdAt;
  final Value<int> difficulty;
  final Value<String> language;
  final Value<String> title;
  const GeneratedPuzzlesCompanion({
    this.id = const Value.absent(),
    this.puzzleId = const Value.absent(),
    this.jsonPayload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.language = const Value.absent(),
    this.title = const Value.absent(),
  });
  GeneratedPuzzlesCompanion.insert({
    this.id = const Value.absent(),
    required String puzzleId,
    required String jsonPayload,
    required DateTime createdAt,
    required int difficulty,
    required String language,
    required String title,
  }) : puzzleId = Value(puzzleId),
       jsonPayload = Value(jsonPayload),
       createdAt = Value(createdAt),
       difficulty = Value(difficulty),
       language = Value(language),
       title = Value(title);
  static Insertable<GeneratedPuzzle> custom({
    Expression<int>? id,
    Expression<String>? puzzleId,
    Expression<String>? jsonPayload,
    Expression<DateTime>? createdAt,
    Expression<int>? difficulty,
    Expression<String>? language,
    Expression<String>? title,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (puzzleId != null) 'puzzle_id': puzzleId,
      if (jsonPayload != null) 'json_payload': jsonPayload,
      if (createdAt != null) 'created_at': createdAt,
      if (difficulty != null) 'difficulty': difficulty,
      if (language != null) 'language': language,
      if (title != null) 'title': title,
    });
  }

  GeneratedPuzzlesCompanion copyWith({
    Value<int>? id,
    Value<String>? puzzleId,
    Value<String>? jsonPayload,
    Value<DateTime>? createdAt,
    Value<int>? difficulty,
    Value<String>? language,
    Value<String>? title,
  }) {
    return GeneratedPuzzlesCompanion(
      id: id ?? this.id,
      puzzleId: puzzleId ?? this.puzzleId,
      jsonPayload: jsonPayload ?? this.jsonPayload,
      createdAt: createdAt ?? this.createdAt,
      difficulty: difficulty ?? this.difficulty,
      language: language ?? this.language,
      title: title ?? this.title,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (puzzleId.present) {
      map['puzzle_id'] = Variable<String>(puzzleId.value);
    }
    if (jsonPayload.present) {
      map['json_payload'] = Variable<String>(jsonPayload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedPuzzlesCompanion(')
          ..write('id: $id, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('jsonPayload: $jsonPayload, ')
          ..write('createdAt: $createdAt, ')
          ..write('difficulty: $difficulty, ')
          ..write('language: $language, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }
}

class $PuzzleProgressTable extends PuzzleProgress
    with TableInfo<$PuzzleProgressTable, PuzzleProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PuzzleProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _puzzleIdMeta = const VerificationMeta(
    'puzzleId',
  );
  @override
  late final GeneratedColumn<String> puzzleId = GeneratedColumn<String>(
    'puzzle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _jsonPayloadMeta = const VerificationMeta(
    'jsonPayload',
  );
  @override
  late final GeneratedColumn<String> jsonPayload = GeneratedColumn<String>(
    'json_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPlayedMeta = const VerificationMeta(
    'lastPlayed',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayed = GeneratedColumn<DateTime>(
    'last_played',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completionPercentMeta = const VerificationMeta(
    'completionPercent',
  );
  @override
  late final GeneratedColumn<int> completionPercent = GeneratedColumn<int>(
    'completion_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    puzzleId,
    jsonPayload,
    lastPlayed,
    isCompleted,
    completionPercent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'puzzle_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<PuzzleProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('puzzle_id')) {
      context.handle(
        _puzzleIdMeta,
        puzzleId.isAcceptableOrUnknown(data['puzzle_id']!, _puzzleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleIdMeta);
    }
    if (data.containsKey('json_payload')) {
      context.handle(
        _jsonPayloadMeta,
        jsonPayload.isAcceptableOrUnknown(
          data['json_payload']!,
          _jsonPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jsonPayloadMeta);
    }
    if (data.containsKey('last_played')) {
      context.handle(
        _lastPlayedMeta,
        lastPlayed.isAcceptableOrUnknown(data['last_played']!, _lastPlayedMeta),
      );
    } else if (isInserting) {
      context.missing(_lastPlayedMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completion_percent')) {
      context.handle(
        _completionPercentMeta,
        completionPercent.isAcceptableOrUnknown(
          data['completion_percent']!,
          _completionPercentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PuzzleProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PuzzleProgressData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      puzzleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}puzzle_id'],
          )!,
      jsonPayload:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}json_payload'],
          )!,
      lastPlayed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_played'],
          )!,
      isCompleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_completed'],
          )!,
      completionPercent:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}completion_percent'],
          )!,
    );
  }

  @override
  $PuzzleProgressTable createAlias(String alias) {
    return $PuzzleProgressTable(attachedDatabase, alias);
  }
}

class PuzzleProgressData extends DataClass
    implements Insertable<PuzzleProgressData> {
  final int id;
  final String puzzleId;
  final String jsonPayload;
  final DateTime lastPlayed;
  final bool isCompleted;
  final int completionPercent;
  const PuzzleProgressData({
    required this.id,
    required this.puzzleId,
    required this.jsonPayload,
    required this.lastPlayed,
    required this.isCompleted,
    required this.completionPercent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['puzzle_id'] = Variable<String>(puzzleId);
    map['json_payload'] = Variable<String>(jsonPayload);
    map['last_played'] = Variable<DateTime>(lastPlayed);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['completion_percent'] = Variable<int>(completionPercent);
    return map;
  }

  PuzzleProgressCompanion toCompanion(bool nullToAbsent) {
    return PuzzleProgressCompanion(
      id: Value(id),
      puzzleId: Value(puzzleId),
      jsonPayload: Value(jsonPayload),
      lastPlayed: Value(lastPlayed),
      isCompleted: Value(isCompleted),
      completionPercent: Value(completionPercent),
    );
  }

  factory PuzzleProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PuzzleProgressData(
      id: serializer.fromJson<int>(json['id']),
      puzzleId: serializer.fromJson<String>(json['puzzleId']),
      jsonPayload: serializer.fromJson<String>(json['jsonPayload']),
      lastPlayed: serializer.fromJson<DateTime>(json['lastPlayed']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completionPercent: serializer.fromJson<int>(json['completionPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'puzzleId': serializer.toJson<String>(puzzleId),
      'jsonPayload': serializer.toJson<String>(jsonPayload),
      'lastPlayed': serializer.toJson<DateTime>(lastPlayed),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completionPercent': serializer.toJson<int>(completionPercent),
    };
  }

  PuzzleProgressData copyWith({
    int? id,
    String? puzzleId,
    String? jsonPayload,
    DateTime? lastPlayed,
    bool? isCompleted,
    int? completionPercent,
  }) => PuzzleProgressData(
    id: id ?? this.id,
    puzzleId: puzzleId ?? this.puzzleId,
    jsonPayload: jsonPayload ?? this.jsonPayload,
    lastPlayed: lastPlayed ?? this.lastPlayed,
    isCompleted: isCompleted ?? this.isCompleted,
    completionPercent: completionPercent ?? this.completionPercent,
  );
  PuzzleProgressData copyWithCompanion(PuzzleProgressCompanion data) {
    return PuzzleProgressData(
      id: data.id.present ? data.id.value : this.id,
      puzzleId: data.puzzleId.present ? data.puzzleId.value : this.puzzleId,
      jsonPayload:
          data.jsonPayload.present ? data.jsonPayload.value : this.jsonPayload,
      lastPlayed:
          data.lastPlayed.present ? data.lastPlayed.value : this.lastPlayed,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completionPercent:
          data.completionPercent.present
              ? data.completionPercent.value
              : this.completionPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleProgressData(')
          ..write('id: $id, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('jsonPayload: $jsonPayload, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completionPercent: $completionPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    puzzleId,
    jsonPayload,
    lastPlayed,
    isCompleted,
    completionPercent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PuzzleProgressData &&
          other.id == this.id &&
          other.puzzleId == this.puzzleId &&
          other.jsonPayload == this.jsonPayload &&
          other.lastPlayed == this.lastPlayed &&
          other.isCompleted == this.isCompleted &&
          other.completionPercent == this.completionPercent);
}

class PuzzleProgressCompanion extends UpdateCompanion<PuzzleProgressData> {
  final Value<int> id;
  final Value<String> puzzleId;
  final Value<String> jsonPayload;
  final Value<DateTime> lastPlayed;
  final Value<bool> isCompleted;
  final Value<int> completionPercent;
  const PuzzleProgressCompanion({
    this.id = const Value.absent(),
    this.puzzleId = const Value.absent(),
    this.jsonPayload = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completionPercent = const Value.absent(),
  });
  PuzzleProgressCompanion.insert({
    this.id = const Value.absent(),
    required String puzzleId,
    required String jsonPayload,
    required DateTime lastPlayed,
    this.isCompleted = const Value.absent(),
    this.completionPercent = const Value.absent(),
  }) : puzzleId = Value(puzzleId),
       jsonPayload = Value(jsonPayload),
       lastPlayed = Value(lastPlayed);
  static Insertable<PuzzleProgressData> custom({
    Expression<int>? id,
    Expression<String>? puzzleId,
    Expression<String>? jsonPayload,
    Expression<DateTime>? lastPlayed,
    Expression<bool>? isCompleted,
    Expression<int>? completionPercent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (puzzleId != null) 'puzzle_id': puzzleId,
      if (jsonPayload != null) 'json_payload': jsonPayload,
      if (lastPlayed != null) 'last_played': lastPlayed,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completionPercent != null) 'completion_percent': completionPercent,
    });
  }

  PuzzleProgressCompanion copyWith({
    Value<int>? id,
    Value<String>? puzzleId,
    Value<String>? jsonPayload,
    Value<DateTime>? lastPlayed,
    Value<bool>? isCompleted,
    Value<int>? completionPercent,
  }) {
    return PuzzleProgressCompanion(
      id: id ?? this.id,
      puzzleId: puzzleId ?? this.puzzleId,
      jsonPayload: jsonPayload ?? this.jsonPayload,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      isCompleted: isCompleted ?? this.isCompleted,
      completionPercent: completionPercent ?? this.completionPercent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (puzzleId.present) {
      map['puzzle_id'] = Variable<String>(puzzleId.value);
    }
    if (jsonPayload.present) {
      map['json_payload'] = Variable<String>(jsonPayload.value);
    }
    if (lastPlayed.present) {
      map['last_played'] = Variable<DateTime>(lastPlayed.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completionPercent.present) {
      map['completion_percent'] = Variable<int>(completionPercent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleProgressCompanion(')
          ..write('id: $id, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('jsonPayload: $jsonPayload, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completionPercent: $completionPercent')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GeneratedPuzzlesTable generatedPuzzles = $GeneratedPuzzlesTable(
    this,
  );
  late final $PuzzleProgressTable puzzleProgress = $PuzzleProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    generatedPuzzles,
    puzzleProgress,
  ];
}

typedef $$GeneratedPuzzlesTableCreateCompanionBuilder =
    GeneratedPuzzlesCompanion Function({
      Value<int> id,
      required String puzzleId,
      required String jsonPayload,
      required DateTime createdAt,
      required int difficulty,
      required String language,
      required String title,
    });
typedef $$GeneratedPuzzlesTableUpdateCompanionBuilder =
    GeneratedPuzzlesCompanion Function({
      Value<int> id,
      Value<String> puzzleId,
      Value<String> jsonPayload,
      Value<DateTime> createdAt,
      Value<int> difficulty,
      Value<String> language,
      Value<String> title,
    });

class $$GeneratedPuzzlesTableFilterComposer
    extends Composer<_$AppDatabase, $GeneratedPuzzlesTable> {
  $$GeneratedPuzzlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonPayload => $composableBuilder(
    column: $table.jsonPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeneratedPuzzlesTableOrderingComposer
    extends Composer<_$AppDatabase, $GeneratedPuzzlesTable> {
  $$GeneratedPuzzlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonPayload => $composableBuilder(
    column: $table.jsonPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeneratedPuzzlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeneratedPuzzlesTable> {
  $$GeneratedPuzzlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get puzzleId =>
      $composableBuilder(column: $table.puzzleId, builder: (column) => column);

  GeneratedColumn<String> get jsonPayload => $composableBuilder(
    column: $table.jsonPayload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);
}

class $$GeneratedPuzzlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GeneratedPuzzlesTable,
          GeneratedPuzzle,
          $$GeneratedPuzzlesTableFilterComposer,
          $$GeneratedPuzzlesTableOrderingComposer,
          $$GeneratedPuzzlesTableAnnotationComposer,
          $$GeneratedPuzzlesTableCreateCompanionBuilder,
          $$GeneratedPuzzlesTableUpdateCompanionBuilder,
          (
            GeneratedPuzzle,
            BaseReferences<
              _$AppDatabase,
              $GeneratedPuzzlesTable,
              GeneratedPuzzle
            >,
          ),
          GeneratedPuzzle,
          PrefetchHooks Function()
        > {
  $$GeneratedPuzzlesTableTableManager(
    _$AppDatabase db,
    $GeneratedPuzzlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$GeneratedPuzzlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GeneratedPuzzlesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$GeneratedPuzzlesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> puzzleId = const Value.absent(),
                Value<String> jsonPayload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> title = const Value.absent(),
              }) => GeneratedPuzzlesCompanion(
                id: id,
                puzzleId: puzzleId,
                jsonPayload: jsonPayload,
                createdAt: createdAt,
                difficulty: difficulty,
                language: language,
                title: title,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String puzzleId,
                required String jsonPayload,
                required DateTime createdAt,
                required int difficulty,
                required String language,
                required String title,
              }) => GeneratedPuzzlesCompanion.insert(
                id: id,
                puzzleId: puzzleId,
                jsonPayload: jsonPayload,
                createdAt: createdAt,
                difficulty: difficulty,
                language: language,
                title: title,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeneratedPuzzlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GeneratedPuzzlesTable,
      GeneratedPuzzle,
      $$GeneratedPuzzlesTableFilterComposer,
      $$GeneratedPuzzlesTableOrderingComposer,
      $$GeneratedPuzzlesTableAnnotationComposer,
      $$GeneratedPuzzlesTableCreateCompanionBuilder,
      $$GeneratedPuzzlesTableUpdateCompanionBuilder,
      (
        GeneratedPuzzle,
        BaseReferences<_$AppDatabase, $GeneratedPuzzlesTable, GeneratedPuzzle>,
      ),
      GeneratedPuzzle,
      PrefetchHooks Function()
    >;
typedef $$PuzzleProgressTableCreateCompanionBuilder =
    PuzzleProgressCompanion Function({
      Value<int> id,
      required String puzzleId,
      required String jsonPayload,
      required DateTime lastPlayed,
      Value<bool> isCompleted,
      Value<int> completionPercent,
    });
typedef $$PuzzleProgressTableUpdateCompanionBuilder =
    PuzzleProgressCompanion Function({
      Value<int> id,
      Value<String> puzzleId,
      Value<String> jsonPayload,
      Value<DateTime> lastPlayed,
      Value<bool> isCompleted,
      Value<int> completionPercent,
    });

class $$PuzzleProgressTableFilterComposer
    extends Composer<_$AppDatabase, $PuzzleProgressTable> {
  $$PuzzleProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonPayload => $composableBuilder(
    column: $table.jsonPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completionPercent => $composableBuilder(
    column: $table.completionPercent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PuzzleProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $PuzzleProgressTable> {
  $$PuzzleProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonPayload => $composableBuilder(
    column: $table.jsonPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completionPercent => $composableBuilder(
    column: $table.completionPercent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PuzzleProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $PuzzleProgressTable> {
  $$PuzzleProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get puzzleId =>
      $composableBuilder(column: $table.puzzleId, builder: (column) => column);

  GeneratedColumn<String> get jsonPayload => $composableBuilder(
    column: $table.jsonPayload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completionPercent => $composableBuilder(
    column: $table.completionPercent,
    builder: (column) => column,
  );
}

class $$PuzzleProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PuzzleProgressTable,
          PuzzleProgressData,
          $$PuzzleProgressTableFilterComposer,
          $$PuzzleProgressTableOrderingComposer,
          $$PuzzleProgressTableAnnotationComposer,
          $$PuzzleProgressTableCreateCompanionBuilder,
          $$PuzzleProgressTableUpdateCompanionBuilder,
          (
            PuzzleProgressData,
            BaseReferences<
              _$AppDatabase,
              $PuzzleProgressTable,
              PuzzleProgressData
            >,
          ),
          PuzzleProgressData,
          PrefetchHooks Function()
        > {
  $$PuzzleProgressTableTableManager(
    _$AppDatabase db,
    $PuzzleProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PuzzleProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$PuzzleProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PuzzleProgressTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> puzzleId = const Value.absent(),
                Value<String> jsonPayload = const Value.absent(),
                Value<DateTime> lastPlayed = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> completionPercent = const Value.absent(),
              }) => PuzzleProgressCompanion(
                id: id,
                puzzleId: puzzleId,
                jsonPayload: jsonPayload,
                lastPlayed: lastPlayed,
                isCompleted: isCompleted,
                completionPercent: completionPercent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String puzzleId,
                required String jsonPayload,
                required DateTime lastPlayed,
                Value<bool> isCompleted = const Value.absent(),
                Value<int> completionPercent = const Value.absent(),
              }) => PuzzleProgressCompanion.insert(
                id: id,
                puzzleId: puzzleId,
                jsonPayload: jsonPayload,
                lastPlayed: lastPlayed,
                isCompleted: isCompleted,
                completionPercent: completionPercent,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PuzzleProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PuzzleProgressTable,
      PuzzleProgressData,
      $$PuzzleProgressTableFilterComposer,
      $$PuzzleProgressTableOrderingComposer,
      $$PuzzleProgressTableAnnotationComposer,
      $$PuzzleProgressTableCreateCompanionBuilder,
      $$PuzzleProgressTableUpdateCompanionBuilder,
      (
        PuzzleProgressData,
        BaseReferences<_$AppDatabase, $PuzzleProgressTable, PuzzleProgressData>,
      ),
      PuzzleProgressData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GeneratedPuzzlesTableTableManager get generatedPuzzles =>
      $$GeneratedPuzzlesTableTableManager(_db, _db.generatedPuzzles);
  $$PuzzleProgressTableTableManager get puzzleProgress =>
      $$PuzzleProgressTableTableManager(_db, _db.puzzleProgress);
}
