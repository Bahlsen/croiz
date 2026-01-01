import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/puzzles/widgets/continue_playing_section.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';

void main() {
  testWidgets('tapping puzzle navigates to /crossword with correct id', (
    tester,
  ) async {
    final inProgressPuzzles = [
      InProgressPuzzleInfo(
        descriptor: PuzzleDescriptor(
          id: 'test-puzzle',
          title: 'Test Puzzle',
          path: 'test/puzzle.json',
        ),
        progress: PuzzleProgress(
          puzzleId: 'test-puzzle',
          savedAt: DateTime.now(),
          elapsedSeconds: 0,
        ),
        completionPercent: 50,
      ),
    ];

    // Router configuration that mimics the app's real router structure.
    // Using this router, navigating to '/game' will fail because it doesn't exist.
    // Navigating to '/crossword?id=test-puzzle' will succeed.
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: ContinuePlayingSection()),
        ),
        GoRoute(
          path: '/crossword',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'];
            return Scaffold(body: Text('Crossword Screen: $id'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inProgressPuzzlesProvider.overrideWith(
            (ref) async => inProgressPuzzles,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Verify card is present
    expect(find.text('Test Puzzle'), findsOneWidget);

    // Tap the card
    await tester.tap(find.text('Test Puzzle'));
    await tester.pumpAndSettle();

    // Expect to be on the Crossword Screen with the correct ID
    expect(find.text('Crossword Screen: test-puzzle'), findsOneWidget);
  });
}
