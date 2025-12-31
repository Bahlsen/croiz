import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/continue_playing_section.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';

void main() {
  testWidgets('shows placeholder when no puzzles in progress', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inProgressPuzzlesProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ContinuePlayingSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should show empty state or nothing
    expect(find.text('No puzzles in progress'), findsOneWidget);
  });

  testWidgets('renders horizontal ListView of in-progress puzzles',
      (tester) async {
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
      InProgressPuzzleInfo(
        descriptor: PuzzleDescriptor(
          id: 'puzzle-2',
          title: 'Test Puzzle 2',
          path: 'test/puzzle2.json',
          difficulty: 3,
          difficultyLabel: 'Hard',
        ),
        progress: PuzzleProgress(
          puzzleId: 'puzzle-2',
          savedAt: DateTime.now().subtract(const Duration(hours: 1)),
          elapsedSeconds: 600,
        ),
        completionPercent: 75,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inProgressPuzzlesProvider.overrideWith(
            (ref) async => inProgressPuzzles,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ContinuePlayingSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should show both puzzles
    expect(find.text('Test Puzzle 1'), findsOneWidget);
    expect(find.text('Test Puzzle 2'), findsOneWidget);
  });

  testWidgets('card shows progress percentage', (tester) async {
    final inProgressPuzzles = [
      InProgressPuzzleInfo(
        descriptor: PuzzleDescriptor(
          id: 'puzzle-1',
          title: 'Test Puzzle',
          path: 'test/puzzle.json',
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
      ProviderScope(
        overrides: [
          inProgressPuzzlesProvider.overrideWith(
            (ref) async => inProgressPuzzles,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ContinuePlayingSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should show progress percentage
    expect(find.text('45%'), findsOneWidget);
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
      ProviderScope(
        overrides: [
          inProgressPuzzlesProvider.overrideWith(
            (ref) async => inProgressPuzzles,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ContinuePlayingSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should show difficulty label
    expect(find.text('Hard'), findsOneWidget);
  });

  testWidgets('card shows elapsed time', (tester) async {
    final inProgressPuzzles = [
      InProgressPuzzleInfo(
        descriptor: PuzzleDescriptor(
          id: 'puzzle-1',
          title: 'Test Puzzle',
          path: 'test/puzzle.json',
        ),
        progress: PuzzleProgress(
          puzzleId: 'puzzle-1',
          savedAt: DateTime.now(),
          elapsedSeconds: 754, // 12:34
        ),
        completionPercent: 50,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inProgressPuzzlesProvider.overrideWith(
            (ref) async => inProgressPuzzles,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ContinuePlayingSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should show time in mm:ss format
    expect(find.text('12:34'), findsOneWidget);
  });

  testWidgets('puzzles sorted by savedAt descending (newest first)',
      (tester) async {
    final now = DateTime.now();
    final inProgressPuzzles = [
      InProgressPuzzleInfo(
        descriptor: PuzzleDescriptor(
          id: 'newest',
          title: 'Newest Puzzle',
          path: 'test/newest.json',
        ),
        progress: PuzzleProgress(
          puzzleId: 'newest',
          savedAt: now,
          elapsedSeconds: 100,
        ),
        completionPercent: 30,
      ),
      InProgressPuzzleInfo(
        descriptor: PuzzleDescriptor(
          id: 'oldest',
          title: 'Oldest Puzzle',
          path: 'test/oldest.json',
        ),
        progress: PuzzleProgress(
          puzzleId: 'oldest',
          savedAt: now.subtract(const Duration(days: 7)),
          elapsedSeconds: 500,
        ),
        completionPercent: 80,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inProgressPuzzlesProvider.overrideWith(
            (ref) async => inProgressPuzzles,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ContinuePlayingSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Both should be visible
    expect(find.text('Newest Puzzle'), findsOneWidget);
    expect(find.text('Oldest Puzzle'), findsOneWidget);

    // Verify order by checking widget positions
    final newestCenter = tester.getCenter(find.text('Newest Puzzle'));
    final oldestCenter = tester.getCenter(find.text('Oldest Puzzle'));
    // In a horizontal list, newest should be to the left (smaller x)
    expect(newestCenter.dx, lessThan(oldestCenter.dx));
  });
}
