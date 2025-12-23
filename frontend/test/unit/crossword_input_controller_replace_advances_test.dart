import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/game_audio_service.dart';

class MockGameAudioService implements GameAudioService {
  @override
  Future<void> playType() async {}
  @override
  Future<void> playDelete() async {}
  @override
  Future<void> playSuccess() async {}
  @override
  Future<void> playVictory() async {}
  @override
  Future<void> get ready => Future<void>.value();
  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('replacing a filled letter advances to next empty in same entry', () {
    const size = 5;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final black = List.generate(size, (_) => List<bool>.filled(size, false));

    // Define one across entry at row 0, cols 0..3 (length 4)
    final boardWithEntry = GameBoard(
      id: 'replace-advance',
      title: 'replace-advance',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 4),
      ],
    );

    final container = ProviderContainer(overrides: [
      gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
      puzzleLoaderProvider.overrideWithValue(AsyncValue.data(boardWithEntry)),
    ]);
    addTearDown(container.dispose);

    // Pre-fill cell (0,1)
    container.read(gameBoardProvider.notifier).setLetter(0, 1, 'X');

    // Select the filled cell (0,1)
    container.read(selectedCellProvider.notifier).state = const SelectedCell(0, 1);

    // Replace with new letter
    CrosswordInputController.fromContainer(container).setLetterAndAdvance('A');

    final boardAfter = container.read(gameBoardProvider);
    expect(boardAfter.grid[0][1], 'A');

    // Next empty in same entry should be (0,2)
    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    expect(sel!.row, 0);
    expect(sel.col, 2);
  });
}
