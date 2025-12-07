import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/core/puzzle_converter.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/services/incorrect_letter_cleaner.dart';

class GameBoardNotifier extends Notifier<GameBoard> {
  // Notifier that mirrors `puzzleLoaderProvider`. Attaches a single listener
  // on first `build()` to react to puzzle load events and update dependent
  // providers (found/locked words, etc.).
  bool _listenerAttached = false;

  @override
  GameBoard build() {
    if (!_listenerAttached) {
      _listenerAttached = true;
      // Safe to call ref.listen here because build() runs after the
      // notifier has been created and ref is available. The guard ensures
      // we don't attach multiple listeners across rebuilds.
      ref.listen<AsyncValue<GameBoard>>(
        puzzleLoaderProvider,
        _onPuzzleLoaderChanged,
        fireImmediately: true,
      );
    }
    final defaultBoard = _createEmptyBoard(5);

    final puzzleAsync = ref.watch(puzzleLoaderProvider);
    return puzzleAsync.maybeWhen(data: (d) => d, orElse: () => defaultBoard);
  }

  void _onPuzzleLoaderChanged(
    AsyncValue<GameBoard>? prev,
    AsyncValue<GameBoard> next,
  ) {
    if (next is AsyncData<GameBoard>) {
      state = next.value;

      // Detect any words already complete in the loaded puzzle and update
      // `foundWordsProvider` / `lockedCellsProvider` so the UI reflects
      // the correct state immediately.
      final entries = state.entries;
      if (entries != null && entries.isNotEmpty) {
        try {
          final wordCheck = ref.read(wordCheckServiceProvider);
          final newFound = <String>{};
          final newLocked = <String>{};
          for (final entry in entries) {
            if (wordCheck.isWordComplete(state, entry)) {
              final key = wordCheck.getWordKey(entry);
              newFound.add(key);
              newLocked.addAll(wordCheck.getCellKeys(entry));
            }
          }
          if (newFound.isNotEmpty) {
            ref.read(foundWordsProvider.notifier).value = newFound;
          }
          if (newLocked.isNotEmpty) {
            ref.read(lockedCellsProvider.notifier).value = newLocked;
          }
        } on Object catch (e, stack) {
          // Log and continue on errors from detection.
          debugPrint('Error updating found/locked words: $e\n$stack');
        }
      }
    }
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
      solutionGrid: List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      ),
    );
  }

  void setLetter(int row, int col, String? letter) {
    // No-op when cell is black.
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
      solutionGrid: state.solutionGrid,
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
    // If a cell becomes black, clear its letter.
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
      solutionGrid: state.solutionGrid,
    );
  }

  /// Clear any letters that do not match puzzle answers.
  /// Uses `incorrectLetterCleaner` service and flashes cleared cells.
  void clearIncorrectLetters() {
    final cleaner = ref.read(incorrectLetterCleanerProvider);
    final result = cleaner.cleanWithResult(state);
    state = result.board;

    if (result.clearedCells.isNotEmpty) {
      // Flash cleared cells via provider then clear the flash after a delay.
      ref.read(flashingClearedCellsProvider.notifier).value = result
          .clearedCells
          .toSet();
      Future.delayed(const Duration(milliseconds: 700), () {
        try {
          ref.read(flashingClearedCellsProvider.notifier).value = <String>{};
        } on Object catch (e, st) {
          developer.log(
            'Clearing flashing cleared cells failed',
            error: e,
            stackTrace: st,
          );
        }
      });
    }
  }
}

/// Provider to load the puzzle asynchronously from JSON.
final puzzleLoaderProvider = FutureProvider<GameBoard>(
  (ref) async => loadPuzzleFromAsset('assets/data/nyt2005-01-01.json'),
);

/// Main game board provider (uses the loaded puzzle or fallback to empty).
final gameBoardProvider = NotifierProvider<GameBoardNotifier, GameBoard>(
  GameBoardNotifier.new,
);

/// Load a puzzle from a JSON asset file and convert to GameBoard.
Future<GameBoard> loadPuzzleFromAsset(String assetPath) async {
  // Load JSON from assets and parse
  final jsonString = await rootBundle.loadString(assetPath);
  final jsonData = json.decode(jsonString) as Map<String, dynamic>;
  final puzzle = Puzzle.fromJson(jsonData);

  if (kDebugMode) {
    developer.log(
      'loadPuzzleFromAsset: loaded puzzle id=${puzzle.id} declared rows=${puzzle.rows} cols=${puzzle.cols}',
      name: 'GameProviders',
    );
  }

  // Control prefill via a Dart define: `--dart-define=PREFILL_PUZZLE=true`
  const prefillEnv = bool.fromEnvironment(
    'PREFILL_PUZZLE',
    defaultValue: false,
  );
  const shouldPrefill = kDebugMode && prefillEnv;

  var board = PuzzleConverter.puzzleToGameBoard(
    puzzle,
    preFillSolutions: shouldPrefill,
  );

  if (kDebugMode) {
    developer.log(
      'loadPuzzleFromAsset: converted board id=${board.id} gridSize=${board.gridSize} rows=${board.grid.length} cols=${board.grid.isEmpty ? 0 : board.grid[0].length}',
      name: 'GameProviders',
    );
  }

  // If prefill is active, clear exactly one non-black cell to leave a single
  // missing letter for quick manual completion during testing.
  if (shouldPrefill) {
    board = _prefillExceptOne(board);
  }

  return board;
}

