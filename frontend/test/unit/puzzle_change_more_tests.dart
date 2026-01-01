import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_board_notifier.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/features/game/providers/game_state_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('Puzzle change — input & cleaners', () {
    test('setLetter only affects current puzzle instance', () async {
      final a = GameBoard(
        id: 'A',
        title: 'A',
        gridSize: 2,
        createdAt: DateTime.now(),
        grid: [
          [null, null],
          [null, null],
        ],
        clues: {},
        blackCells: List.generate(2, (_) => List<bool>.filled(2, false)),
        difficulty: 1,
        entries: [],
        solutionGrid: [
          [null, null],
          [null, null],
        ],
      );

      final b = GameBoard(
        id: 'B',
        title: 'B',
        gridSize: 2,
        createdAt: DateTime.now(),
        grid: [
          ['X', null],
          [null, null],
        ],
        clues: {},
        blackCells: List.generate(2, (_) => List<bool>.filled(2, false)),
        difficulty: 1,
        entries: [],
        solutionGrid: [
          ['X', null],
          [null, null],
        ],
      );

      GameBoard? current = a;

      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWith((ref) async => current!),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      await container.read(puzzleLoaderProvider.future);
      // ensure initialised
      container.read(gameBoardProvider);

      // set a letter on A
      container.read(gameBoardProvider.notifier).setLetter(0, 0, 'M');
      expect(container.read(gameBoardProvider).grid[0][0], equals('M'));

      // switch to B
      current = b;
      container.refresh(puzzleLoaderProvider);
      await container.read(puzzleLoaderProvider.future);
      // B should keep its own value
      expect(container.read(gameBoardProvider).id, equals('B'));
      expect(container.read(gameBoardProvider).grid[0][0], equals('X'));

      // switch back to a fresh A (simulate loader returning fresh instance)
      final aFresh = GameBoard(
        id: 'A',
        title: 'A',
        gridSize: 2,
        createdAt: DateTime.now(),
        grid: [
          [null, null],
          [null, null],
        ],
        clues: {},
        blackCells: List.generate(2, (_) => List<bool>.filled(2, false)),
        difficulty: 1,
        entries: [],
        solutionGrid: [
          [null, null],
          [null, null],
        ],
      );
      current = aFresh;
      container.refresh(puzzleLoaderProvider);
      await container.read(puzzleLoaderProvider.future);
      // fresh A should not have M (no in-memory carryover)
      expect(container.read(gameBoardProvider).id, equals('A'));
      expect(container.read(gameBoardProvider).grid[0][0], isNull);
    });

    test('toggleBlackCell updates black map and clears cell', () async {
      final board = GameBoard(
        id: 'tb',
        title: 'tb',
        gridSize: 2,
        createdAt: DateTime.now(),
        grid: [
          ['A', 'B'],
          ['C', 'D'],
        ],
        clues: {},
        blackCells: List.generate(2, (_) => List<bool>.filled(2, false)),
        difficulty: 1,
        entries: [],
        solutionGrid: [
          ['A', 'B'],
          ['C', 'D'],
        ],
      );

      final current = board;
      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWith((ref) async => current),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      await container.read(puzzleLoaderProvider.future);
      container.read(gameBoardProvider);

      // toggle (0,1) to black
      container.read(gameBoardProvider.notifier).toggleBlackCell(0, 1);
      final gb = container.read(gameBoardProvider);
      expect(gb.blackCells[0][1], isTrue);
      // cell should be null when black
      expect(gb.grid[0][1], isNull);
    });

    test(
      'clearIncorrectLetters clears wrong letters and flashes cells',
      () async {
        final entries = [
          const PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            answer: 'ABC',
          ),
        ];

        final board = GameBoard(
          id: 'clean',
          title: 'clean',
          gridSize: 3,
          createdAt: DateTime.now(),
          grid: [
            ['A', 'X', 'C'], // X is incorrect
            [null, null, null],
            [null, null, null],
          ],
          clues: {},
          blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
          difficulty: 1,
          entries: entries,
          solutionGrid: [
            ['A', 'B', 'C'],
            [null, null, null],
            [null, null, null],
          ],
        );

        final current = board;
        final container = ProviderContainer(
          overrides: [
            puzzleLoaderProvider.overrideWith((ref) async => current),
            // keep flash set long enough to assert it
            flashClearDelayProvider.overrideWithValue(
              const Duration(seconds: 5),
            ),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        await container.read(puzzleLoaderProvider.future);
        container.read(gameBoardProvider);

        container.read(gameBoardProvider.notifier).clearIncorrectLetters();

        // grid should have cleared the incorrect cell
        final gb = container.read(gameBoardProvider);
        expect(gb.grid[0][1], isNull);

        // flashing cleared cells should include (0,1)
        final flashed = container.read(flashingClearedCellsProvider);
        expect(flashed, contains(const CellKey(0, 1)));
      },
    );
  });
}
