import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/board_helpers.dart';

class GameBoardNotifier extends StateNotifier<GameBoard> {
  GameBoardNotifier(super.state);

  factory GameBoardNotifier.createEmpty(int size) {
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final blackCells = List.generate(size, (_) => List<bool>.filled(size, false));
    final board = GameBoard(
      id: 'local',
      title: 'Local Game',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: {},
      blackCells: blackCells,
      difficulty: 1,
    );
    return GameBoardNotifier(board);
  }

  void setLetter(int row, int col, String? letter) {
    final newGrid = List<List<String?>>.from(
      state.grid.map((r) => List<String?>.from(r)),
    );
    newGrid[row][col] = letter == null || letter.isEmpty ? null : letter.substring(0, 1).toUpperCase();
    // copy blackCells as-is
    final newBlack = List<List<bool>>.from(
      state.blackCells.map((r) => List<bool>.from(r)),
    );
    state = GameBoard(
      id: state.id,
      title: state.title,
      gridSize: state.gridSize,
      createdAt: state.createdAt,
      grid: newGrid,
      clues: state.clues,
      blackCells: newBlack,
      difficulty: state.difficulty,
    );
  }

  void toggleBlackCell(int row, int col) {
    final newGrid = List<List<String?>>.from(
      state.grid.map((r) => List<String?>.from(r)),
    );
    final newBlack = List<List<bool>>.from(
      state.blackCells.map((r) => List<bool>.from(r)),
    );
    newBlack[row][col] = !newBlack[row][col];
    // if a cell becomes black, clear its letter
    if (newBlack[row][col]) {
      newGrid[row][col] = null;
    }
    state = GameBoard(
      id: state.id,
      title: state.title,
      gridSize: state.gridSize,
      createdAt: state.createdAt,
      grid: newGrid,
      clues: state.clues,
      blackCells: newBlack,
      difficulty: state.difficulty,
    );
  }
}

final gameBoardProvider = StateNotifierProvider<GameBoardNotifier, GameBoard>((ref) {
  return createSampleBoard();
});


  
GameBoardNotifier createSampleBoard() =>
  _createSampleBoardImpl();

GameBoardNotifier _createSampleBoardImpl() {
  const size = 13;
  final grid = List.generate(size, (_) => List<String?>.filled(size, null));
  final blackCells = List.generate(size, (_) => List<bool>.filled(size, false));

  // Example arbitrary pattern of black cells (prototype)
  final blackCoords = <List<int>>[
    // some pattern to create non-rectangular crossword
    [0, 0], [0, 1], [0, 11], [0, 12],
    [1, 0], [1, 12],
    [2, 4], [2, 8],
    [3, 2], [3, 10],
    [4, 0], [4, 6], [4, 12],
    [5, 3], [5, 9],
    [6, 0], [6, 12],
    [7, 3], [7, 9],
    [8, 0], [8, 6], [8, 12],
    [9, 2], [9, 10],
    [10,4], [10,8],
    [11,0], [11,12],
    [12,0], [12,1], [12,11], [12,12],
  ];
  blackCells.setBlackCells(blackCoords);

  // Place some sample words (horizontal/vertical)
  // Ensure word cells are not black before placing words
  void place(String w, int r, int c, {bool horizontal = true}) {
    for (var i = 0; i < w.length; i++) {
      final rr = horizontal ? r : r + i;
      final cc = horizontal ? c + i : c;
      if (rr >= 0 && rr < size && cc >= 0 && cc < size) {
        blackCells[rr][cc] = false;
      }
    }
    grid.setWordSafe(r, c, w, horizontal: horizontal);
  }

  place('SOL', 2, 0);
  place('APOGEE', 2, 5);
  place('LEAD', 3, 3);
  place('ENTERPRISE', 5, 0);
  place('OPEN', 6, 2);
  place('STEREO', 8, 2);
  place('ALPHA', 0, 4, horizontal: false);
  place('BRAVO', 0, 7, horizontal: false);

  final board = GameBoard(
    id: 'sample',
    title: 'Sample Crossword',
    gridSize: size,
    createdAt: DateTime.now(),
    grid: grid,
    clues: {},
    blackCells: blackCells,
    difficulty: 1,
  );
  return GameBoardNotifier(board);
}

/// Represents a selected cell in the grid.
class SelectedCell {
  const SelectedCell(this.row, this.col);
  final int row;
  final int col;
}

/// Represents word direction: true = horizontal, false = vertical.
enum WordDirection { horizontal, vertical }

/// Holds the currently selected cell (or null if none).
final selectedCellProvider = StateProvider<SelectedCell?>((ref) => null);

/// Holds the current word direction (horizontal or vertical).
final wordDirectionProvider = StateProvider<WordDirection>((ref) => WordDirection.horizontal);
