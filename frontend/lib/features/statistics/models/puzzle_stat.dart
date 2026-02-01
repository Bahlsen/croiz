import 'package:freezed_annotation/freezed_annotation.dart';

part 'puzzle_stat.freezed.dart';
part 'puzzle_stat.g.dart';

/// Statistics for a single completed puzzle.
@freezed
abstract class PuzzleStat with _$PuzzleStat {
  const factory PuzzleStat({
    /// ID of the puzzle this stat is for
    required String puzzleId,

    /// When the puzzle was completed
    required DateTime completedAt,

    /// Time taken to complete the puzzle (in seconds)
    required int timeToCompleteSeconds,

    /// Total number of words in the puzzle
    required int totalWords,

    /// Unique identifier for this stat record
    int? id,

    /// Number of hints used (words or letters revealed)
    @Default(0) int hintsUsed,

    /// Accuracy: ratio of correct letters on first try (0.0 - 1.0)
    @Default(1) double accuracy,

    /// Number of words that were revealed (not solved by user)
    @Default(0) int wordsRevealed,
  }) = _PuzzleStat;

  const PuzzleStat._();

  factory PuzzleStat.fromJson(Map<String, dynamic> json) =>
      _$PuzzleStatFromJson(json);

  /// Get completion time as a Duration
  Duration get completionTime => Duration(seconds: timeToCompleteSeconds);

  /// Check if this was a perfect puzzle (no hints, 100% accuracy)
  bool get isPerfect => hintsUsed == 0 && accuracy >= 1;

  /// Check if this was a speed run (completed in less than 5 minutes)
  bool get isSpeedRun => timeToCompleteSeconds < 300; // 5 minutes

  /// Get the percentage of words solved without hints
  double get solvedPercentage {
    if (totalWords == 0) {
      return 0;
    }
    return ((totalWords - wordsRevealed) / totalWords) * 100;
  }

  /// Format completion time as MM:SS
  String get formattedTime {
    final duration = completionTime;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
