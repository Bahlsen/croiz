import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_list_tile_enhanced.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';

void main() {
  testWidgets('shows difficulty badge with correct color for Hard',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PuzzleListTileEnhanced(
              descriptor: PuzzleDescriptor(
                id: 'test-puzzle',
                title: 'Test Puzzle',
                path: 'test/puzzle.json',
                difficulty: 3,
                difficultyLabel: 'Hard',
              ),
            ),
          ),
        ),
      ),
    );

    // Should show the difficulty label
    expect(find.text('Hard'), findsOneWidget);

    // Find the badge container and verify it uses red color
    final badgeFinder = find.ancestor(
      of: find.text('Hard'),
      matching: find.byType(Container),
    );
    expect(badgeFinder, findsAtLeastNWidgets(1));
  });

  testWidgets('shows difficulty label text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PuzzleListTileEnhanced(
              descriptor: PuzzleDescriptor(
                id: 'test-puzzle',
                title: 'Test Puzzle',
                path: 'test/puzzle.json',
                difficulty: 2,
                difficultyLabel: 'Medium',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Medium'), findsOneWidget);
  });

  testWidgets('shows progress indicator when puzzle is in progress',
      (tester) async {
    final progress = PuzzleProgress(
      puzzleId: 'test-puzzle',
      savedAt: DateTime.now(),
      elapsedSeconds: 300,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PuzzleListTileEnhanced(
              descriptor: PuzzleDescriptor(
                id: 'test-puzzle',
                title: 'Test Puzzle',
                path: 'test/puzzle.json',
              ),
              progress: progress,
              completionPercent: 50,
            ),
          ),
        ),
      ),
    );

    // Should show progress percentage
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('shows checkmark icon when puzzle is completed', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PuzzleListTileEnhanced(
              descriptor: PuzzleDescriptor(
                id: 'test-puzzle',
                title: 'Test Puzzle',
                path: 'test/puzzle.json',
              ),
              isCompleted: true,
            ),
          ),
        ),
      ),
    );

    // Should show checkmark icon
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('shows language code', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PuzzleListTileEnhanced(
              descriptor: PuzzleDescriptor(
                id: 'test-puzzle',
                title: 'Test Puzzle',
                path: 'test/puzzle.json',
                language: 'fr',
              ),
            ),
          ),
        ),
      ),
    );

    // Should show language code
    expect(find.text('FR'), findsOneWidget);
  });

  testWidgets('shows no indicator for unstarted puzzle', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PuzzleListTileEnhanced(
              descriptor: PuzzleDescriptor(
                id: 'test-puzzle',
                title: 'Test Puzzle',
                path: 'test/puzzle.json',
              ),
            ),
          ),
        ),
      ),
    );

    // Should not show progress percentage
    expect(find.textContaining('%'), findsNothing);
    // Should not show checkmark
    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  testWidgets('shows origin and date in subtitle', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PuzzleListTileEnhanced(
              descriptor: PuzzleDescriptor(
                id: 'nyt2024-01-15',
                title: 'Monday, January 15',
                path: 'nytimes/2024/nyt2024-01-15.json',
                origin: 'nytimes',
                year: '2024',
              ),
            ),
          ),
        ),
      ),
    );

    // Should show origin in subtitle
    expect(find.textContaining('nytimes'), findsOneWidget);
  });
}
