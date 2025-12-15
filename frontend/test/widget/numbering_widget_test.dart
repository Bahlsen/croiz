import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';
import 'package:croiz/features/game/game_providers.dart';

void main() {
  group('Crossword numbering from entries', () {
    testWidgets('does not require entries for every potential start cell', (
      tester,
    ) async {
      // Minimal 2x2 grid: valid entry only for across at (0,0); down at (0,0) has no entry.
      const size = 2;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final black = List.generate(size, (_) => List<bool>.filled(size, false));
      final entries = <PuzzleEntryData>[
        const PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 0,
          y: 0,
          length: 2,
          clue: 'a',
        ),
      ];

      final board = GameBoard(
        id: 'mini',
        title: 'Mini',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: black,
        difficulty: 1,
        entries: entries,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          ],
          child: const MaterialApp(home: Scaffold(body: CrosswordGrid())),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not throw when entries map numbers by coordinates only', (
      tester,
    ) async {
      const size = 2;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final black = List.generate(size, (_) => List<bool>.filled(size, false));
      // No blacks; mapping should be direct at entry coordinates.
      final entries = <PuzzleEntryData>[
        const PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 1,
          y: 0,
          length: 1,
          clue: 'coord-only',
        ),
      ];
      final board = GameBoard(
        id: 'ok',
        title: 'OK',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: black,
        difficulty: 1,
        entries: entries,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          ],
          child: const MaterialApp(home: Scaffold(body: CrosswordGrid())),
        ),
      );

      // Expect no exception under coordinate-only mapping
      expect(tester.takeException(), isNull);
    });

    // Normalization test removed: numbering now uses entry coordinates directly.
  });
}
