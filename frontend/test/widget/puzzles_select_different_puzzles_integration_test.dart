import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Selecting different puzzles loads different boards', (
    tester,
  ) async {
    final puzzles = [
      PuzzleDescriptor(
        id: 'p1',
        title: 'Puzzle 1',
        path: 'assets/data/p1.json',
      ),
      PuzzleDescriptor(
        id: 'p2',
        title: 'Puzzle 2',
        path: 'assets/data/p2.json',
      ),
    ];

    GameBoard boardWithLetter(String id, String letter) {
      final board = GameBoard(
        id: id,
        title: id,
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: List.generate(3, (_) => List<String?>.filled(3, null)),
        clues: const {},
        blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
        difficulty: 1,
      );
      board.grid[0][0] = letter;
      return board;
    }

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
          puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          puzzleAssetLoaderProvider.overrideWithValue((String assetPath) async {
            if (assetPath.endsWith('/p1.json')) {
              return boardWithLetter('p1', 'A');
            }
            if (assetPath.endsWith('/p2.json')) {
              return boardWithLetter('p2', 'B');
            }
            throw StateError('Unexpected assetPath=$assetPath');
          }),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    // Expand nested origin/year tiles to reveal puzzles
    await tester.tap(find.text('unknown').at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('unknown').at(1));
    await tester.pumpAndSettle();

    // Select first puzzle.
    await tester.tap(find.text('Puzzle 1'));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsWidgets);

    // Go back to list.
    await tester.tap(find.byTooltip('Puzzles'));
    await tester.pumpAndSettle();
    expect(find.text('Puzzles'), findsOneWidget);
    // Re-expand nested tiles to reveal puzzles again, then select second puzzle.
    await tester.tap(find.text('unknown').at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('unknown').at(1));
    await tester.pumpAndSettle();

    // Select second puzzle.
    await tester.tap(find.text('Puzzle 2'));
    await tester.pumpAndSettle();
    expect(find.text('B'), findsWidgets);
  });
}
