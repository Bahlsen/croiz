import 'package:croiz/data/db/app_database.dart';
import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/features/statistics/models/puzzle_stat.dart';
import 'package:croiz/features/statistics/models/user_stats.dart';
import 'package:drift/drift.dart';

/// Service for checking and unlocking achievements.
class AchievementService {
  AchievementService(this._db);

  final AppDatabase _db;

  /// Checks for newly unlocked achievements based on updated stats and the latest puzzle.
  /// Returns a list of newly unlocked achievements.
  Future<List<AchievementId>> checkAchievements(
    UserStats stats,
    PuzzleStat lastPuzzle,
  ) async {
    final newUnlocks = <AchievementId>[];

    // Get currently unlocked achievements
    final existingRows = await _db.select(_db.userAchievementsTable).get();
    final existingIds = existingRows.map((r) => r.achievementId).toSet();

    void check(AchievementId id, {required bool condition}) {
      if (condition && !existingIds.contains(id.name)) {
        newUnlocks.add(id);
      }
    }

    // 1. First Puzzle
    check(
      AchievementId.firstPuzzle,
      condition: stats.totalPuzzlesCompleted >= 1,
    );

    // 2. Ten Puzzles
    check(
      AchievementId.tenPuzzles,
      condition: stats.totalPuzzlesCompleted >= 10,
    );

    // 3. Hundred Puzzles
    check(
      AchievementId.hundredPuzzles,
      condition: stats.totalPuzzlesCompleted >= 100,
    );

    // 4. Week Streak (7 days)
    check(AchievementId.weekStreak, condition: stats.currentStreak >= 7);

    // 5. Month Streak (30 days)
    check(AchievementId.monthStreak, condition: stats.currentStreak >= 30);

    // 6. Speed Demon (< 3 mins = 180 seconds) AND no hints used
    check(
      AchievementId.speedDemon,
      condition:
          lastPuzzle.timeToCompleteSeconds < 180 &&
          lastPuzzle.hintsUsed == 0 &&
          lastPuzzle.wordsRevealed == 0,
    );

    // 7. Perfect Puzzle
    // isPerfect checks hintsUsed == 0 and accuracy >= 1
    // We also explicitly check wordsRevealed to be safe
    check(
      AchievementId.perfectPuzzle,
      condition: lastPuzzle.isPerfect && lastPuzzle.wordsRevealed == 0,
    );

    // 8. Generator (Skip for now or check count)
    // 9. Polyglot (Skip for now)

    // Save newly unlocked achievements
    if (newUnlocks.isNotEmpty) {
      final now = DateTime.now();
      await _db.batch((batch) {
        for (final id in newUnlocks) {
          batch.insert(
            _db.userAchievementsTable,
            UserAchievementsTableCompanion.insert(
              achievementId: id.name,
              unlockedAt: Value(now),
            ),
          );
        }
      });
    }

    return newUnlocks;
  }

  /// Get all unlocked achievements
  Future<List<AchievementId>> getUnlockedAchievements() async {
    final rows = await _db.select(_db.userAchievementsTable).get();
    return rows
        .map(
          (r) => AchievementId.values.firstWhere(
            (e) => e.name == r.achievementId,
            orElse: () => AchievementId.firstPuzzle, // Fallback
          ),
        )
        .toList();
  }
}
