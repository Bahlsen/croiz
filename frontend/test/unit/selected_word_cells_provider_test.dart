import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import '../helpers/test_helpers.dart';

void main() {
  test('selectedWordCellsProvider returns correct horizontal set', () {
    final container = createTestContainer();
    addTearDown(container.dispose);

    const size = 5;
    final black = List.generate(size, (_) => List<bool>.filled(size, false));
    // Place a black cell at (0,3) so the word 0,0 spans cols 0..2
    black[0][3] = true;

    final board = GameBoard(
      id: 's',
      title: 's',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: List.generate(size, (_) => List<String?>.filled(size, null)),
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [],
    );

    // Give a small delay to handle initial loader firing if needed
    container.read(gameBoardProvider.notifier).setBoard(board);
    container
        .read(selectedCellProvider.notifier)
        .select(const SelectedCell(0, 1));
    container
        .read(wordDirectionProvider.notifier)
        .setDirection(WordDirection.horizontal);

    final set = container.read(selectedWordCellsProvider);
    expect(set.contains(const CellKey(0, 0)), true);
    expect(set.contains(const CellKey(0, 1)), true);
    expect(set.contains(const CellKey(0, 2)), true);
    expect(set.contains(const CellKey(0, 3)), false);
  });

  test('selectedWordCellsProvider returns correct vertical set', () {
    final container = createTestContainer();
    addTearDown(container.dispose);

    const size = 5;
    final black = List.generate(size, (_) => List<bool>.filled(size, false));
    // Block at (3,0) so vertical word at (1,0) spans rows 1..2
    black[3][0] = true;

    final board = GameBoard(
      id: 's',
      title: 's',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: List.generate(size, (_) => List<String?>.filled(size, null)),
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [],
    );

    container.read(gameBoardProvider.notifier).setBoard(board);
    container
        .read(selectedCellProvider.notifier)
        .select(const SelectedCell(2, 0));
    container
        .read(wordDirectionProvider.notifier)
        .setDirection(WordDirection.vertical);

    final set = container.read(selectedWordCellsProvider);
    expect(set.contains(const CellKey(1, 0)), true);
    expect(set.contains(const CellKey(2, 0)), true);
    expect(set.contains(const CellKey(3, 0)), false);
  });
}
