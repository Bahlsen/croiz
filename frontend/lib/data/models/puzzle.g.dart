// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Puzzle _$PuzzleFromJson(Map<String, dynamic> json) => Puzzle(
  id: json['id'] as String,
  rows: (json['rows'] as num).toInt(),
  cols: (json['cols'] as num).toInt(),
  cells: (json['cells'] as List<dynamic>)
      .map((e) => PuzzleCell.fromJson(e as Map<String, dynamic>))
      .toList(),
  entries: (json['entries'] as List<dynamic>)
      .map((e) => PuzzleEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  version: json['version'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  extras: json['extras'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PuzzleToJson(Puzzle instance) => <String, dynamic>{
  'id': instance.id,
  'version': instance.version,
  'metadata': instance.metadata,
  'rows': instance.rows,
  'cols': instance.cols,
  'cells': instance.cells.map((e) => e.toJson()).toList(),
  'entries': instance.entries.map((e) => e.toJson()).toList(),
  'extras': instance.extras,
};
