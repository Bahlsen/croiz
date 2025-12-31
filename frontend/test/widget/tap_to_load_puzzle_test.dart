import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/routes/app_router.dart';
import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tap to load puzzle flow', () {
    testWidgets('tapping a list item loads the puzzle and navigates', (
      WidgetTester tester,
    ) async {
      // Prepare a descriptor with title different from token to avoid metadata load.
      final desc = PuzzleDescriptor(
        id: 'test-0001',
        title: 'Sample Puzzle',
        path: 'testorigin/2020/test-0001.json',
        subtitle: '',
        origin: 'testorigin',
        year: '2020',
      );

      // Override index provider to return our single item immediately.
      final container = ProviderContainer(
        overrides: [
          puzzlesProvider.overrideWithValue(
            AsyncValue.data(<PuzzleDescriptor>[desc]),
          ),
          // Override loader to avoid JSON parsing and return a minimal board.
          puzzleAssetLoaderProvider.overrideWithValue(
            (String assetPath) async => GameBoard(
              id: 'test-0001',
              title: 'Sample Puzzle',
              gridSize: 5,
              createdAt: DateTime.now(),
              grid: List.generate(5, (_) => List<String?>.filled(5, null)),
              clues: <String, String>{},
              blackCells: List.generate(5, (_) => List<bool>.filled(5, false)),
              difficulty: 1,
              entries: const <PuzzleEntryData>[],
              solutionGrid: List.generate(
                5,
                (_) => List<String?>.filled(5, null),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Build the app with router and our container.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Sizer(
            builder: (context, orientation, deviceType) =>
                MaterialApp.router(routerConfig: appRouter),
          ),
        ),
      );

      // Navigate to puzzles list page via shared router instance.
      appRouter.go('/puzzles');
      await tester.pumpAndSettle();

      // Expand origin and year groups to reveal the item.
      expect(find.text('testorigin'), findsOneWidget);
      await tester.tap(find.text('testorigin'));
      await tester.pumpAndSettle();
      expect(find.text('2020'), findsOneWidget);
      await tester.tap(find.text('2020'));
      await tester.pumpAndSettle();
      // Tap the list tile with our sample title.
      expect(find.text('Sample Puzzle'), findsOneWidget);
      await tester.tap(find.text('Sample Puzzle'));
      await tester.pumpAndSettle();

      // Verify navigation occurred to crossword screen by checking the
      // crossword screen widget and that the game board provider loaded.
      expect(find.byType(CrosswordScreen), findsOneWidget);

      // Verify the game board provider loaded our board id.
      final board = container.read(gameBoardProvider);
      expect(board.id, 'test-0001');
    });
  });
}
