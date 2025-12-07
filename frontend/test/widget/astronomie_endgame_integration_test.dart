import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/crossword_screen.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/core/puzzle_converter.dart';
import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/services/providers.dart';

void main() {
  testWidgets(
    'Completing last prefilled cell in astronomie triggers end overlay',
    (tester) async {
      final jsonString = File(
        'assets/data/astronomie_puzzle.json',
      ).readAsStringSync();
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final puzzle = Puzzle.fromJson(jsonData);

      // Build a prefilled board and then clear exactly one prefilled non-black cell
      var board = PuzzleConverter.puzzleToGameBoard(
        puzzle,
        preFillSolutions: true,
      );
      int? clearR, clearC;
      for (var r = 0; r < board.gridSize; r++) {
        for (var c = 0; c < board.gridSize; c++) {
          if (!board.blackCells[r][c] && board.grid[r][c] != null) {
            clearR = r;
            clearC = c;
            break;
          }
        }
        if (clearR != null) {
          break;
        }
      }
      expect(clearR, isNotNull);
      final missing = board.grid[clearR!][clearC!];
      final newGrid = List<List<String?>>.from(
        board.grid.map(List<String?>.from),
      );
      newGrid[clearR][clearC] = null;
      board = board.copyWith(grid: newGrid);

      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CrosswordScreen()),
        ),
      );

      // Ensure UI settled and controller created
      await tester.pumpAndSettle();

      // Type the missing letter via controller
      final controller = CrosswordInputController.fromContainer(container);
      container.read(selectedCellProvider.notifier).state = SelectedCell(
        clearR,
        clearC,
      );
      controller.setLetterAndAdvance(missing!);

      await tester.pumpAndSettle();
      // Debug: inspect found words vs entries
      final found = container.read(foundWordsProvider);
      final entries = container.read(gameBoardProvider).entries;
      debugPrint('found=${found.length} entries=${entries?.length}');
      // Compute which entries are missing
      final missingKeys = <String>[];
      for (final e in entries!) {
        final key = '${e.y},${e.x},${e.direction}';
        if (!found.contains(key)) {
          missingKeys.add(key);
        }
      }
      debugPrint('missingKeys=$missingKeys');
      if (missingKeys.isNotEmpty) {
        final m = missingKeys.first.split(',');
        final ey = int.parse(m[0]);
        final ex = int.parse(m[1]);
        final edir = m[2];
        final e = entries.firstWhere(
          (en) => en.x == ex && en.y == ey && en.direction == edir,
        );
        final cells = <String?>[];
        final blacks = <bool>[];
        for (var i = 0; i < e.length; i++) {
          final r = edir == 'across' ? ey : ey + i;
          final c = edir == 'across' ? ex + i : ex;
          cells.add(container.read(gameBoardProvider).grid[r][c]);
          blacks.add(container.read(gameBoardProvider).blackCells[r][c]);
        }
        final missingKey = '$ey,$ex,$edir';
        debugPrint('entry $missingKey cells=$cells blacks=$blacks');
        final svc = container.read(wordCheckServiceProvider);
        final isComplete = svc.isWordComplete(
          container.read(gameBoardProvider),
          e,
        );
        debugPrint('svc.isWordComplete($missingKey)=$isComplete');
      }

      // End overlay should be visible
      expect(
        find.text('Bravo !'),
        findsOneWidget,
        reason:
            'Overlay not shown; found=${found.length} entries=${entries.length}',
      );
    },
  );
}
