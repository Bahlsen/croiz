import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/services/game_audio_service.dart';

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

  test('vertical backspace moves backward within entry then to previous word', () {
    const size = 5;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    // Pre-fill entry at x=2 (previous entry) first cell
    grid[0][2] = 'X';
    // Fill entry at x=0 rows 0..2
    grid[0][0] = 'A';
    grid[1][0] = 'B';
    grid[2][0] = 'C';

    final black = List.generate(size, (_) => List<bool>.filled(size, false));

    final board = GameBoard(
      id: 'vb',
      title: 'vertical-backspace',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [
        // previous vertical entry (number 1)
        PuzzleEntryData(number: 1, direction: 'down', x: 2, y: 0, length: 3),
        // current vertical entry (number 2)
        PuzzleEntryData(number: 2, direction: 'down', x: 0, y: 0, length: 3),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);

    final controller = CrosswordInputController.fromContainer(container);

    // Set vertical direction and select last cell of current entry
    container
        .read(wordDirectionProvider.notifier)
        .setDirection(WordDirection.vertical);
    container
        .read(selectedCellProvider.notifier)
        .select(const SelectedCell(2, 0));

    // 1) Clear (2,0) -> expect selection to move to previous filled in same entry (1,0)
    controller.clearCurrent();
    var sel = container.read<SelectedCell?>(selectedCellProvider);
    expect(sel, isNotNull);
    final s = sel!;
    expect(s.row, 1);
    expect(s.col, 0);

    // 2) Clear (1,0) -> expect selection to move to (0,0)
    controller.clearCurrent();
    sel = container.read<SelectedCell?>(selectedCellProvider);
    expect(sel, isNotNull);
    final s2 = sel!;
    expect(s2.row, 0);
    expect(s2.col, 0);

    // 3) Clear (0,0) -> now the current entry is empty; expect selection to move
    //    to previous word's last filled cell (0,2)
    controller.clearCurrent();
    sel = container.read<SelectedCell?>(selectedCellProvider);
    expect(sel, isNotNull);
    final s3 = sel!;
    expect(s3.row, 0);
    expect(s3.col, 2);
  });

  test(
    'backspace across multiple previous words selects last letters in sequence',
    () {
      const size = 6;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      // Three across entries on row 0: cells [0,1], [2,3], [4,5]
      grid[0][0] = 'A';
      grid[0][1] = 'B';
      grid[0][2] = 'C';
      grid[0][3] = 'D';
      grid[0][4] = 'E';
      grid[0][5] = 'F';

      final black = List.generate(size, (_) => List<bool>.filled(size, false));

      final board = GameBoard(
        id: 'multi-back',
        title: 'multi-back',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: black,
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 5,
            direction: 'across',
            x: 0,
            y: 0,
            length: 2,
          ),
          PuzzleEntryData(
            number: 6,
            direction: 'across',
            x: 2,
            y: 0,
            length: 2,
          ),
          PuzzleEntryData(
            number: 7,
            direction: 'across',
            x: 4,
            y: 0,
            length: 2,
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);

      final controller = CrosswordInputController.fromContainer(container);

      // Select last cell of entry 7 (0,5)
      container
          .read(wordDirectionProvider.notifier)
          .setDirection(WordDirection.horizontal);
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(0, 5));

      // clear (0,5) -> should move to (0,4)
      controller.clearCurrent();
      var sel = container.read<SelectedCell?>(selectedCellProvider);
      expect(sel, isNotNull);
      final s4 = sel!;
      expect(s4.row, 0);
      expect(s4.col, 4);

      // clear (0,4) -> should move to last letter of previous word (0,3)
      controller.clearCurrent();
      sel = container.read<SelectedCell?>(selectedCellProvider);
      expect(sel, isNotNull);
      final s5 = sel!;
      expect(s5.row, 0);
      expect(s5.col, 3);

      // clear (0,3) -> should move to (0,2)
      controller.clearCurrent();
      sel = container.read<SelectedCell?>(selectedCellProvider);
      expect(sel, isNotNull);
      final s6 = sel!;
      expect(s6.row, 0);
      expect(s6.col, 2);

      // clear (0,2) -> should move to last letter of previous word (0,1)
      controller.clearCurrent();
      sel = container.read<SelectedCell?>(selectedCellProvider);
      expect(sel, isNotNull);
      final s7 = sel!;
      expect(s7.row, 0);
      expect(s7.col, 1);
    },
  );

  test('vertical backspace across multiple previous words selects last letters', () {
    const size = 6;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));

    // Create three vertical entries at cols 0,2,4 with length 2 each and fill them
    grid[0][0] = 'A';
    grid[1][0] = 'B';

    grid[0][2] = 'C';
    grid[1][2] = 'D';

    grid[0][4] = 'E';
    grid[1][4] = 'F';

    final black = List.generate(size, (_) => List<bool>.filled(size, false));

    final board = GameBoard(
      id: 'v-multi-back',
      title: 'v-multi-back',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 5, direction: 'down', x: 0, y: 0, length: 2),
        PuzzleEntryData(number: 6, direction: 'down', x: 2, y: 0, length: 2),
        PuzzleEntryData(number: 7, direction: 'down', x: 4, y: 0, length: 2),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);

    final controller = CrosswordInputController.fromContainer(container);

    // Select last cell of entry 7 (row=1,col=4)
    container
        .read(wordDirectionProvider.notifier)
        .setDirection(WordDirection.vertical);
    container
        .read(selectedCellProvider.notifier)
        .select(const SelectedCell(1, 4));

    // clear (1,4) -> should move to (0,4)
    controller.clearCurrent();
    var sel = container.read<SelectedCell?>(selectedCellProvider);
    expect(sel, isNotNull);
    final s8 = sel!;
    expect(s8.row, 0);
    expect(s8.col, 4);

    // clear (0,4) -> should move to last letter of previous vertical word (1,2)
    controller.clearCurrent();
    sel = container.read<SelectedCell?>(selectedCellProvider);
    expect(sel, isNotNull);
    final s9 = sel!;
    expect(s9.row, 1);
    expect(s9.col, 2);

    // clear (1,2) -> should move to (0,2)
    controller.clearCurrent();
    sel = container.read<SelectedCell?>(selectedCellProvider);
    expect(sel, isNotNull);
    final s10 = sel!;
    expect(s10.row, 0);
    expect(s10.col, 2);

    // clear (0,2) -> should move to last letter of previous vertical word (1,0)
    controller.clearCurrent();
    sel = container.read<SelectedCell?>(selectedCellProvider);
    expect(sel, isNotNull);
    final s11 = sel!;
    expect(s11.row, 1);
    expect(s11.col, 0);
  });
}
