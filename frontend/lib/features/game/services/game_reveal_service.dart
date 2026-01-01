import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/utils/flash_utils.dart';

/// Result of a reveal operation containing updated state.
class RevealResult {
  const RevealResult({
    required this.newGrid,
    required this.newFoundWords,
    required this.newLockedCells,
    required this.cellsToFlash,
    required this.hasChanges,
  });

  /// No-op result when nothing was revealed.
  factory RevealResult.noOp(GameBoard board) => RevealResult(
    newGrid: board.grid,
    newFoundWords: const <String>{},
    newLockedCells: const <CellKey>{},
    cellsToFlash: const <CellKey>{},
    hasChanges: false,
  );

  final List<List<String?>> newGrid;
  final Set<String> newFoundWords;
  final Set<CellKey> newLockedCells;
  final Set<CellKey> cellsToFlash;
  final bool hasChanges;
}

/// Service responsible for puzzle reveal operations.
///
/// Extracted from GameBoardNotifier to follow Single Responsibility Principle.
/// Handles reveal letter, reveal entry, and reveal all operations.
class GameRevealService {
  const GameRevealService();

  /// Reveal a single letter at the given cell.
  /// Returns the revealed letter or null if no reveal was possible.
  String? revealLetterAt({
    required GameBoard board,
    required int row,
    required int col,
  }) {
    final sol = board.solutionGrid;
    if (sol == null) {
      return null;
    }
    if (row < 0 || row >= sol.length) {
      return null;
    }
    if (col < 0 || col >= sol[row].length) {
      return null;
    }
    return sol[row][col];
  }

  /// Reveal an entire entry (word).
  /// Returns RevealResult with updated grid and cells to flash.
  RevealResult revealEntry({
    required GameBoard board,
    required PuzzleEntryData entry,
    required Set<String> currentFoundWords,
    required Set<CellKey> currentLockedCells,
    required String Function(PuzzleEntryData) getWordKey,
    required List<CellKey> Function(PuzzleEntryData) getCellKeys,
  }) {
    final sol = board.solutionGrid;
    if (sol == null) {
      return RevealResult.noOp(board);
    }

    final key = getWordKey(entry);
    final entryCellKeys = getCellKeys(entry);

    // If already found or locked, treat as no-op
    if (currentFoundWords.contains(key) ||
        currentLockedCells.containsAll(entryCellKeys)) {
      return RevealResult.noOp(board);
    }

    final newGrid = board.grid.map(List<String?>.from).toList();
    final cells = <CellKey>{};

    if (entry.direction == 'across') {
      final row = entry.y;
      for (var i = 0; i < entry.length; i++) {
        final col = entry.x + i;
        if (row >= 0 && row < sol.length && col >= 0 && col < sol[row].length) {
          newGrid[row][col] = sol[row][col];
          cells.add(CellKey(row, col));
        }
      }
    } else {
      final col = entry.x;
      for (var i = 0; i < entry.length; i++) {
        final row = entry.y + i;
        if (row >= 0 && row < sol.length && col >= 0 && col < sol[row].length) {
          newGrid[row][col] = sol[row][col];
          cells.add(CellKey(row, col));
        }
      }
    }

    final newFound = Set<String>.from(currentFoundWords)..add(key);
    final newLocked = Set<CellKey>.from(currentLockedCells)..addAll(cells);

    return RevealResult(
      newGrid: newGrid,
      newFoundWords: newFound,
      newLockedCells: newLocked,
      cellsToFlash: cells,
      hasChanges: true,
    );
  }

  /// Reveal the entire puzzle.
  /// Returns RevealResult with updated grid and cells to flash (only newly revealed).
  RevealResult revealAll({
    required GameBoard board,
    required Set<String> currentFoundWords,
    required Set<CellKey> currentLockedCells,
    required Set<CellKey> currentlyFlashing,
    required bool Function(GameBoard, PuzzleEntryData) isWordComplete,
    required String Function(PuzzleEntryData) getWordKey,
    required List<CellKey> Function(PuzzleEntryData) getCellKeys,
  }) {
    final sol = board.solutionGrid;
    if (sol == null) {
      return RevealResult.noOp(board);
    }

    final entries = board.entries;
    // Early return if already complete
    if (entries != null && entries.isNotEmpty) {
      if (currentFoundWords.length == entries.length) {
        return RevealResult.noOp(board);
      }
    }

    // Capture state before reveal
    final beforeBoard = board;
    final newGrid = sol.map(List<String?>.from).toList();
    final afterBoard = board.copyWith(grid: newGrid);

    // Determine which entries are newly completed
    final allKeys = <String>{};
    final newlyFound = <String>{};
    final newCells = <CellKey>{};

    if (entries != null) {
      for (final e in entries) {
        final key = getWordKey(e);
        allKeys.add(key);

        final wasComplete = isWordComplete(beforeBoard, e);
        final isCompleteNow = isWordComplete(afterBoard, e);
        final cellKeys = getCellKeys(e);
        final wasLocked = currentLockedCells.containsAll(cellKeys);

        if (!wasComplete &&
            isCompleteNow &&
            !currentFoundWords.contains(key) &&
            !wasLocked) {
          newlyFound.add(key);
          newCells.addAll(cellKeys);
        }
      }
    }

    // Filter out cells that are already flashing
    final toFlash =
        newCells.where((c) => !currentlyFlashing.contains(c)).toSet();

    // Lock all non-black cells
    final locked = <CellKey>{};
    for (var r = 0; r < newGrid.length; r++) {
      for (var c = 0; c < newGrid[r].length; c++) {
        if (!board.blackCells[r][c]) {
          locked.add(CellKey(r, c));
        }
      }
    }

    // If no entries metadata, all cells should flash
    if (entries == null || entries.isEmpty) {
      return RevealResult(
        newGrid: newGrid,
        newFoundWords: allKeys,
        newLockedCells: locked,
        cellsToFlash: locked,
        hasChanges: true,
      );
    }

    return RevealResult(
      newGrid: newGrid,
      newFoundWords: allKeys,
      newLockedCells: locked,
      cellsToFlash: toFlash,
      hasChanges: newlyFound.isNotEmpty || toFlash.isNotEmpty,
    );
  }

  /// Helper to trigger flash animation and play sound.
  void triggerFlash({
    required Set<CellKey> cells,
    required void Function(Set<CellKey>) setFlashingCells,
    required Duration Function() getFlashDelay,
    required Future<void> Function() playSuccess,
    bool Function()? shouldPlaySound,
  }) {
    if (cells.isEmpty) {
      return;
    }
    triggerFlashAndPlaySuccess(
      cells,
      setFlashingCells,
      getFlashDelay,
      playSuccess: playSuccess,
      shouldPlaySound: shouldPlaySound,
    );
  }
}

/// Provider for the reveal service.
final gameRevealServiceProvider = Provider<GameRevealService>(
  (ref) => const GameRevealService(),
);
