import 'package:croiz/data/db/app_database.dart';
import 'package:croiz/features/statistics/models/puzzle_stat.dart';
import 'package:croiz/features/statistics/models/user_stats.dart';
import 'package:croiz/features/statistics/services/achievement_service.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';

/// Service responsible for managing user and puzzle statistics.
class StatisticsService {
  StatisticsService(this._db, {this.achievementService});

  final AppDatabase _db;
  final AchievementService? achievementService;
  final Logger _logger = Logger();

  /// Loads the global user statistics.
  /// If no stats record exists, it creates a default one.
  Future<UserStats> getOrInitUserStats() async {
    try {
      final record =
          await (_db.select(_db.userStatsTable)
            ..where((t) => t.id.equals(1))).getSingleOrNull();

      if (record != null) {
        return UserStats(
          id: record.id,
          totalPuzzlesCompleted: record.totalPuzzlesCompleted,
          totalWordsFound: record.totalWordsFound,
          totalPlayTimeSeconds: record.totalPlayTimeSeconds,
          currentStreak: record.currentStreak,
          longestStreak: record.longestStreak,
          lastPlayedDate: record.lastPlayedDate,
          createdAt: record.createdAt,
          updatedAt: record.updatedAt,
        );
      } else {
        // Create initial record
        final now = DateTime.now();
        final initialId = await _db
            .into(_db.userStatsTable)
            .insert(
              UserStatsTableCompanion.insert(
                totalPuzzlesCompleted: const Value(0),
                totalWordsFound: const Value(0),
                totalPlayTimeSeconds: const Value(0),
                currentStreak: const Value(0),
                longestStreak: const Value(0),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
        return UserStats(id: initialId, createdAt: now, updatedAt: now);
      }
    } on Object catch (e) {
      _logger.e('Error loading UserStats', error: e);
      return const UserStats(); // Fallback
    }
  }

  /// Records a completed puzzle and updates global stats.
  Future<void> recordPuzzleCompletion({
    required String puzzleId,
    required int timeSeconds,
    required int totalWords,
    required int wordsFound,
    required int hintsUsed,
    required double accuracy,
    required int wordsRevealed,
  }) async {
    try {
      final now = DateTime.now();

      // 1. Save individual puzzle stat
      final puzzleStat = PuzzleStat(
        puzzleId: puzzleId,
        completedAt: now,
        timeToCompleteSeconds: timeSeconds,
        hintsUsed: hintsUsed,
        accuracy: accuracy,
        totalWords: totalWords,
        wordsRevealed: wordsRevealed,
      );

      await _db
          .into(_db.puzzleStatsTable)
          .insert(
            PuzzleStatsTableCompanion.insert(
              puzzleId: puzzleId,
              completedAt: now,
              timeToCompleteSeconds: timeSeconds,
              hintsUsed: Value(hintsUsed),
              accuracy: accuracy,
              totalWords: totalWords,
              wordsRevealed: Value(wordsRevealed),
            ),
          );

      // 2. Update global stats
      final currentStats = await getOrInitUserStats();

      // Update streak
      var newStreak = currentStats.currentStreak;
      var newLongest = currentStats.longestStreak;

      final today = DateTime(now.year, now.month, now.day);
      final lastPlay =
          currentStats.lastPlayedDate != null
              ? DateTime(
                currentStats.lastPlayedDate!.year,
                currentStats.lastPlayedDate!.month,
                currentStats.lastPlayedDate!.day,
              )
              : null;

      if (lastPlay == null) {
        newStreak = 1;
      } else if (today == lastPlay) {
        // Already played today, streak remains same
      } else if (today.difference(lastPlay).inDays == 1) {
        // Consecutive day
        newStreak++;
      } else {
        // Streak broken
        newStreak = 1;
      }

      if (newStreak > newLongest) {
        newLongest = newStreak;
      }

      final updatedUserStats = UserStats(
        id: currentStats.id, // ID remains same
        totalPuzzlesCompleted: currentStats.totalPuzzlesCompleted + 1,
        totalWordsFound: currentStats.totalWordsFound + wordsFound,
        totalPlayTimeSeconds: currentStats.totalPlayTimeSeconds + timeSeconds,
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastPlayedDate: now,
        createdAt: currentStats.createdAt,
        updatedAt: now,
      );

      await (_db.update(_db.userStatsTable)
        ..where((t) => t.id.equals(1))).write(
        UserStatsTableCompanion(
          totalPuzzlesCompleted: Value(updatedUserStats.totalPuzzlesCompleted),
          totalWordsFound: Value(updatedUserStats.totalWordsFound),
          totalPlayTimeSeconds: Value(updatedUserStats.totalPlayTimeSeconds),
          currentStreak: Value(updatedUserStats.currentStreak),
          longestStreak: Value(updatedUserStats.longestStreak),
          lastPlayedDate: Value<DateTime?>(now),
          updatedAt: Value<DateTime>(now),
        ),
      );

      // Check achievements
      if (achievementService != null) {
        final newAchievements = await achievementService!.checkAchievements(
          updatedUserStats,
          puzzleStat,
        );
        if (newAchievements.isNotEmpty) {
          _logger.i('Unlocked achievements: $newAchievements');
          // In future, we could return this list or emit it via a stream
        }
      }

      _logger.i('Puzzle completion recorded successfully.');
    } on Object catch (e) {
      _logger.e('Error recording puzzle completion', error: e);
    }
  }

  /// Returns a stream of the latest puzzle completions.
  Stream<List<PuzzleStat>> watchRecentCompletions({int limit = 10}) =>
      (_db.select(_db.puzzleStatsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
            ..limit(limit))
          .watch()
          .map(
            (rows) =>
                rows
                    .map(
                      (r) => PuzzleStat(
                        id: r.id,
                        puzzleId: r.puzzleId,
                        completedAt: r.completedAt,
                        timeToCompleteSeconds: r.timeToCompleteSeconds,
                        hintsUsed: r.hintsUsed,
                        accuracy: r.accuracy,
                        totalWords: r.totalWords,
                        wordsRevealed: r.wordsRevealed,
                      ),
                    )
                    .toList(),
          );

  /// Returns all puzzle completions for heatmap/calendar.
  Future<List<PuzzleStat>> getAllCompletions() async =>
      (await _db.select(_db.puzzleStatsTable).get())
          .map(
            (r) => PuzzleStat(
              id: r.id,
              puzzleId: r.puzzleId,
              completedAt: r.completedAt,
              timeToCompleteSeconds: r.timeToCompleteSeconds,
              hintsUsed: r.hintsUsed,
              accuracy: r.accuracy,
              totalWords: r.totalWords,
              wordsRevealed: r.wordsRevealed,
            ),
          )
          .toList();
}
