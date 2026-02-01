import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/features/statistics/models/puzzle_stat.dart';
import 'package:croiz/features/statistics/models/user_stats.dart';
import 'package:croiz/features/statistics/providers/statistics_providers.dart';
import 'package:croiz/features/statistics/screens/statistics_screen.dart';
import 'package:croiz/features/statistics/services/achievement_service.dart';
import 'package:croiz/features/statistics/services/statistics_service.dart';
import 'package:croiz/features/statistics/widgets/completion_chart.dart';
import 'package:croiz/features/statistics/widgets/stats_summary_card.dart';
import 'package:croiz/features/statistics/widgets/streak_calendar.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class FakeStatisticsService implements StatisticsService {
  FakeStatisticsService(this.stats, this.allPuzzles);

  final UserStats stats;
  final List<PuzzleStat> allPuzzles;

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
  AchievementService? get achievementService => null;

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

void main() {
  testWidgets('StatisticsScreen renders correctly with data', (tester) async {
    // Mock data
    const mockUserStats = UserStats(
      totalPuzzlesCompleted: 10,
      currentStreak: 5,
      longestStreak: 7,
      totalPlayTimeSeconds: 3600,
    );

    final mockAllCompletions = <PuzzleStat>[
      PuzzleStat(
        puzzleId: 'p1',
        completedAt: DateTime.now(),
        timeToCompleteSeconds: 60,
        accuracy: 1,
        totalWords: 10,
        id: 1,
      ),
    ];
    final mockUnlocked = [AchievementId.firstPuzzle];

    final fakeStatsService = FakeStatisticsService(
      mockUserStats,
      mockAllCompletions,
    );
    final fakeAchievementService = FakeAchievementService(mockUnlocked);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsServiceProvider.overrideWith((ref) => fakeStatsService),
          achievementServiceProvider.overrideWith(
            (ref) => fakeAchievementService,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Sizer(
            builder:
                (context, orientation, deviceType) => const StatisticsScreen(),
          ),
        ),
      ),
    );

    // Initial loading
    await tester.pump();
    // Finish animations/futures
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Statistics'), findsOneWidget);

    // Verify Summary Cards
    expect(find.byType(StatsSummaryCard), findsNWidgets(4));
    expect(find.text('10'), findsOneWidget); // Total puzzles
    expect(find.text('5 Days'), findsOneWidget); // Current streak

    // Verify Achievements
    expect(find.text('Achievements'), findsOneWidget);

    // Verify Charts
    expect(find.byType(StreakCalendar), findsOneWidget);
    expect(find.byType(CompletionChart), findsOneWidget);
  });
}
