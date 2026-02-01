import 'package:croiz/data/db/database_provider.dart';
import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/features/statistics/models/puzzle_stat.dart';
import 'package:croiz/features/statistics/models/user_stats.dart';
import 'package:croiz/features/statistics/services/achievement_service.dart';
import 'package:croiz/features/statistics/services/statistics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_providers.g.dart';

/// Provider for the AchievementService instance.
@Riverpod(keepAlive: true, dependencies: [appDatabase])
AchievementService achievementService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return AchievementService(db);
}

/// Provider for the StatisticsService instance.
@Riverpod(keepAlive: true, dependencies: [appDatabase, achievementService])
StatisticsService statisticsService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final achievements = ref.watch(achievementServiceProvider);
  return StatisticsService(db, achievementService: achievements);
}

/// Provider for all unlocked achievements.
@Riverpod(dependencies: [achievementService])
Future<List<AchievementId>> unlockedAchievements(Ref ref) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getUnlockedAchievements();
}

/// Provider for the global UserStats.
/// Refreshes automatically whenever stats are updated.
@Riverpod(keepAlive: true, dependencies: [statisticsService])
class UserStatsNotifier extends _$UserStatsNotifier {
  @override
  Future<UserStats> build() async {
    final service = ref.watch(statisticsServiceProvider);
    return service.getOrInitUserStats();
  }

  /// Manually refresh stats (e.g., after recording a completion).
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      final service = ref.read(statisticsServiceProvider);
      return service.getOrInitUserStats();
    });
  }
}

/// Stream provider for recent puzzle completions.
@Riverpod(dependencies: [statisticsService])
Stream<List<PuzzleStat>> recentCompletions(Ref ref, {int limit = 10}) {
  final service = ref.watch(statisticsServiceProvider);
  return service.watchRecentCompletions(limit: limit);
}

/// Future provider for all puzzle completions (useful for calendar).
@Riverpod(dependencies: [statisticsService])
Future<List<PuzzleStat>> allCompletions(Ref ref) async {
  final service = ref.watch(statisticsServiceProvider);
  return service.getAllCompletions();
}
