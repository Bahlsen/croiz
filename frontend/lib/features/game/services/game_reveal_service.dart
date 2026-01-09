import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/features/game/providers/word_check_provider.dart';

part 'game_reveal_service.g.dart';

/// Result of a reveal operation.
class RevealResult {
  RevealResult({
    required this.newGrid,
    required this.newFoundWords,
    required this.newLockedCells,
    required this.cellsToFlash,
    required this.hasChanges,
  });
  final List<List<String?>> newGrid;
  final Set<String> newFoundWords;
  final Set<CellKey> newLockedCells;
  final Set<CellKey> cellsToFlash;
  final bool hasChanges;
}

/// Service responsible for puzzle reveal operations.
///
/// Extracted from GameBoardNotifier to follow Single Responsibility Principle.
/// Handles revealing a single letter, a whole word, or the entire puzzle.
class GameRevealService {
  GameRevealService(this._wordCheck);

  final WordCheckService _wordCheck;

  /// Reveals a single cell.
  String? revealLetterAt({
    required GameBoard board,
    required int row,
    required int col,
  }) {
    final solutionGrid = board.solutionGrid;
    return solutionGrid?[row][col];
  }

  /// Reveals the solution letter at the given cell.
  void revealLetter({
    required CellKey cell,
    required GameBoard board,
    required List<List<String?>> currentGrid,
    required void Function(List<List<String?>> grid) setGrid,
    required void Function(Set<CellKey> cells) triggerFlash,
    required (void Function(), void Function()) soundCallbacks,
  }) {
    final solutionGrid = board.solutionGrid;
    if (solutionGrid == null) {
      return;
    }

    final (playSuccess, _) = soundCallbacks;

    final solution = solutionGrid[cell.row][cell.col];
    if (solution == null) {
      return;
    }

    final newGrid = currentGrid.map(List<String?>.from).toList();
    newGrid[cell.row][cell.col] = solution;

    setGrid(newGrid);
    triggerFlash({cell});

    // Play reveal sound
    playSuccess();
  }

  /// Reveals the selected word.
  RevealResult revealEntry({
    required GameBoard board,
    required PuzzleEntryData entry,
    required Set<String> currentFoundWords,
    required Set<CellKey> currentLockedCells,
  }) {
    final solutionGrid = board.solutionGrid;
    if (solutionGrid == null) {
      return RevealResult(
        newGrid: board.grid,
        newFoundWords: currentFoundWords,
        newLockedCells: currentLockedCells,
        cellsToFlash: {},
        hasChanges: false,
      );
    }

    final newGrid = board.grid.map(List<String?>.from).toList();
    final affectedCells = <CellKey>{};

    for (var i = 0; i < entry.length; i++) {
      final r = entry.direction == 'across' ? entry.y : entry.y + i;
      final c = entry.direction == 'across' ? entry.x + i : entry.x;

      final solution = solutionGrid[r][c];
      if (solution != null) {
        newGrid[r][c] = solution;
        affectedCells.add(CellKey(r, c));
      }
    }

    final newFound = Set<String>.from(currentFoundWords)
      ..add(_wordCheck.getWordKey(entry));
    final newLocked = Set<CellKey>.from(currentLockedCells)
      ..addAll(affectedCells);

    return RevealResult(
      newGrid: newGrid,
      newFoundWords: newFound,
      newLockedCells: newLocked,
      cellsToFlash: affectedCells,
      hasChanges: true,
    );
  }

  /// Reveals the entire puzzle.
  RevealResult revealAll({
    required GameBoard board,
    required Set<String> currentFoundWords,
    required Set<CellKey> currentLockedCells,
    required Set<CellKey> currentlyFlashing,
  }) {
    final solutionGrid = board.solutionGrid;
    if (solutionGrid == null) {
      return RevealResult(
        newGrid: board.grid,
        newFoundWords: currentFoundWords,
        newLockedCells: currentLockedCells,
        cellsToFlash: {},
        hasChanges: false,
      );
    }

    final newGrid = solutionGrid.map(List<String?>.from).toList();
    final newFound = _wordCheck.scanForCompletedWords(board, newGrid);
    final newLocked = <CellKey>{};
    if (board.entries != null) {
      for (final entry in board.entries!) {
        if (newFound.contains(_wordCheck.getWordKey(entry))) {
          newLocked.addAll(_wordCheck.getCellKeys(entry));
        }
      }
    }

    final cellsToFlash = newLocked.difference(currentLockedCells);

    return RevealResult(
      newGrid: newGrid,
      newFoundWords: newFound,
      newLockedCells: newLocked,
      cellsToFlash: cellsToFlash,
      hasChanges: true,
    );
  }

  /// Trigger visual feedback for revealed cells.
  void triggerFlash({
    required Set<CellKey> cells,
    required void Function(Set<CellKey> cells) setFlashingCells,
    required Duration Function() getFlashDelay,
    required void Function() playSuccess,
    required bool Function() shouldPlaySound,
  }) {
    if (cells.isEmpty) {
      return;
    }

    setFlashingCells(cells);
    if (shouldPlaySound()) {
      playSuccess();
    }

    final delay = getFlashDelay();
    if (delay == Duration.zero) {
      setFlashingCells(<CellKey>{});
    } else {
      Future.delayed(delay, () => setFlashingCells(<CellKey>{}));
    }
  }
}

@Riverpod(keepAlive: true, dependencies: [wordCheckService])
GameRevealService gameRevealService(Ref ref) {
  final wordCheck = ref.watch(wordCheckServiceProvider);
  return GameRevealService(wordCheck);
}
