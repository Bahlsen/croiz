// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_cell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuzzleCell _$PuzzleCellFromJson(Map<String, dynamic> json) => PuzzleCell(
  x: (json['x'] as num).toInt(),
  y: (json['y'] as num).toInt(),
  isBlack: json['is_black'] as bool? ?? false,
  solution: json['solution'] as String?,
  state: json['state'] as String?,
  rebus: json['rebus'] as String?,
  circled: json['circled'] as bool?,
  shaded: json['shaded'] as bool?,
  barredLeft: json['barredLeft'] as bool?,
  barredTop: json['barredTop'] as bool?,
  annotations: json['annotations'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PuzzleCellToJson(PuzzleCell instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'is_black': instance.isBlack,
      'solution': instance.solution,
      'state': instance.state,
      'rebus': instance.rebus,
      'circled': instance.circled,
      'shaded': instance.shaded,
      'barredLeft': instance.barredLeft,
      'barredTop': instance.barredTop,
      'annotations': instance.annotations,
    };
