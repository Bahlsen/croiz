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

class $UserStatsTableTable extends UserStatsTable
    with TableInfo<$UserStatsTableTable, UserStatsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _totalPuzzlesCompletedMeta =
      const VerificationMeta('totalPuzzlesCompleted');
  @override
  late final GeneratedColumn<int> totalPuzzlesCompleted = GeneratedColumn<int>(
    'total_puzzles_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalWordsFoundMeta = const VerificationMeta(
    'totalWordsFound',
  );
  @override
  late final GeneratedColumn<int> totalWordsFound = GeneratedColumn<int>(
    'total_words_found',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPlayTimeSecondsMeta =
      const VerificationMeta('totalPlayTimeSeconds');
  @override
  late final GeneratedColumn<int> totalPlayTimeSeconds = GeneratedColumn<int>(
    'total_play_time_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedDateMeta = const VerificationMeta(
    'lastPlayedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedDate =
      GeneratedColumn<DateTime>(
        'last_played_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    totalPuzzlesCompleted,
    totalWordsFound,
    totalPlayTimeSeconds,
    currentStreak,
    longestStreak,
    lastPlayedDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserStatsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('total_puzzles_completed')) {
      context.handle(
        _totalPuzzlesCompletedMeta,
        totalPuzzlesCompleted.isAcceptableOrUnknown(
          data['total_puzzles_completed']!,
          _totalPuzzlesCompletedMeta,
        ),
      );
    }
    if (data.containsKey('total_words_found')) {
      context.handle(
        _totalWordsFoundMeta,
        totalWordsFound.isAcceptableOrUnknown(
          data['total_words_found']!,
          _totalWordsFoundMeta,
        ),
      );
    }
    if (data.containsKey('total_play_time_seconds')) {
      context.handle(
        _totalPlayTimeSecondsMeta,
        totalPlayTimeSeconds.isAcceptableOrUnknown(
          data['total_play_time_seconds']!,
          _totalPlayTimeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('last_played_date')) {
      context.handle(
        _lastPlayedDateMeta,
        lastPlayedDate.isAcceptableOrUnknown(
          data['last_played_date']!,
          _lastPlayedDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserStatsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStatsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      totalPuzzlesCompleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_puzzles_completed'],
          )!,
      totalWordsFound:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_words_found'],
          )!,
      totalPlayTimeSeconds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_play_time_seconds'],
          )!,
      currentStreak:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}current_streak'],
          )!,
      longestStreak:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}longest_streak'],
          )!,
      lastPlayedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_date'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $UserStatsTableTable createAlias(String alias) {
    return $UserStatsTableTable(attachedDatabase, alias);
  }
}

