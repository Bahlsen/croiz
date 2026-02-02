import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/features/statistics/models/puzzle_stat.dart';
import 'package:croiz/features/statistics/models/user_stats.dart';
import 'package:croiz/features/statistics/services/achievement_service.dart';
import 'package:croiz/features/statistics/services/statistics_service.dart';

class FakeStatisticsService implements StatisticsService {
  FakeStatisticsService({
    this.stats = const UserStats(
      totalPuzzlesCompleted: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalPlayTimeSeconds: 0,
    ),
    this.allPuzzles = const [],
  });

  final UserStats stats;
  final List<PuzzleStat> allPuzzles;

  @override
  AchievementService? get achievementService => null;

  @override
  void Function(List<AchievementId>)? get onAchievementsUnlocked => null;

  @override
  Future<UserStats> getOrInitUserStats() async => stats;

  @override
  Stream<UserStats> watchUserStats() => Stream.value(stats);

  @override
  Stream<List<PuzzleStat>> watchRecentCompletions({int limit = 10}) =>
      Stream.value(allPuzzles.take(limit).toList());

  @override
  Future<List<PuzzleStat>> getAllCompletions() async => allPuzzles;

  @override
  Future<void> recordPuzzleCompletion({
    required String puzzleId,
    required int timeSeconds,
    required int totalWords,
    required int wordsFound,
    required int hintsUsed,
    required double accuracy,
    required int wordsRevealed,
  }) async {}
}

class FakeAchievementService implements AchievementService {
  FakeAchievementService(this.unlocked);

  final List<AchievementId> unlocked;

  @override
  Future<List<AchievementId>> getUnlockedAchievements() async => unlocked;

  @override
  Future<List<AchievementId>> checkAchievements(
    UserStats stats,
    PuzzleStat lastPuzzle,
  ) async => [];
}