GameBoard _prefillExceptOne(GameBoard board) {
  // Prefer clearing the center cell to make the prefill deterministic and
  // easy to find during manual testing. If center is black or not prefilled,
  // fall back to the first available prefilled cell.
  final coords = <MapEntry<int, int>>[];
  for (var r = 0; r < board.gridSize; r++) {
    for (var c = 0; c < board.gridSize; c++) {
      if (!board.blackCells[r][c] && (board.grid[r][c] != null)) {
        coords.add(MapEntry(r, c));
      }
    }
  }
  if (coords.isEmpty) {
    return board;
  }

  final centerR = board.gridSize ~/ 2;
  final centerC = board.gridSize ~/ 2;
  MapEntry<int, int>? pick;
  if (centerR >= 0 &&
      centerR < board.gridSize &&
      centerC >= 0 &&
      centerC < board.gridSize &&
      !board.blackCells[centerR][centerC] &&
      board.grid[centerR][centerC] != null) {
    pick = MapEntry(centerR, centerC);
  } else {
    pick = coords.first;
  }

  final newGrid = List<List<String?>>.from(board.grid.map(List<String?>.from));
  newGrid[pick.key][pick.value] = null;
  return board.copyWith(grid: newGrid);
}

/// Create sample board by loading from assets/data/sample_5x5.json
Future<GameBoard> createSampleBoard() async {
  final board = await loadPuzzleFromAsset('assets/data/sample_5x5.json');
  return board;
}

/// Fallback: create empty board if loading fails
GameBoard createEmptyBoard(int size) =>
    GameBoardNotifier._createEmptyBoard(size);

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
    NotifierProvider<SelectedCellNotifier, SelectedCell?>(
      SelectedCellNotifier.new,
    );

/// Holds the current word direction (horizontal or vertical).
class WordDirectionNotifier extends Notifier<WordDirection> {
  @override
  WordDirection build() => _initialWordDirection(ref);
  WordDirection get value => state;
  set value(WordDirection v) => state = v;
}

final wordDirectionProvider =
    NotifierProvider<WordDirectionNotifier, WordDirection>(
      WordDirectionNotifier.new,
    );

// Holds the set of found word keys (format: "row,col,direction")
class FoundWordsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => _initialFoundWords(ref);
  Set<String> get value => state;
  set value(Set<String> v) => state = v;
}

final foundWordsProvider = NotifierProvider<FoundWordsNotifier, Set<String>>(
  FoundWordsNotifier.new,
);

// Holds cells that should flash (format: "row,col")
class FlashingCellsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => _initialFlashingCells(ref);
  Set<String> get value => state;
  set value(Set<String> v) => state = v;
}

final flashingCellsProvider =
    NotifierProvider<FlashingCellsNotifier, Set<String>>(
      FlashingCellsNotifier.new,
    );

// Holds cells that should flash red because they were cleared by the cleaner.
class FlashingClearedCellsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => _initialFlashingClearedCells(ref);
  Set<String> get value => state;
  set value(Set<String> v) => state = v;
}

final flashingClearedCellsProvider =
    NotifierProvider<FlashingClearedCellsNotifier, Set<String>>(
      FlashingClearedCellsNotifier.new,
    );

// Holds cells that are locked (format: "row,col")
class LockedCellsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => _initialLockedCells(ref);
  Set<String> get value => state;
  set value(Set<String> v) => state = v;
}

final lockedCellsProvider = NotifierProvider<LockedCellsNotifier, Set<String>>(
  LockedCellsNotifier.new,
);
// Provider tear-offs for initial values.
SelectedCell? _initialSelectedCell(ref) => null;
WordDirection _initialWordDirection(ref) => WordDirection.horizontal;
Set<String> _initialFoundWords(ref) => <String>{};
Set<String> _initialFlashingCells(ref) => <String>{};
Set<String> _initialLockedCells(ref) => <String>{};
Set<String> _initialFlashingClearedCells(ref) => <String>{};