class UserStatsTableData extends DataClass
    implements Insertable<UserStatsTableData> {
  final int id;
  final int totalPuzzlesCompleted;
  final int totalWordsFound;
  final int totalPlayTimeSeconds;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPlayedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserStatsTableData({
    required this.id,
    required this.totalPuzzlesCompleted,
    required this.totalWordsFound,
    required this.totalPlayTimeSeconds,
    required this.currentStreak,
    required this.longestStreak,
    this.lastPlayedDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['total_puzzles_completed'] = Variable<int>(totalPuzzlesCompleted);
    map['total_words_found'] = Variable<int>(totalWordsFound);
    map['total_play_time_seconds'] = Variable<int>(totalPlayTimeSeconds);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    if (!nullToAbsent || lastPlayedDate != null) {
      map['last_played_date'] = Variable<DateTime>(lastPlayedDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserStatsTableCompanion toCompanion(bool nullToAbsent) {
    return UserStatsTableCompanion(
      id: Value(id),
      totalPuzzlesCompleted: Value(totalPuzzlesCompleted),
      totalWordsFound: Value(totalWordsFound),
      totalPlayTimeSeconds: Value(totalPlayTimeSeconds),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      lastPlayedDate:
          lastPlayedDate == null && nullToAbsent
              ? const Value.absent()
              : Value(lastPlayedDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserStatsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStatsTableData(
      id: serializer.fromJson<int>(json['id']),
      totalPuzzlesCompleted: serializer.fromJson<int>(
        json['totalPuzzlesCompleted'],
      ),
      totalWordsFound: serializer.fromJson<int>(json['totalWordsFound']),
      totalPlayTimeSeconds: serializer.fromJson<int>(
        json['totalPlayTimeSeconds'],
      ),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      lastPlayedDate: serializer.fromJson<DateTime?>(json['lastPlayedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'totalPuzzlesCompleted': serializer.toJson<int>(totalPuzzlesCompleted),
      'totalWordsFound': serializer.toJson<int>(totalWordsFound),
      'totalPlayTimeSeconds': serializer.toJson<int>(totalPlayTimeSeconds),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'lastPlayedDate': serializer.toJson<DateTime?>(lastPlayedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserStatsTableData copyWith({
    int? id,
    int? totalPuzzlesCompleted,
    int? totalWordsFound,
    int? totalPlayTimeSeconds,
    int? currentStreak,
    int? longestStreak,
    Value<DateTime?> lastPlayedDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserStatsTableData(
    id: id ?? this.id,
    totalPuzzlesCompleted: totalPuzzlesCompleted ?? this.totalPuzzlesCompleted,
    totalWordsFound: totalWordsFound ?? this.totalWordsFound,
    totalPlayTimeSeconds: totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastPlayedDate:
        lastPlayedDate.present ? lastPlayedDate.value : this.lastPlayedDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserStatsTableData copyWithCompanion(UserStatsTableCompanion data) {
    return UserStatsTableData(
      id: data.id.present ? data.id.value : this.id,
      totalPuzzlesCompleted:
          data.totalPuzzlesCompleted.present
              ? data.totalPuzzlesCompleted.value
              : this.totalPuzzlesCompleted,
      totalWordsFound:
          data.totalWordsFound.present
              ? data.totalWordsFound.value
              : this.totalWordsFound,
      totalPlayTimeSeconds:
          data.totalPlayTimeSeconds.present
              ? data.totalPlayTimeSeconds.value
              : this.totalPlayTimeSeconds,
      currentStreak:
          data.currentStreak.present
              ? data.currentStreak.value
              : this.currentStreak,
      longestStreak:
          data.longestStreak.present
              ? data.longestStreak.value
              : this.longestStreak,
      lastPlayedDate:
          data.lastPlayedDate.present
              ? data.lastPlayedDate.value
              : this.lastPlayedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsTableData(')
          ..write('id: $id, ')
          ..write('totalPuzzlesCompleted: $totalPuzzlesCompleted, ')
          ..write('totalWordsFound: $totalWordsFound, ')
          ..write('totalPlayTimeSeconds: $totalPlayTimeSeconds, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastPlayedDate: $lastPlayedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    totalPuzzlesCompleted,
    totalWordsFound,
    totalPlayTimeSeconds,
    currentStreak,
    longestStreak,
    lastPlayedDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStatsTableData &&
          other.id == this.id &&
          other.totalPuzzlesCompleted == this.totalPuzzlesCompleted &&
          other.totalWordsFound == this.totalWordsFound &&
          other.totalPlayTimeSeconds == this.totalPlayTimeSeconds &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.lastPlayedDate == this.lastPlayedDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserStatsTableCompanion extends UpdateCompanion<UserStatsTableData> {
  final Value<int> id;
  final Value<int> totalPuzzlesCompleted;
  final Value<int> totalWordsFound;
  final Value<int> totalPlayTimeSeconds;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<DateTime?> lastPlayedDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserStatsTableCompanion({
    this.id = const Value.absent(),
    this.totalPuzzlesCompleted = const Value.absent(),
    this.totalWordsFound = const Value.absent(),
    this.totalPlayTimeSeconds = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastPlayedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserStatsTableCompanion.insert({
    this.id = const Value.absent(),
    this.totalPuzzlesCompleted = const Value.absent(),
    this.totalWordsFound = const Value.absent(),
    this.totalPlayTimeSeconds = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastPlayedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<UserStatsTableData> custom({
    Expression<int>? id,
    Expression<int>? totalPuzzlesCompleted,
    Expression<int>? totalWordsFound,
    Expression<int>? totalPlayTimeSeconds,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<DateTime>? lastPlayedDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (totalPuzzlesCompleted != null)
        'total_puzzles_completed': totalPuzzlesCompleted,
      if (totalWordsFound != null) 'total_words_found': totalWordsFound,
      if (totalPlayTimeSeconds != null)
        'total_play_time_seconds': totalPlayTimeSeconds,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (lastPlayedDate != null) 'last_played_date': lastPlayedDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserStatsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? totalPuzzlesCompleted,
    Value<int>? totalWordsFound,
    Value<int>? totalPlayTimeSeconds,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<DateTime?>? lastPlayedDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserStatsTableCompanion(
      id: id ?? this.id,
      totalPuzzlesCompleted:
          totalPuzzlesCompleted ?? this.totalPuzzlesCompleted,
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
      totalPlayTimeSeconds: totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (totalPuzzlesCompleted.present) {
      map['total_puzzles_completed'] = Variable<int>(
        totalPuzzlesCompleted.value,
      );
    }
    if (totalWordsFound.present) {
      map['total_words_found'] = Variable<int>(totalWordsFound.value);
    }
    if (totalPlayTimeSeconds.present) {
      map['total_play_time_seconds'] = Variable<int>(
        totalPlayTimeSeconds.value,
      );
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (lastPlayedDate.present) {
      map['last_played_date'] = Variable<DateTime>(lastPlayedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsTableCompanion(')
          ..write('id: $id, ')
          ..write('totalPuzzlesCompleted: $totalPuzzlesCompleted, ')
          ..write('totalWordsFound: $totalWordsFound, ')
          ..write('totalPlayTimeSeconds: $totalPlayTimeSeconds, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastPlayedDate: $lastPlayedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PuzzleStatsTableTable extends PuzzleStatsTable
    with TableInfo<$PuzzleStatsTableTable, PuzzleStatsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PuzzleStatsTableTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeToCompleteSecondsMeta =
      const VerificationMeta('timeToCompleteSeconds');
  @override
  late final GeneratedColumn<int> timeToCompleteSeconds = GeneratedColumn<int>(
    'time_to_complete_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintsUsedMeta = const VerificationMeta(
    'hintsUsed',
  );
  @override
  late final GeneratedColumn<int> hintsUsed = GeneratedColumn<int>(
    'hints_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalWordsMeta = const VerificationMeta(
    'totalWords',
  );
  @override
  late final GeneratedColumn<int> totalWords = GeneratedColumn<int>(
    'total_words',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordsRevealedMeta = const VerificationMeta(
    'wordsRevealed',
  );
  @override
  late final GeneratedColumn<int> wordsRevealed = GeneratedColumn<int>(
    'words_revealed',
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
    completedAt,
    timeToCompleteSeconds,
    hintsUsed,
    accuracy,
    totalWords,
    wordsRevealed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'puzzle_stats_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PuzzleStatsTableData> instance, {
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
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('time_to_complete_seconds')) {
      context.handle(
        _timeToCompleteSecondsMeta,
        timeToCompleteSeconds.isAcceptableOrUnknown(
          data['time_to_complete_seconds']!,
          _timeToCompleteSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeToCompleteSecondsMeta);
    }
    if (data.containsKey('hints_used')) {
      context.handle(
        _hintsUsedMeta,
        hintsUsed.isAcceptableOrUnknown(data['hints_used']!, _hintsUsedMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('total_words')) {
      context.handle(
        _totalWordsMeta,
        totalWords.isAcceptableOrUnknown(data['total_words']!, _totalWordsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalWordsMeta);
    }
    if (data.containsKey('words_revealed')) {
      context.handle(
        _wordsRevealedMeta,
        wordsRevealed.isAcceptableOrUnknown(
          data['words_revealed']!,
          _wordsRevealedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PuzzleStatsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PuzzleStatsTableData(
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
      completedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}completed_at'],
          )!,
      timeToCompleteSeconds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}time_to_complete_seconds'],
          )!,
      hintsUsed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}hints_used'],
          )!,
      accuracy:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}accuracy'],
          )!,
      totalWords:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_words'],
          )!,
      wordsRevealed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}words_revealed'],
          )!,
    );
  }

  @override
  $PuzzleStatsTableTable createAlias(String alias) {
    return $PuzzleStatsTableTable(attachedDatabase, alias);
  }
}

class PuzzleStatsTableData extends DataClass
    implements Insertable<PuzzleStatsTableData> {
  final int id;
  final String puzzleId;
  final DateTime completedAt;
  final int timeToCompleteSeconds;
  final int hintsUsed;
  final double accuracy;
  final int totalWords;
  final int wordsRevealed;
  const PuzzleStatsTableData({
    required this.id,
    required this.puzzleId,
    required this.completedAt,
    required this.timeToCompleteSeconds,
    required this.hintsUsed,
    required this.accuracy,
    required this.totalWords,
    required this.wordsRevealed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['puzzle_id'] = Variable<String>(puzzleId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['time_to_complete_seconds'] = Variable<int>(timeToCompleteSeconds);
    map['hints_used'] = Variable<int>(hintsUsed);
    map['accuracy'] = Variable<double>(accuracy);
    map['total_words'] = Variable<int>(totalWords);
    map['words_revealed'] = Variable<int>(wordsRevealed);
    return map;
  }

  PuzzleStatsTableCompanion toCompanion(bool nullToAbsent) {
    return PuzzleStatsTableCompanion(
      id: Value(id),
      puzzleId: Value(puzzleId),
      completedAt: Value(completedAt),
      timeToCompleteSeconds: Value(timeToCompleteSeconds),
      hintsUsed: Value(hintsUsed),
      accuracy: Value(accuracy),
      totalWords: Value(totalWords),
      wordsRevealed: Value(wordsRevealed),
    );
  }

  factory PuzzleStatsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PuzzleStatsTableData(
      id: serializer.fromJson<int>(json['id']),
      puzzleId: serializer.fromJson<String>(json['puzzleId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      timeToCompleteSeconds: serializer.fromJson<int>(
        json['timeToCompleteSeconds'],
      ),
      hintsUsed: serializer.fromJson<int>(json['hintsUsed']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      totalWords: serializer.fromJson<int>(json['totalWords']),
      wordsRevealed: serializer.fromJson<int>(json['wordsRevealed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'puzzleId': serializer.toJson<String>(puzzleId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'timeToCompleteSeconds': serializer.toJson<int>(timeToCompleteSeconds),
      'hintsUsed': serializer.toJson<int>(hintsUsed),
      'accuracy': serializer.toJson<double>(accuracy),
      'totalWords': serializer.toJson<int>(totalWords),
      'wordsRevealed': serializer.toJson<int>(wordsRevealed),
    };
  }

  PuzzleStatsTableData copyWith({
    int? id,
    String? puzzleId,
    DateTime? completedAt,
    int? timeToCompleteSeconds,
    int? hintsUsed,
    double? accuracy,
    int? totalWords,
    int? wordsRevealed,
  }) => PuzzleStatsTableData(
    id: id ?? this.id,
    puzzleId: puzzleId ?? this.puzzleId,
    completedAt: completedAt ?? this.completedAt,
    timeToCompleteSeconds: timeToCompleteSeconds ?? this.timeToCompleteSeconds,
    hintsUsed: hintsUsed ?? this.hintsUsed,
    accuracy: accuracy ?? this.accuracy,
    totalWords: totalWords ?? this.totalWords,
    wordsRevealed: wordsRevealed ?? this.wordsRevealed,
  );
  PuzzleStatsTableData copyWithCompanion(PuzzleStatsTableCompanion data) {
    return PuzzleStatsTableData(
      id: data.id.present ? data.id.value : this.id,
      puzzleId: data.puzzleId.present ? data.puzzleId.value : this.puzzleId,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      timeToCompleteSeconds:
          data.timeToCompleteSeconds.present
              ? data.timeToCompleteSeconds.value
              : this.timeToCompleteSeconds,
      hintsUsed: data.hintsUsed.present ? data.hintsUsed.value : this.hintsUsed,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      totalWords:
          data.totalWords.present ? data.totalWords.value : this.totalWords,
      wordsRevealed:
          data.wordsRevealed.present
              ? data.wordsRevealed.value
              : this.wordsRevealed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleStatsTableData(')
          ..write('id: $id, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('completedAt: $completedAt, ')
          ..write('timeToCompleteSeconds: $timeToCompleteSeconds, ')
          ..write('hintsUsed: $hintsUsed, ')
          ..write('accuracy: $accuracy, ')
          ..write('totalWords: $totalWords, ')
          ..write('wordsRevealed: $wordsRevealed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    puzzleId,
    completedAt,
    timeToCompleteSeconds,
    hintsUsed,
    accuracy,
    totalWords,
    wordsRevealed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PuzzleStatsTableData &&
          other.id == this.id &&
          other.puzzleId == this.puzzleId &&
          other.completedAt == this.completedAt &&
          other.timeToCompleteSeconds == this.timeToCompleteSeconds &&
          other.hintsUsed == this.hintsUsed &&
          other.accuracy == this.accuracy &&
          other.totalWords == this.totalWords &&
          other.wordsRevealed == this.wordsRevealed);
}

class PuzzleStatsTableCompanion extends UpdateCompanion<PuzzleStatsTableData> {
  final Value<int> id;
  final Value<String> puzzleId;
  final Value<DateTime> completedAt;
  final Value<int> timeToCompleteSeconds;
  final Value<int> hintsUsed;
  final Value<double> accuracy;
  final Value<int> totalWords;
  final Value<int> wordsRevealed;
  const PuzzleStatsTableCompanion({
    this.id = const Value.absent(),
    this.puzzleId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.timeToCompleteSeconds = const Value.absent(),
    this.hintsUsed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.totalWords = const Value.absent(),
    this.wordsRevealed = const Value.absent(),
  });
  PuzzleStatsTableCompanion.insert({
    this.id = const Value.absent(),
    required String puzzleId,
    required DateTime completedAt,
    required int timeToCompleteSeconds,
    this.hintsUsed = const Value.absent(),
    required double accuracy,
    required int totalWords,
    this.wordsRevealed = const Value.absent(),
  }) : puzzleId = Value(puzzleId),
       completedAt = Value(completedAt),
       timeToCompleteSeconds = Value(timeToCompleteSeconds),
       accuracy = Value(accuracy),
       totalWords = Value(totalWords);
  static Insertable<PuzzleStatsTableData> custom({
    Expression<int>? id,
    Expression<String>? puzzleId,
    Expression<DateTime>? completedAt,
    Expression<int>? timeToCompleteSeconds,
    Expression<int>? hintsUsed,
    Expression<double>? accuracy,
    Expression<int>? totalWords,
    Expression<int>? wordsRevealed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (puzzleId != null) 'puzzle_id': puzzleId,
      if (completedAt != null) 'completed_at': completedAt,
      if (timeToCompleteSeconds != null)
        'time_to_complete_seconds': timeToCompleteSeconds,
      if (hintsUsed != null) 'hints_used': hintsUsed,
      if (accuracy != null) 'accuracy': accuracy,
      if (totalWords != null) 'total_words': totalWords,
      if (wordsRevealed != null) 'words_revealed': wordsRevealed,
    });
  }

  PuzzleStatsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? puzzleId,
    Value<DateTime>? completedAt,
    Value<int>? timeToCompleteSeconds,
    Value<int>? hintsUsed,
    Value<double>? accuracy,
    Value<int>? totalWords,
    Value<int>? wordsRevealed,
  }) {
    return PuzzleStatsTableCompanion(
      id: id ?? this.id,
      puzzleId: puzzleId ?? this.puzzleId,
      completedAt: completedAt ?? this.completedAt,
      timeToCompleteSeconds:
          timeToCompleteSeconds ?? this.timeToCompleteSeconds,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      accuracy: accuracy ?? this.accuracy,
      totalWords: totalWords ?? this.totalWords,
      wordsRevealed: wordsRevealed ?? this.wordsRevealed,
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
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (timeToCompleteSeconds.present) {
      map['time_to_complete_seconds'] = Variable<int>(
        timeToCompleteSeconds.value,
      );
    }
    if (hintsUsed.present) {
      map['hints_used'] = Variable<int>(hintsUsed.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (totalWords.present) {
      map['total_words'] = Variable<int>(totalWords.value);
    }
    if (wordsRevealed.present) {
      map['words_revealed'] = Variable<int>(wordsRevealed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleStatsTableCompanion(')
          ..write('id: $id, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('completedAt: $completedAt, ')
          ..write('timeToCompleteSeconds: $timeToCompleteSeconds, ')
          ..write('hintsUsed: $hintsUsed, ')
          ..write('accuracy: $accuracy, ')
          ..write('totalWords: $totalWords, ')
          ..write('wordsRevealed: $wordsRevealed')
          ..write(')'))
        .toString();
  }
}

class $UserAchievementsTableTable extends UserAchievementsTable
    with TableInfo<$UserAchievementsTableTable, UserAchievementsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAchievementsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _achievementIdMeta = const VerificationMeta(
    'achievementId',
  );
  @override
  late final GeneratedColumn<String> achievementId = GeneratedColumn<String>(
    'achievement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [achievementId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_achievements_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAchievementsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('achievement_id')) {
      context.handle(
        _achievementIdMeta,
        achievementId.isAcceptableOrUnknown(
          data['achievement_id']!,
          _achievementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {achievementId};
  @override
  UserAchievementsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAchievementsTableData(
      achievementId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}achievement_id'],
          )!,
      unlockedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}unlocked_at'],
          )!,
    );
  }

  @override
  $UserAchievementsTableTable createAlias(String alias) {
    return $UserAchievementsTableTable(attachedDatabase, alias);
  }
}

class UserAchievementsTableData extends DataClass
    implements Insertable<UserAchievementsTableData> {
  final String achievementId;
  final DateTime unlockedAt;
  const UserAchievementsTableData({
    required this.achievementId,
    required this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['achievement_id'] = Variable<String>(achievementId);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  UserAchievementsTableCompanion toCompanion(bool nullToAbsent) {
    return UserAchievementsTableCompanion(
      achievementId: Value(achievementId),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory UserAchievementsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAchievementsTableData(
      achievementId: serializer.fromJson<String>(json['achievementId']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'achievementId': serializer.toJson<String>(achievementId),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  UserAchievementsTableData copyWith({
    String? achievementId,
    DateTime? unlockedAt,
  }) => UserAchievementsTableData(
    achievementId: achievementId ?? this.achievementId,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );
  UserAchievementsTableData copyWithCompanion(
    UserAchievementsTableCompanion data,
  ) {
    return UserAchievementsTableData(
      achievementId:
          data.achievementId.present
              ? data.achievementId.value
              : this.achievementId,
      unlockedAt:
          data.unlockedAt.present ? data.unlockedAt.value : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievementsTableData(')
          ..write('achievementId: $achievementId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(achievementId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAchievementsTableData &&
          other.achievementId == this.achievementId &&
          other.unlockedAt == this.unlockedAt);
}

class UserAchievementsTableCompanion
    extends UpdateCompanion<UserAchievementsTableData> {
  final Value<String> achievementId;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const UserAchievementsTableCompanion({
    this.achievementId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserAchievementsTableCompanion.insert({
    required String achievementId,
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : achievementId = Value(achievementId);
  static Insertable<UserAchievementsTableData> custom({
    Expression<String>? achievementId,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (achievementId != null) 'achievement_id': achievementId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserAchievementsTableCompanion copyWith({
    Value<String>? achievementId,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return UserAchievementsTableCompanion(
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (achievementId.present) {
      map['achievement_id'] = Variable<String>(achievementId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievementsTableCompanion(')
          ..write('achievementId: $achievementId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
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
  late final $UserStatsTableTable userStatsTable = $UserStatsTableTable(this);
  late final $PuzzleStatsTableTable puzzleStatsTable = $PuzzleStatsTableTable(
    this,
  );
  late final $UserAchievementsTableTable userAchievementsTable =
      $UserAchievementsTableTable(this);
  late final Index puzzlesFilterIdx = Index(
    'puzzles_filter_idx',
    'CREATE INDEX puzzles_filter_idx ON generated_puzzles (difficulty, language)',
  );
  late final Index puzzlesTitleIdx = Index(
    'puzzles_title_idx',
    'CREATE INDEX puzzles_title_idx ON generated_puzzles (title)',
  );
  late final Index puzzleStatsPuzzleIdIdx = Index(
    'puzzle_stats_puzzle_id_idx',
    'CREATE INDEX puzzle_stats_puzzle_id_idx ON puzzle_stats_table (puzzle_id)',
  );
  late final Index puzzleStatsCompletedAtIdx = Index(
    'puzzle_stats_completed_at_idx',
    'CREATE INDEX puzzle_stats_completed_at_idx ON puzzle_stats_table (completed_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    generatedPuzzles,
    puzzleProgress,
    userStatsTable,
    puzzleStatsTable,
    userAchievementsTable,
    puzzlesFilterIdx,
    puzzlesTitleIdx,
    puzzleStatsPuzzleIdIdx,
    puzzleStatsCompletedAtIdx,
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
typedef $$UserStatsTableTableCreateCompanionBuilder =
    UserStatsTableCompanion Function({
      Value<int> id,
      Value<int> totalPuzzlesCompleted,
      Value<int> totalWordsFound,
      Value<int> totalPlayTimeSeconds,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<DateTime?> lastPlayedDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserStatsTableTableUpdateCompanionBuilder =
    UserStatsTableCompanion Function({
      Value<int> id,
      Value<int> totalPuzzlesCompleted,
      Value<int> totalWordsFound,
      Value<int> totalPlayTimeSeconds,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<DateTime?> lastPlayedDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UserStatsTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserStatsTableTable> {
  $$UserStatsTableTableFilterComposer({
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

  ColumnFilters<int> get totalPuzzlesCompleted => $composableBuilder(
    column: $table.totalPuzzlesCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWordsFound => $composableBuilder(
    column: $table.totalWordsFound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPlayTimeSeconds => $composableBuilder(
    column: $table.totalPlayTimeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedDate => $composableBuilder(
    column: $table.lastPlayedDate,
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
}

class $$UserStatsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserStatsTableTable> {
  $$UserStatsTableTableOrderingComposer({
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

  ColumnOrderings<int> get totalPuzzlesCompleted => $composableBuilder(
    column: $table.totalPuzzlesCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWordsFound => $composableBuilder(
    column: $table.totalWordsFound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPlayTimeSeconds => $composableBuilder(
    column: $table.totalPlayTimeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedDate => $composableBuilder(
    column: $table.lastPlayedDate,
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
}

class $$UserStatsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserStatsTableTable> {
  $$UserStatsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get totalPuzzlesCompleted => $composableBuilder(
    column: $table.totalPuzzlesCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalWordsFound => $composableBuilder(
    column: $table.totalWordsFound,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPlayTimeSeconds => $composableBuilder(
    column: $table.totalPlayTimeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPlayedDate => $composableBuilder(
    column: $table.lastPlayedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserStatsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserStatsTableTable,
          UserStatsTableData,
          $$UserStatsTableTableFilterComposer,
          $$UserStatsTableTableOrderingComposer,
          $$UserStatsTableTableAnnotationComposer,
          $$UserStatsTableTableCreateCompanionBuilder,
          $$UserStatsTableTableUpdateCompanionBuilder,
          (
            UserStatsTableData,
            BaseReferences<
              _$AppDatabase,
              $UserStatsTableTable,
              UserStatsTableData
            >,
          ),
          UserStatsTableData,
          PrefetchHooks Function()
        > {
  $$UserStatsTableTableTableManager(
    _$AppDatabase db,
    $UserStatsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UserStatsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$UserStatsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UserStatsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalPuzzlesCompleted = const Value.absent(),
                Value<int> totalWordsFound = const Value.absent(),
                Value<int> totalPlayTimeSeconds = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<DateTime?> lastPlayedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserStatsTableCompanion(
                id: id,
                totalPuzzlesCompleted: totalPuzzlesCompleted,
                totalWordsFound: totalWordsFound,
                totalPlayTimeSeconds: totalPlayTimeSeconds,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastPlayedDate: lastPlayedDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalPuzzlesCompleted = const Value.absent(),
                Value<int> totalWordsFound = const Value.absent(),
                Value<int> totalPlayTimeSeconds = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<DateTime?> lastPlayedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserStatsTableCompanion.insert(
                id: id,
                totalPuzzlesCompleted: totalPuzzlesCompleted,
                totalWordsFound: totalWordsFound,
                totalPlayTimeSeconds: totalPlayTimeSeconds,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastPlayedDate: lastPlayedDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
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

typedef $$UserStatsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserStatsTableTable,
      UserStatsTableData,
      $$UserStatsTableTableFilterComposer,
      $$UserStatsTableTableOrderingComposer,
      $$UserStatsTableTableAnnotationComposer,
      $$UserStatsTableTableCreateCompanionBuilder,
      $$UserStatsTableTableUpdateCompanionBuilder,
      (
        UserStatsTableData,
        BaseReferences<_$AppDatabase, $UserStatsTableTable, UserStatsTableData>,
      ),
      UserStatsTableData,
      PrefetchHooks Function()
    >;
typedef $$PuzzleStatsTableTableCreateCompanionBuilder =
    PuzzleStatsTableCompanion Function({
      Value<int> id,
      required String puzzleId,
      required DateTime completedAt,
      required int timeToCompleteSeconds,
      Value<int> hintsUsed,
      required double accuracy,
      required int totalWords,
      Value<int> wordsRevealed,
    });
typedef $$PuzzleStatsTableTableUpdateCompanionBuilder =
    PuzzleStatsTableCompanion Function({
      Value<int> id,
      Value<String> puzzleId,
      Value<DateTime> completedAt,
      Value<int> timeToCompleteSeconds,
      Value<int> hintsUsed,
      Value<double> accuracy,
      Value<int> totalWords,
      Value<int> wordsRevealed,
    });

class $$PuzzleStatsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PuzzleStatsTableTable> {
  $$PuzzleStatsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeToCompleteSeconds => $composableBuilder(
    column: $table.timeToCompleteSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintsUsed => $composableBuilder(
    column: $table.hintsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWords => $composableBuilder(
    column: $table.totalWords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordsRevealed => $composableBuilder(
    column: $table.wordsRevealed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PuzzleStatsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PuzzleStatsTableTable> {
  $$PuzzleStatsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeToCompleteSeconds => $composableBuilder(
    column: $table.timeToCompleteSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintsUsed => $composableBuilder(
    column: $table.hintsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWords => $composableBuilder(
    column: $table.totalWords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordsRevealed => $composableBuilder(
    column: $table.wordsRevealed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PuzzleStatsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PuzzleStatsTableTable> {
  $$PuzzleStatsTableTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeToCompleteSeconds => $composableBuilder(
    column: $table.timeToCompleteSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hintsUsed =>
      $composableBuilder(column: $table.hintsUsed, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get totalWords => $composableBuilder(
    column: $table.totalWords,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordsRevealed => $composableBuilder(
    column: $table.wordsRevealed,
    builder: (column) => column,
  );
}

class $$PuzzleStatsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PuzzleStatsTableTable,
          PuzzleStatsTableData,
          $$PuzzleStatsTableTableFilterComposer,
          $$PuzzleStatsTableTableOrderingComposer,
          $$PuzzleStatsTableTableAnnotationComposer,
          $$PuzzleStatsTableTableCreateCompanionBuilder,
          $$PuzzleStatsTableTableUpdateCompanionBuilder,
          (
            PuzzleStatsTableData,
            BaseReferences<
              _$AppDatabase,
              $PuzzleStatsTableTable,
              PuzzleStatsTableData
            >,
          ),
          PuzzleStatsTableData,
          PrefetchHooks Function()
        > {
  $$PuzzleStatsTableTableTableManager(
    _$AppDatabase db,
    $PuzzleStatsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$PuzzleStatsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PuzzleStatsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$PuzzleStatsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> puzzleId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> timeToCompleteSeconds = const Value.absent(),
                Value<int> hintsUsed = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<int> totalWords = const Value.absent(),
                Value<int> wordsRevealed = const Value.absent(),
              }) => PuzzleStatsTableCompanion(
                id: id,
                puzzleId: puzzleId,
                completedAt: completedAt,
                timeToCompleteSeconds: timeToCompleteSeconds,
                hintsUsed: hintsUsed,
                accuracy: accuracy,
                totalWords: totalWords,
                wordsRevealed: wordsRevealed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String puzzleId,
                required DateTime completedAt,
                required int timeToCompleteSeconds,
                Value<int> hintsUsed = const Value.absent(),
                required double accuracy,
                required int totalWords,
                Value<int> wordsRevealed = const Value.absent(),
              }) => PuzzleStatsTableCompanion.insert(
                id: id,
                puzzleId: puzzleId,
                completedAt: completedAt,
                timeToCompleteSeconds: timeToCompleteSeconds,
                hintsUsed: hintsUsed,
                accuracy: accuracy,
                totalWords: totalWords,
                wordsRevealed: wordsRevealed,
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

typedef $$PuzzleStatsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PuzzleStatsTableTable,
      PuzzleStatsTableData,
      $$PuzzleStatsTableTableFilterComposer,
      $$PuzzleStatsTableTableOrderingComposer,
      $$PuzzleStatsTableTableAnnotationComposer,
      $$PuzzleStatsTableTableCreateCompanionBuilder,
      $$PuzzleStatsTableTableUpdateCompanionBuilder,
      (
        PuzzleStatsTableData,
        BaseReferences<
          _$AppDatabase,
          $PuzzleStatsTableTable,
          PuzzleStatsTableData
        >,
      ),
      PuzzleStatsTableData,
      PrefetchHooks Function()
    >;
typedef $$UserAchievementsTableTableCreateCompanionBuilder =
    UserAchievementsTableCompanion Function({
      required String achievementId,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });
typedef $$UserAchievementsTableTableUpdateCompanionBuilder =
    UserAchievementsTableCompanion Function({
      Value<String> achievementId,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

class $$UserAchievementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserAchievementsTableTable> {
  $$UserAchievementsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserAchievementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAchievementsTableTable> {
  $$UserAchievementsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserAchievementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAchievementsTableTable> {
  $$UserAchievementsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$UserAchievementsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserAchievementsTableTable,
          UserAchievementsTableData,
          $$UserAchievementsTableTableFilterComposer,
          $$UserAchievementsTableTableOrderingComposer,
          $$UserAchievementsTableTableAnnotationComposer,
          $$UserAchievementsTableTableCreateCompanionBuilder,
          $$UserAchievementsTableTableUpdateCompanionBuilder,
          (
            UserAchievementsTableData,
            BaseReferences<
              _$AppDatabase,
              $UserAchievementsTableTable,
              UserAchievementsTableData
            >,
          ),
          UserAchievementsTableData,
          PrefetchHooks Function()
        > {
  $$UserAchievementsTableTableTableManager(
    _$AppDatabase db,
    $UserAchievementsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UserAchievementsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$UserAchievementsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$UserAchievementsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> achievementId = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserAchievementsTableCompanion(
                achievementId: achievementId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String achievementId,
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserAchievementsTableCompanion.insert(
                achievementId: achievementId,
                unlockedAt: unlockedAt,
                rowid: rowid,
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

typedef $$UserAchievementsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserAchievementsTableTable,
      UserAchievementsTableData,
      $$UserAchievementsTableTableFilterComposer,
      $$UserAchievementsTableTableOrderingComposer,
      $$UserAchievementsTableTableAnnotationComposer,
      $$UserAchievementsTableTableCreateCompanionBuilder,
      $$UserAchievementsTableTableUpdateCompanionBuilder,
      (
        UserAchievementsTableData,
        BaseReferences<
          _$AppDatabase,
          $UserAchievementsTableTable,
          UserAchievementsTableData
        >,
      ),
      UserAchievementsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GeneratedPuzzlesTableTableManager get generatedPuzzles =>
      $$GeneratedPuzzlesTableTableManager(_db, _db.generatedPuzzles);
  $$PuzzleProgressTableTableManager get puzzleProgress =>
      $$PuzzleProgressTableTableManager(_db, _db.puzzleProgress);
  $$UserStatsTableTableTableManager get userStatsTable =>
      $$UserStatsTableTableTableManager(_db, _db.userStatsTable);
  $$PuzzleStatsTableTableTableManager get puzzleStatsTable =>
      $$PuzzleStatsTableTableTableManager(_db, _db.puzzleStatsTable);
  $$UserAchievementsTableTableTableManager get userAchievementsTable =>
      $$UserAchievementsTableTableTableManager(_db, _db.userAchievementsTable);
}
