import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/core/puzzle_converter.dart';

class GameBoardNotifier extends StateNotifier<GameBoard> {
  GameBoardNotifier(super.state);

  factory GameBoardNotifier.createEmpty(int size) {
    final grid = <List<String?>>[];
    for (var i = 0; i < size; i++) {
      grid.add(List<String?>.filled(size, null));
    }
    final blackCells = <List<bool>>[];
    for (var i = 0; i < size; i++) {
      blackCells.add(List<bool>.filled(size, false));
    }
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
    // Do nothing if this cell is a black cell — no interaction allowed.
    if (state.blackCells.isDisabled(row, col)) {
      return;
    }
    final newGrid = List<List<String?>>.from(
      state.grid.map(List<String?>.from),
    );
    newGrid[row][col] = letter == null || letter.isEmpty ? null : letter.substring(0, 1).toUpperCase();
    // copy blackCells as-is
    final newBlack = List<List<bool>>.from(
      state.blackCells.map(List<bool>.from),
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
      entries: state.entries,
    );
  }

  void toggleBlackCell(int row, int col) {
    final newGrid = List<List<String?>>.from(
      state.grid.map(List<String?>.from),
    );
    final newBlack = List<List<bool>>.from(
      state.blackCells.map(List<bool>.from),
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
      entries: state.entries,
    );
  }
}

/// Provider to load the puzzle asynchronously from JSON.
final puzzleLoaderProvider = FutureProvider<GameBoard>(
  (ref) async => loadPuzzleFromAsset('assets/data/astronomie_puzzle.json'),
);

/// Main game board provider (uses the loaded puzzle or fallback to empty).
final gameBoardProvider = StateNotifierProvider<GameBoardNotifier, GameBoard>((ref) {
  final puzzleAsync = ref.watch(puzzleLoaderProvider);
  return puzzleAsync.when(
    data: GameBoardNotifier.new,
    loading: () => GameBoardNotifier.createEmpty(5),
    error: (_, __) => GameBoardNotifier.createEmpty(5),
  );
});


/// Load a puzzle from a JSON asset file and convert to GameBoard.
Future<GameBoard> loadPuzzleFromAsset(String assetPath) async {
  final jsonString = await rootBundle.loadString(assetPath);
  final jsonData = json.decode(jsonString) as Map<String, dynamic>;
  final puzzle = Puzzle.fromJson(jsonData);
  return PuzzleConverter.puzzleToGameBoard(puzzle);
}

/// Create sample board by loading from assets/data/sample_5x5.json
Future<GameBoardNotifier> createSampleBoard() async {
  final board = await loadPuzzleFromAsset('assets/data/sample_5x5.json');
  return GameBoardNotifier(board);
}

/// Fallback: create empty board if loading fails
GameBoardNotifier createEmptyBoard(int size) =>
    GameBoardNotifier.createEmpty(size);

/// Represents a selected cell in the grid.
class SelectedCell {
  const SelectedCell(this.row, this.col);
  final int row;
  final int col;
}

/// Represents word direction: true = horizontal, false = vertical.
enum WordDirection { horizontal, vertical }

/// Holds the currently selected cell (or null if none).
final selectedCellProvider = StateProvider<SelectedCell?>(_initialSelectedCell);

/// Holds the current word direction (horizontal or vertical).
final wordDirectionProvider = StateProvider<WordDirection>(_initialWordDirection);

// Provider tear-offs for initial values.
SelectedCell? _initialSelectedCell(ref) => null;
WordDirection _initialWordDirection(ref) => WordDirection.horizontal;
