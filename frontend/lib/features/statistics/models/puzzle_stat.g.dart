// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PuzzleStat _$PuzzleStatFromJson(Map<String, dynamic> json) => _PuzzleStat(
  puzzleId: json['puzzleId'] as String,
  completedAt: DateTime.parse(json['completedAt'] as String),
  timeToCompleteSeconds: (json['timeToCompleteSeconds'] as num).toInt(),
  totalWords: (json['totalWords'] as num).toInt(),
  id: (json['id'] as num?)?.toInt(),
  hintsUsed: (json['hintsUsed'] as num?)?.toInt() ?? 0,
  accuracy: (json['accuracy'] as num?)?.toDouble() ?? 1,
  wordsRevealed: (json['wordsRevealed'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PuzzleStatToJson(_PuzzleStat instance) =>
    <String, dynamic>{
      'puzzleId': instance.puzzleId,
      'completedAt': instance.completedAt.toIso8601String(),
      'timeToCompleteSeconds': instance.timeToCompleteSeconds,
      'totalWords': instance.totalWords,
      'id': instance.id,
      'hintsUsed': instance.hintsUsed,
      'accuracy': instance.accuracy,
      'wordsRevealed': instance.wordsRevealed,
    };
