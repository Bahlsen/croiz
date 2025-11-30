// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuzzleEntry _$PuzzleEntryFromJson(Map<String, dynamic> json) => PuzzleEntry(
  number: (json['number'] as num).toInt(),
  direction: json['direction'] as String,
  x: (json['x'] as num).toInt(),
  y: (json['y'] as num).toInt(),
  length: (json['length'] as num).toInt(),
  id: json['id'] as String?,
  answer: json['answer'] as String?,
  clue: json['clue'] as String?,
  enumeration: json['enumeration'] as String?,
  rebusMap: (json['rebusMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  multiSolution: (json['multiSolution'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  annotations: json['annotations'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PuzzleEntryToJson(PuzzleEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'direction': instance.direction,
      'x': instance.x,
      'y': instance.y,
      'length': instance.length,
      'answer': instance.answer,
      'clue': instance.clue,
      'enumeration': instance.enumeration,
      'rebusMap': instance.rebusMap,
      'multiSolution': instance.multiSolution,
      'annotations': instance.annotations,
    };
