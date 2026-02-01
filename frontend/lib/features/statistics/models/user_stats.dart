import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_stats.freezed.dart';
part 'user_stats.g.dart';

/// User statistics model tracking overall game progress and achievements.
@freezed
abstract class UserStats with _$UserStats {
  const factory UserStats({
    /// Unique identifier for the stats record (usually 1)
    @Default(1) int id,

    /// Total number of puzzles completed
    @Default(0) int totalPuzzlesCompleted,

    /// Total number of words found across all puzzles
    @Default(0) int totalWordsFound,

    /// Total play time in seconds
    @Default(0) int totalPlayTimeSeconds,

    /// Current consecutive days streak
    @Default(0) int currentStreak,

    /// Longest consecutive days streak ever achieved
    @Default(0) int longestStreak,

    /// Last date the user played
    DateTime? lastPlayedDate,

    /// Date when stats were created
    DateTime? createdAt,

    /// Date when stats were last updated
    DateTime? updatedAt,
  }) = _UserStats;

  const UserStats._();

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  /// Get total play time as a Duration
  Duration get totalPlayTime => Duration(seconds: totalPlayTimeSeconds);

  /// Get average completion time per puzzle
  Duration get averageCompletionTime {
    if (totalPuzzlesCompleted == 0) {
      return Duration.zero;
    }
    return Duration(seconds: totalPlayTimeSeconds ~/ totalPuzzlesCompleted);
  }

  /// Check if the user played today
  bool get playedToday {
    if (lastPlayedDate == null) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPlayed = DateTime(
      lastPlayedDate!.year,
      lastPlayedDate!.month,
      lastPlayedDate!.day,
    );
    return today == lastPlayed;
  }

  /// Check if the streak should be broken (more than 1 day since last play)
  bool get streakBroken {
    if (lastPlayedDate == null) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPlayed = DateTime(
      lastPlayedDate!.year,
      lastPlayedDate!.month,
      lastPlayedDate!.day,
    );
    final difference = today.difference(lastPlayed).inDays;
    return difference > 1;
  }
}
