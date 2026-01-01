import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/continue_playing_section.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

void main() {
  Widget buildTestWidget({required overrides}) {
    return ProviderScope(
      overrides: overrides,
      child: Sizer(
        builder:
            (context, orientation, deviceType) => MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: ContinuePlayingSection()),
            ),
      ),
    );
  }

  testWidgets('shows placeholder when no puzzles in progress', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        overrides: [inProgressPuzzlesProvider.overrideWith((ref) async => [])],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No puzzles in progress'), findsOneWidget);
  });

  testWidgets('renders horizontal ListView of in-progress puzzles', (
    tester,
  ) async {
    final inProgressPuzzles = [
      InProgressPuzzleInfo(
        descriptor: PuzzleDescriptor(
          id: 'puzzle-1',
          title: 'Test Puzzle 1',
          path: 'test/puzzle1.json',
          difficulty: 2,
          difficultyLabel: 'Medium',
        ),
        progress: PuzzleProgress(
          puzzleId: 'puzzle-1',
          savedAt: DateTime.now(),
          elapsedSeconds: 300,
        ),
        completionPercent: 45,
      ),
    ];

    await tester.pumpWidget(
      buildTestWidget(
        overrides: [
          inProgressPuzzlesProvider.overrideWith(
            (ref) async => inProgressPuzzles,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Puzzle 1'), findsOneWidget);
    expect(find.text('45%'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget); // 300s = 5:00
  });

  testWidgets('card shows difficulty badge', (tester) async {
    final inProgressPuzzles = [
      InProgressPuzzleInfo(
        descriptor: PuzzleDescriptor(
          id: 'puzzle-1',
          title: 'Test Puzzle',
          path: 'test/puzzle.json',
          difficulty: 3,
          difficultyLabel: 'Hard',
        ),
        progress: PuzzleProgress(
          puzzleId: 'puzzle-1',
          savedAt: DateTime.now(),
          elapsedSeconds: 300,
        ),
        completionPercent: 50,
      ),
    ];

    await tester.pumpWidget(
      buildTestWidget(
        overrides: [
          inProgressPuzzlesProvider.overrideWith(
            (ref) async => inProgressPuzzles,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HARD'), findsOneWidget); // Uppercased in PuzzleCard
  });
}
