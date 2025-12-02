import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/core/puzzle_converter.dart';
import 'package:croiz/features/game/services/incorrect_letter_cleaner.dart';

class GameBoardNotifier extends Notifier<GameBoard> {
  @override
  GameBoard build() {
    final defaultBoard = _createEmptyBoard(5);

    // Listen for puzzle loader updates and update state when puzzle data arrives
    ref.listen<AsyncValue<GameBoard>>(puzzleLoaderProvider, (prev, next) {
      if (next is AsyncData<GameBoard>) {
        state = next.value;
      }
    });

    final puzzleAsync = ref.watch(puzzleLoaderProvider);
    return puzzleAsync.maybeWhen(data: (d) => d, orElse: () => defaultBoard);
  }

  static GameBoard _createEmptyBoard(int size) {
    final grid = <List<String?>>[];
    for (var i = 0; i < size; i++) {
      grid.add(List<String?>.filled(size, null));
    }
    final blackCells = <List<bool>>[];
    for (var i = 0; i < size; i++) {
      blackCells.add(List<bool>.filled(size, false));
    }
    return GameBoard(
      id: 'local',
      title: 'Local Game',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: {},
      blackCells: blackCells,
      difficulty: 1,
    );
  }

  void setLetter(int row, int col, String? letter) {
    // Do nothing if this cell is a black cell — no interaction allowed.
    if (state.blackCells.isDisabled(row, col)) {
      return;
    }
    final newGrid = List<List<String?>>.from(
      state.grid.map(List<String?>.from),
    );
    newGrid[row][col] = letter == null || letter.isEmpty
        ? null
        : letter.substring(0, 1).toUpperCase();
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

  /// Clear any letters in the grid that do not match the puzzle answers.
  ///
  /// For each entry with a known answer, build an expected grid from the
  /// answers and remove any letter in the current grid that does not match
  /// the expected character for that cell.
  void clearIncorrectLetters() {
    final cleaner = ref.read(incorrectLetterCleanerProvider);
    final result = cleaner.cleanWithResult(state);
    state = result.board;

    if (result.clearedCells.isNotEmpty) {
      // Flash cleared cells in the UI (red) via flashingClearedCellsProvider
      ref.read(flashingClearedCellsProvider.notifier).value = result.clearedCells.toSet();
      // Clear flash after a short duration
      Future.delayed(const Duration(milliseconds: 700), () {
        try {
          ref.read(flashingClearedCellsProvider.notifier).value = <String>{};
        } on Object catch (_) {}
      });
    }
  }
}

/// Provider to load the puzzle asynchronously from JSON.
final puzzleLoaderProvider = FutureProvider<GameBoard>(
  (ref) async => loadPuzzleFromAsset('assets/data/astronomie_puzzle.json'),
);

/// Main game board provider (uses the loaded puzzle or fallback to empty).
final gameBoardProvider = NotifierProvider<GameBoardNotifier, GameBoard>(
  GameBoardNotifier.new,
);

/// Load a puzzle from a JSON asset file and convert to GameBoard.
Future<GameBoard> loadPuzzleFromAsset(String assetPath) async {
  final jsonString = await rootBundle.loadString(assetPath);
  final jsonData = json.decode(jsonString) as Map<String, dynamic>;
  final puzzle = Puzzle.fromJson(jsonData);
  return PuzzleConverter.puzzleToGameBoard(puzzle);
}

/// Create sample board by loading from assets/data/sample_5x5.json
Future<GameBoard> createSampleBoard() async {
  final board = await loadPuzzleFromAsset('assets/data/sample_5x5.json');
  return board;
}

/// Fallback: create empty board if loading fails
GameBoard createEmptyBoard(int size) => GameBoardNotifier._createEmptyBoard(size);

/// Represents a selected cell in the grid.
class SelectedCell {
  const SelectedCell(this.row, this.col);
  final int row;
  final int col;
}

/// Represents word direction: true = horizontal, false = vertical.
enum WordDirection { horizontal, vertical }

/// Holds the currently selected cell (or null if none).
class SelectedCellNotifier extends Notifier<SelectedCell?> {
  @override
  SelectedCell? build() => _initialSelectedCell(ref);
  SelectedCell? get value => state;
  set value(SelectedCell? v) => state = v;
}

final selectedCellProvider =
    NotifierProvider<SelectedCellNotifier, SelectedCell?>(SelectedCellNotifier.new);

/// Holds the current word direction (horizontal or vertical).
class WordDirectionNotifier extends Notifier<WordDirection> {
  @override
  WordDirection build() => _initialWordDirection(ref);
  WordDirection get value => state;
  set value(WordDirection v) => state = v;
}

final wordDirectionProvider =
    NotifierProvider<WordDirectionNotifier, WordDirection>(WordDirectionNotifier.new);

// Holds the set of found word keys (format: "row,col,direction")
class FoundWordsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => _initialFoundWords(ref);
  Set<String> get value => state;
  set value(Set<String> v) => state = v;
}

final foundWordsProvider =
    NotifierProvider<FoundWordsNotifier, Set<String>>(FoundWordsNotifier.new);

// Holds cells that should flash (format: "row,col")
class FlashingCellsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => _initialFlashingCells(ref);
  Set<String> get value => state;
  set value(Set<String> v) => state = v;
}

final flashingCellsProvider =
    NotifierProvider<FlashingCellsNotifier, Set<String>>(FlashingCellsNotifier.new);

// Holds cells that should flash red because they were cleared by the cleaner.
class FlashingClearedCellsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => _initialFlashingClearedCells(ref);
  Set<String> get value => state;
  set value(Set<String> v) => state = v;
}

final flashingClearedCellsProvider =
    NotifierProvider<FlashingClearedCellsNotifier, Set<String>>(FlashingClearedCellsNotifier.new);

// Holds cells that are locked (format: "row,col")
class LockedCellsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => _initialLockedCells(ref);
  Set<String> get value => state;
  set value(Set<String> v) => state = v;
}

final lockedCellsProvider =
    NotifierProvider<LockedCellsNotifier, Set<String>>(LockedCellsNotifier.new);
// Provider tear-offs for initial values.
SelectedCell? _initialSelectedCell(ref) => null;
WordDirection _initialWordDirection(ref) => WordDirection.horizontal;
Set<String> _initialFoundWords(ref) => {};
Set<String> _initialFlashingCells(ref) => {};
Set<String> _initialLockedCells(ref) => {};
Set<String> _initialFlashingClearedCells(ref) => {};
