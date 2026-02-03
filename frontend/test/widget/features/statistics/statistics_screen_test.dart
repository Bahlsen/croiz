import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/features/statistics/models/puzzle_stat.dart';
import 'package:croiz/features/statistics/models/user_stats.dart';
import 'package:croiz/features/statistics/providers/statistics_providers.dart';
import 'package:croiz/features/statistics/screens/statistics_screen.dart';
import 'package:croiz/features/statistics/widgets/achievement_badge.dart';
import 'package:croiz/features/statistics/widgets/stats_summary_card.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import '../../../helpers/fake_statistics_service.dart';

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
        puzzleId: 'p12345678',
        completedAt: DateTime.now(),
        timeToCompleteSeconds: 60,
        accuracy: 1,
        totalWords: 10,
        id: 1,
      ),
    ];
    final mockUnlocked = [AchievementId.firstPuzzle];

    final fakeStatsService = FakeStatisticsService(
      stats: mockUserStats,
      allPuzzles: mockAllCompletions,
    );
    final fakeAchievementService = FakeAchievementService(mockUnlocked);

    // Initial loading
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

    // Set a realistic screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pump();
    // Finish animations/futures - use pump with duration because of repeating animations (shimmer)
    await tester.pump(const Duration(seconds: 3));

    // Verify Title
    expect(find.text('Statistics'), findsOneWidget);

    // Verify Summary Cards
    expect(find.byType(StatsSummaryCard), findsNWidgets(4));
    expect(find.text('10'), findsOneWidget); // Total puzzles
    expect(find.text('5 Days'), findsOneWidget); // Current streak

    // Verify Achievements Section
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.byType(AchievementBadge), findsWidgets);

    // Verify Recent Completions Section
    expect(find.text('Recent Completions'), findsOneWidget);
    // Check for the mock puzzle ID substring used in UI
    expect(find.textContaining('Puzzle p1234567'), findsOneWidget);
    // Check for accuracy text
    expect(find.textContaining('100%'), findsOneWidget);
  });

  testWidgets('StatisticsScreen shows empty state for recent completions', (
    tester,
  ) async {
    // Mock data with empty completions
    const mockUserStats = UserStats(
      totalPuzzlesCompleted: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalPlayTimeSeconds: 0,
    );

    final fakeStatsService = FakeStatisticsService(
      stats: mockUserStats,
      allPuzzles: [],
    );
    final fakeAchievementService = FakeAchievementService([]);

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

    // Set a realistic screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    // Verify Empty State Message
    expect(find.text('No puzzles completed yet!'), findsOneWidget);
    expect(find.text('Recent Completions'), findsOneWidget);
  });
}
