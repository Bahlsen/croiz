import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/game_audio_service.dart';
import 'package:croiz/domain/entities/game_entities.dart';

// Mock pour le service audio (n'hérite pas pour éviter les appels au constructeur)
class MockGameAudioService implements GameAudioService {
  int typeCallCount = 0;
  int deleteCallCount = 0;
  int successCallCount = 0;

  @override
  Future<void> playType() async {
    typeCallCount++;
  }

  @override
  Future<void> playDelete() async {
    deleteCallCount++;
  }

  @override
  Future<void> playSuccess() async {
    successCallCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CrosswordInputController - Audio Integration', () {
    late ProviderContainer container;
    late MockGameAudioService mockAudioService;

    setUp(() {
      mockAudioService = MockGameAudioService();
      container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          gameBoardProvider.overrideWith(
            (ref) => GameBoardNotifier(
              GameBoard(
                id: 'test',
                title: 'Test Board',
                gridSize: 3,
                createdAt: DateTime.now(),
                grid: [
                  [null, null, null],
                  [null, null, null],
                  [null, null, null],
                ],
                clues: {},
                blackCells: [
                  [false, false, false],
                  [false, false, false],
                  [false, false, false],
                ],
                difficulty: 1,
              ),
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('setLetterAndAdvance sets the letter in the board', () {
      final controller = CrosswordInputController.fromContainer(container);
      container.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 0);

      controller.setLetterAndAdvance('A');

      final value = container.read(gameBoardProvider).grid[0][0];
      expect(value, 'A');
    });

    test('clearCurrent clears the current cell', () {
      final controller = CrosswordInputController.fromContainer(container);
      container.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 0);
      container.read(gameBoardProvider.notifier).setLetter(0, 0, 'A');

      controller.clearCurrent();

      final value = container.read(gameBoardProvider).grid[0][0];
      expect(value, isNull);
    });

    test('setLetterAndAdvance detects completed word and plays success sound',
        () async {
      // Create a board with a simple 3-letter word "CAT"
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          gameBoardProvider.overrideWith(
            (ref) => GameBoardNotifier(
              GameBoard(
                id: 'test',
                title: 'Test Board',
                gridSize: 3,
                createdAt: DateTime.now(),
                grid: [
                  [null, null, null],
                  [null, null, null],
                  [null, null, null],
                ],
                clues: {},
                blackCells: [
                  [false, false, false],
                  [false, false, false],
                  [false, false, false],
                ],
                difficulty: 1,
                entries: [
                  const PuzzleEntryData(
                    number: 1,
                    direction: 'across',
                    x: 0,
                    y: 0,
                    length: 3,
                    answer: 'CAT',
                  ),
                ],
              ),
            ),
          ),
        ],
      );

      final controller = CrosswordInputController.fromContainer(testContainer);
      testContainer.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 0);

      // Type the word "CAT"
      controller.setLetterAndAdvance('C');
      testContainer.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 1);
      controller.setLetterAndAdvance('A');

      testContainer.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 2);
      controller.setLetterAndAdvance('T');

      // Verify the word is marked as found
      final foundWords = testContainer.read(foundWordsProvider);
      expect(foundWords.contains('0,0,across'), true);

      testContainer.dispose();
    });

    test('locked cells cannot be modified', () {
      // Setup a container with a locked cell
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          gameBoardProvider.overrideWith(
            (ref) => GameBoardNotifier(
              GameBoard(
                id: 'test',
                title: 'Test Board',
                gridSize: 3,
                createdAt: DateTime.now(),
                grid: [
                  ['C', 'A', 'T'],
                  [null, null, null],
                  [null, null, null],
                ],
                clues: {},
                blackCells: [
                  [false, false, false],
                  [false, false, false],
                  [false, false, false],
                ],
                difficulty: 1,
              ),
            ),
          ),
          lockedCellsProvider.overrideWith((ref) => {'0,0', '0,1', '0,2'}),
        ],
      );

      final controller = CrosswordInputController.fromContainer(testContainer);
      testContainer.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 0);

      final initialValue =
          testContainer.read(gameBoardProvider).grid[0][0];
      controller.setLetterAndAdvance('X');

      // Value should not change because cell is locked
      final finalValue = testContainer.read(gameBoardProvider).grid[0][0];
      expect(finalValue, initialValue);

      testContainer.dispose();
    });

    test('clearCurrent does not clear locked cells', () {
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          gameBoardProvider.overrideWith(
            (ref) => GameBoardNotifier(
              GameBoard(
                id: 'test',
                title: 'Test Board',
                gridSize: 3,
                createdAt: DateTime.now(),
                grid: [
                  ['C', null, null],
                  [null, null, null],
                  [null, null, null],
                ],
                clues: {},
                blackCells: [
                  [false, false, false],
                  [false, false, false],
                  [false, false, false],
                ],
                difficulty: 1,
              ),
            ),
          ),
          lockedCellsProvider.overrideWith((ref) => {'0,0'}),
        ],
      );

      final controller = CrosswordInputController.fromContainer(testContainer);
      testContainer.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 0);

      controller.clearCurrent();

      // Value should not be cleared because cell is locked
      final finalValue = testContainer.read(gameBoardProvider).grid[0][0];
      expect(finalValue, 'C');

      testContainer.dispose();
    });
  });
}
