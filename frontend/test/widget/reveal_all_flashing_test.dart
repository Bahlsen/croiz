import 'package:croiz/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_board_provider.dart';
import 'package:croiz/features/game/providers/game_state_providers.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';

void main() {
  testWidgets(
    'Reveal one word then revealAll only flashes newly revealed words',
    (WidgetTester tester) async {
      const entries = [
        PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 0,
          y: 0,
          length: 3,
          answer: 'CAT',
        ),
        PuzzleEntryData(
          number: 2,
          direction: 'across',
          x: 0,
          y: 1,
          length: 3,
          answer: 'DOG',
        ),
      ];

      final board = GameBoard(
        id: 'test',
        title: 't',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          [null, null, null],
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
        difficulty: 1,
        entries: entries,
        solutionGrid: [
          ['C', 'A', 'T'],
          ['D', 'O', 'G'],
          [null, null, null],
        ],
      );

      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          flashClearDelayProvider.overrideWithValue(const Duration(seconds: 5)),
        ],
      );
      addTearDown(container.dispose);

      container.read(gameBoardProvider.notifier).setBoard(board);
      try {
        container.read(gameAudioMutedProvider.notifier).setMuted(muted: true);
      } on Object {
        // audio not available in test environment
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: Center(child: SizedBox())),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Reveal first entry
      container.read(gameBoardProvider.notifier).revealEntry(entries[0]);
      await tester.pumpAndSettle();

      final entry1 = {
        const CellKey(0, 0),
        const CellKey(0, 1),
        const CellKey(0, 2),
      };
      expect(container.read(flashingCellsProvider).containsAll(entry1), isTrue);

      // Now reveal all, only entry2 should flash
      container.read(gameBoardProvider.notifier).revealAll();
      await tester.pumpAndSettle();

      final entry2 = {
        const CellKey(1, 0),
        const CellKey(1, 1),
        const CellKey(1, 2),
      };
      final flashing = container.read(flashingCellsProvider);
      expect(flashing.containsAll(entry2), isTrue);
      for (final c in entry1) {
        expect(flashing.contains(c), isFalse);
      }

      await tester.pump(const Duration(seconds: 6));
    },
  );

  testWidgets(
    'Reveal a single letter then revealAll only flashes newly revealed words',
    (WidgetTester tester) async {
      const entries = [
        PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 0,
          y: 0,
          length: 3,
          answer: 'CAT',
        ),
        PuzzleEntryData(
          number: 2,
          direction: 'across',
          x: 0,
          y: 1,
          length: 3,
          answer: 'DOG',
        ),
      ];

      final board = GameBoard(
        id: 'test2',
        title: 't2',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['C', null, 'T'],
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
        difficulty: 1,
        entries: entries,
        solutionGrid: [
          ['C', 'A', 'T'],
          ['D', 'O', 'G'],
          [null, null, null],
        ],
      );

      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          flashClearDelayProvider.overrideWithValue(const Duration(seconds: 5)),
        ],
      );
      addTearDown(container.dispose);

      container.read(gameBoardProvider.notifier).setBoard(board);
      try {
        container.read(gameAudioMutedProvider.notifier).setMuted(muted: true);
      } on Object {
        // audio not available in test environment
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: Center(child: SizedBox())),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Reveal the missing letter at 0,1 which completes the first word
      container.read(gameBoardProvider.notifier).revealLetterAt(0, 1);
      await tester.pumpAndSettle();

      final entry1 = {
        const CellKey(0, 0),
        const CellKey(0, 1),
        const CellKey(0, 2),
      };
      expect(container.read(flashingCellsProvider).containsAll(entry1), isTrue);

      // Now revealAll
      container.read(gameBoardProvider.notifier).revealAll();
      await tester.pumpAndSettle();

      final entry2 = {
        const CellKey(1, 0),
        const CellKey(1, 1),
        const CellKey(1, 2),
      };
      final flashing = container.read(flashingCellsProvider);
      expect(flashing.containsAll(entry2), isTrue);
      for (final c in entry1) {
        expect(flashing.contains(c), isFalse);
      }

      await tester.pump(const Duration(seconds: 6));
    },
  );
}
