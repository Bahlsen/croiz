import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import '../helpers/test_helpers.dart';
import '../helpers/fake_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multi-word completion tests', () {
    late FakeAudioService mockAudio;

    setUp(() {
      mockAudio = FakeAudioService();
    });

    test(
      'completing a single horizontal word flashes its cells and plays success once',
      () {
        fakeAsync((async) {
          final container = createTestContainer(
            audioService: mockAudio,
            flashClearDelay: const Duration(seconds: 1),
            wordCheckDebounceDelay: Duration.zero,
          );
          addTearDown(container.dispose);

          const size = 3;
          final board = GameBoard(
            id: 'single-h',
            title: 'single-h',
            gridSize: size,
            createdAt: DateTime.now(),
            grid: List.generate(size, (_) => List<String?>.filled(size, null)),
            clues: const {},
            blackCells: List.generate(
              size,
              (_) => List<bool>.filled(size, false),
            ),
            difficulty: 1,
            entries: const [
              PuzzleEntryData(
                number: 1,
                direction: 'across',
                x: 0,
                y: 0,
                length: 3,
                answer: 'CAT',
              ),
            ],
            solutionGrid: [
              ['C', 'A', 'T'],
              [null, null, null],
              [null, null, null],
            ],
          );

          container.read(gameBoardProvider.notifier).setBoard(board);
          container
              .read(selectedCellProvider.notifier)
              .select(const SelectedCell(0, 0));
          container
              .read(wordDirectionProvider.notifier)
              .setDirection(WordDirection.horizontal);

          final controller = CrosswordInputController.fromContainer(container);

          controller
            ..setLetterAndAdvance('C')
            ..setLetterAndAdvance('A')
            ..setLetterAndAdvance('T');

          async.flushMicrotasks();

          expect(mockAudio.successCount, 1);
          final flashing = container.read(flashingCellsProvider);
          expect(flashing.length, 3);
          expect(
            flashing,
            containsAll([
              const CellKey(0, 0),
              const CellKey(0, 1),
              const CellKey(0, 2),
            ]),
          );

          expect(container.read(foundWordsProvider).length, 1);

          async.elapse(const Duration(seconds: 2));
          expect(container.read(flashingCellsProvider), isEmpty);
        });
      },
    );

    test(
      'completing a single vertical word flashes its cells and plays success once',
      () {
        fakeAsync((async) {
          final container = createTestContainer(
            audioService: mockAudio,
            flashClearDelay: const Duration(seconds: 1),
            wordCheckDebounceDelay: Duration.zero,
          );
          addTearDown(container.dispose);

          const size = 3;
          final board = GameBoard(
            id: 'single-v',
            title: 'single-v',
            gridSize: size,
            createdAt: DateTime.now(),
            grid: List.generate(size, (_) => List<String?>.filled(size, null)),
            clues: const {},
            blackCells: List.generate(
              size,
              (_) => List<bool>.filled(size, false),
            ),
            difficulty: 1,
            entries: const [
              PuzzleEntryData(
                number: 1,
                direction: 'down',
                x: 0,
                y: 0,
                length: 3,
                answer: 'DOG',
              ),
            ],
            solutionGrid: [
              ['D', null, null],
              ['O', null, null],
              ['G', null, null],
            ],
          );

          container.read(gameBoardProvider.notifier).setBoard(board);
          container
              .read(selectedCellProvider.notifier)
              .select(const SelectedCell(0, 0));
          container
              .read(wordDirectionProvider.notifier)
              .setDirection(WordDirection.vertical);

          final controller = CrosswordInputController.fromContainer(container);

          controller
            ..setLetterAndAdvance('D')
            ..setLetterAndAdvance('O')
            ..setLetterAndAdvance('G');

          async.flushMicrotasks();

          expect(mockAudio.successCount, 1);
          expect(container.read(flashingCellsProvider).length, 3);

          async.elapse(const Duration(seconds: 2));
          expect(container.read(flashingCellsProvider), isEmpty);
        });
      },
    );

    test(
      'completing two words at intersection flashes ALL cells and plays success ONCE',
      () {
        fakeAsync((async) {
          final container = createTestContainer(
            audioService: mockAudio,
            flashClearDelay: const Duration(seconds: 1),
            wordCheckDebounceDelay: Duration.zero,
          );
          addTearDown(container.dispose);

          const size = 3;
          final grid = List.generate(
            size,
            (_) => List<String?>.filled(size, null),
          );
          grid[0][0] = 'C';
          grid[0][2] = 'T';
          grid[1][1] = 'C';
          grid[2][1] = 'E';

          final board = GameBoard(
            id: 'intersection',
            title: 'intersection',
            gridSize: size,
            createdAt: DateTime.now(),
            grid: grid,
            clues: const {},
            blackCells: List.generate(
              size,
              (_) => List<bool>.filled(size, false),
            ),
            difficulty: 1,
            entries: const [
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
                direction: 'down',
                x: 1,
                y: 0,
                length: 3,
                answer: 'ACE',
              ),
            ],
            solutionGrid: [
              ['C', 'A', 'T'],
              [null, 'C', null],
              [null, 'E', null],
            ],
          );

          container.read(gameBoardProvider.notifier).setBoard(board);
          container
              .read(selectedCellProvider.notifier)
              .select(const SelectedCell(0, 1));
          container
              .read(wordDirectionProvider.notifier)
              .setDirection(WordDirection.horizontal);

          final controller = CrosswordInputController.fromContainer(container);

          controller.setLetterAndAdvance('A');

          async.flushMicrotasks();

          expect(mockAudio.successCount, 1);
          expect(container.read(flashingCellsProvider).length, 5);
          expect(container.read(foundWordsProvider).length, 2);

          async.elapse(const Duration(seconds: 2));
          expect(container.read(flashingCellsProvider), isEmpty);
        });
      },
    );

    test(
      'completing only one word when typing at intersection (other word incomplete)',
      () {
        fakeAsync((async) {
          final container = createTestContainer(
            audioService: mockAudio,
            flashClearDelay: const Duration(seconds: 1),
            wordCheckDebounceDelay: Duration.zero,
          );
          addTearDown(container.dispose);

          const size = 3;
          final grid = List.generate(
            size,
            (_) => List<String?>.filled(size, null),
          );
          grid[0][0] = 'C';
          grid[0][2] = 'T';

          final board = GameBoard(
            id: 'partial-intersection',
            title: 'partial-intersection',
            gridSize: size,
            createdAt: DateTime.now(),
            grid: grid,
            clues: const {},
            blackCells: List.generate(
              size,
              (_) => List<bool>.filled(size, false),
            ),
            difficulty: 1,
            entries: const [
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
                direction: 'down',
                x: 1,
                y: 0,
                length: 3,
                answer: 'ACE',
              ),
            ],
            solutionGrid: [
              ['C', 'A', 'T'],
              [null, 'C', null],
              [null, 'E', null],
            ],
          );

          container.read(gameBoardProvider.notifier).setBoard(board);
          container
              .read(selectedCellProvider.notifier)
              .select(const SelectedCell(0, 1));
          container
              .read(wordDirectionProvider.notifier)
              .setDirection(WordDirection.horizontal);

          final controller = CrosswordInputController.fromContainer(container);

          controller.setLetterAndAdvance('A');

          async.flushMicrotasks();

          expect(mockAudio.successCount, 1);
          expect(container.read(flashingCellsProvider).length, 3);
          expect(container.read(foundWordsProvider).length, 1);

          async.elapse(const Duration(seconds: 2));
          expect(container.read(flashingCellsProvider), isEmpty);
        });
      },
    );

    test(
      'typing a letter that does not complete any word does not trigger flash or sound',
      () {
        fakeAsync((async) {
          final container = createTestContainer(
            audioService: mockAudio,
            flashClearDelay: const Duration(seconds: 1),
            wordCheckDebounceDelay: Duration.zero,
          );
          addTearDown(container.dispose);

          const size = 3;
          final board = GameBoard(
            id: 'no-complete',
            title: 'no-complete',
            gridSize: size,
            createdAt: DateTime.now(),
            grid: List.generate(size, (_) => List<String?>.filled(size, null)),
            clues: const {},
            blackCells: List.generate(
              size,
              (_) => List<bool>.filled(size, false),
            ),
            difficulty: 1,
            entries: const [
              PuzzleEntryData(
                number: 1,
                direction: 'across',
                x: 0,
                y: 0,
                length: 3,
                answer: 'CAT',
              ),
            ],
            solutionGrid: [
              ['C', 'A', 'T'],
              [null, null, null],
              [null, null, null],
            ],
          );

          container.read(gameBoardProvider.notifier).setBoard(board);
          container
              .read(selectedCellProvider.notifier)
              .select(const SelectedCell(0, 0));
          container
              .read(wordDirectionProvider.notifier)
              .setDirection(WordDirection.horizontal);

          final controller = CrosswordInputController.fromContainer(container);

          controller.setLetterAndAdvance('C');

          async.flushMicrotasks();

          expect(mockAudio.successCount, 0);
          expect(container.read(flashingCellsProvider), isEmpty);
        });
      },
    );

    test('already found word is skipped when typing at intersection', () {
      fakeAsync((async) {
        final container = createTestContainer(
          audioService: mockAudio,
          flashClearDelay: const Duration(seconds: 1),
          wordCheckDebounceDelay: Duration.zero,
        );
        addTearDown(container.dispose);

        const size = 3;
        final grid = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        grid[0][0] = 'C';
        grid[0][1] = 'A';
        grid[0][2] = 'T';

        final board = GameBoard(
          id: 'already-found',
          title: 'already-found',
          gridSize: size,
          createdAt: DateTime.now(),
          grid: grid,
          clues: const {},
          blackCells: List.generate(
            size,
            (_) => List<bool>.filled(size, false),
          ),
          difficulty: 1,
          entries: const [
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
          ],
          solutionGrid: [
            ['C', 'A', 'T'],
            ['D', 'O', 'G'],
            [null, null, null],
          ],
        );

        container.read(gameBoardProvider.notifier).setBoard(board);
        container.read(foundWordsProvider.notifier).setFoundWords({
          '0,0,across',
        });
        container.read(lockedCellsProvider.notifier).setLockedCells({
          const CellKey(0, 0),
          const CellKey(0, 1),
          const CellKey(0, 2),
        });

        container
            .read(selectedCellProvider.notifier)
            .select(const SelectedCell(1, 0));
        container
            .read(wordDirectionProvider.notifier)
            .setDirection(WordDirection.horizontal);

        final controller = CrosswordInputController.fromContainer(container);

        controller
          ..setLetterAndAdvance('D')
          ..setLetterAndAdvance('O')
          ..setLetterAndAdvance('G');

        async.flushMicrotasks();

        expect(mockAudio.successCount, 1);
        expect(container.read(flashingCellsProvider).length, 3);
        expect(container.read(foundWordsProvider).length, 2);

        async.elapse(const Duration(seconds: 2));
        expect(container.read(flashingCellsProvider), isEmpty);
      });
    });

    test('completing all words triggers victory sound', () {
      fakeAsync((async) {
        final container = createTestContainer(
          audioService: mockAudio,
          flashClearDelay: const Duration(seconds: 1),
          wordCheckDebounceDelay: Duration.zero,
        );
        addTearDown(container.dispose);

        const size = 3;
        final board = GameBoard(
          id: 'victory',
          title: 'victory',
          gridSize: size,
          createdAt: DateTime.now(),
          grid: List.generate(size, (_) => List<String?>.filled(size, null)),
          clues: const {},
          blackCells: List.generate(
            size,
            (_) => List<bool>.filled(size, false),
          ),
          difficulty: 1,
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 3,
              answer: 'ABC',
            ),
          ],
          solutionGrid: [
            ['A', 'B', 'C'],
            [null, null, null],
            [null, null, null],
          ],
        );

        container.read(gameBoardProvider.notifier).setBoard(board);
        container
            .read(selectedCellProvider.notifier)
            .select(const SelectedCell(0, 0));
        container
            .read(wordDirectionProvider.notifier)
            .setDirection(WordDirection.horizontal);

        final controller = CrosswordInputController.fromContainer(container);

        controller
          ..setLetterAndAdvance('A')
          ..setLetterAndAdvance('B')
          ..setLetterAndAdvance('C');

        async.flushMicrotasks();

        expect(mockAudio.successCount, 1);
        expect(mockAudio.victoryCount, 1);

        async.elapse(const Duration(seconds: 2));
      });
    });
  });
}
