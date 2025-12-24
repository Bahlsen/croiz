import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('Selecting a puzzle loads board and navigates', (tester) async {
    final sample = [
      PuzzleDescriptor(
        id: 'sample1',
        title: 'Sample',
        path: 'assets/data/sample1.json',
      ),
    ];

    final fakeBoard = GameBoard(
      id: 'sample1',
      title: 'Sample',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: List.generate(3, (_) => List<String?>.filled(3, null)),
      clues: {},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 1,
    );
    fakeBoard.grid[0][0] = 'A';

    final router = GoRouter(
      initialLocation: '/puzzles',
      routes: [
        GoRoute(
          path: '/puzzles',
          builder: (context, state) => const PuzzlesListPage(),
        ),
        GoRoute(
          path: '/crossword',
          builder: (context, state) =>
              CrosswordScreen(puzzleId: state.uri.queryParameters['id']),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWithValue(AsyncValue.data(sample)),
          puzzleAssetLoaderProvider.overrideWithValue(
            (String path) async => fakeBoard,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    // Expand nested origin/year tiles to reveal the puzzle
    await tester.tap(find.text('unknown').at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('unknown').at(1));
    await tester.pumpAndSettle();

    expect(find.text('Sample'), findsOneWidget);

    await tester.tap(find.text('Sample'));
    await tester.pumpAndSettle();

    // Verify we navigated to the crossword screen and grid is visible
    expect(find.byType(CrosswordScreen), findsOneWidget);
    expect(find.text('A'), findsWidgets);
  });
}
