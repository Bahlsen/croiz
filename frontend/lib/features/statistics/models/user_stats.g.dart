// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserStats _$UserStatsFromJson(Map<String, dynamic> json) => _UserStats(
  id: (json['id'] as num?)?.toInt() ?? 1,
  totalPuzzlesCompleted: (json['totalPuzzlesCompleted'] as num?)?.toInt() ?? 0,
  totalWordsFound: (json['totalWordsFound'] as num?)?.toInt() ?? 0,
  totalPlayTimeSeconds: (json['totalPlayTimeSeconds'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  lastPlayedDate:
      json['lastPlayedDate'] == null
          ? null
          : DateTime.parse(json['lastPlayedDate'] as String),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserStatsToJson(_UserStats instance) =>
    <String, dynamic>{
      'id': instance.id,
      'totalPuzzlesCompleted': instance.totalPuzzlesCompleted,
      'totalWordsFound': instance.totalWordsFound,
      'totalPlayTimeSeconds': instance.totalPlayTimeSeconds,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastPlayedDate': instance.lastPlayedDate?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
