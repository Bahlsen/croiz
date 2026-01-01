import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/persistence/hive_puzzle_storage.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart'
    show PuzzleStorageInterface;

/// Result of loading puzzle progress from storage.
class ProgressLoadResult {
  const ProgressLoadResult({
    required this.grid,
    required this.foundWords,
    required this.lockedCells,
    required this.elapsedSeconds,
  });

  /// Empty result when no progress was stored.
  static const empty = ProgressLoadResult(
    grid: null,
    foundWords: null,
    lockedCells: null,
    elapsedSeconds: null,
  );

  final List<List<String?>>? grid;
  final Set<String>? foundWords;
  final Set<CellKey>? lockedCells;
  final int? elapsedSeconds;

  bool get hasData =>
      grid != null ||
      foundWords != null ||
      lockedCells != null ||
      elapsedSeconds != null;
}

/// Service responsible for loading and restoring puzzle progress.
///
/// Extracted from GameBoardNotifier to follow Single Responsibility Principle.
/// Handles loading persisted progress and computing initial state from grid.
class GameProgressService {
  GameProgressService({PuzzleStorageInterface? storage})
    : _storage = storage ?? HivePuzzleStorage();

  final PuzzleStorageInterface _storage;

  /// Load persisted progress for a puzzle.
  Future<ProgressLoadResult> loadProgress(
    String puzzleId, {
    required int expectedRows,
    required int expectedCols,
  }) async {
    try {
      final stored = await _storage.load(puzzleId);
      if (stored == null) {
        return ProgressLoadResult.empty;
      }

      // Parse grid
      List<List<String?>>? grid;
      final gridData = stored['grid'];
      if (gridData is List) {
        final rows = gridData.length;
        final cols =
            rows > 0 && gridData[0] is List ? (gridData[0] as List).length : 0;
        if (rows == expectedRows && cols == expectedCols) {
          final newGrid = <List<String?>>[];
          for (final r in gridData) {
            final rowList = <String?>[];
            for (final c in (r as List)) {
              if (c == null) {
                rowList.add(null);
              } else {
                rowList.add(c.toString());
              }
            }
            newGrid.add(rowList);
          }
          grid = newGrid;
        }
      }

      // Parse found words
      Set<String>? foundWords;
      final found = stored['foundWords'];
      if (found is List) {
        foundWords = found.cast<String>().toSet();
      }

      // Parse locked cells
      Set<CellKey>? lockedCells;
      final locked = stored['lockedCells'];
      if (locked is List) {
        final set = <CellKey>{};
        for (final s in locked) {
          if (s is String) {
            final parts = s.split(',');
            if (parts.length == 2) {
              final r = int.tryParse(parts[0]);
              final c = int.tryParse(parts[1]);
              if (r != null && c != null) {
                set.add(CellKey(r, c));
              }
            }
          }
        }
        lockedCells = set;
      }

      // Parse elapsed time
      int? elapsedSeconds;
      final timerVal = stored['elapsedSeconds'];
      if (timerVal is num) {
        elapsedSeconds = timerVal.toInt();
      }

      return ProgressLoadResult(
        grid: grid,
        foundWords: foundWords,
        lockedCells: lockedCells,
        elapsedSeconds: elapsedSeconds,
      );
    } on Object catch (e, st) {
      if (kDebugMode) {
        developer.log('Failed to load puzzle progress: $e', stackTrace: st);
      }
      return ProgressLoadResult.empty;
    }
  }

  /// Compute initial found/locked words from current grid state.
  /// Used when no stored progress exists.
  InitialStateResult computeInitialState({
    required GameBoard board,
    required bool Function(GameBoard, PuzzleEntryData) isWordComplete,
    required String Function(PuzzleEntryData) getWordKey,
    required List<CellKey> Function(PuzzleEntryData) getCellKeys,
  }) {
    final entries = board.entries;
    if (entries == null || entries.isEmpty) {
      return InitialStateResult.empty;
    }

    final newFound = <String>{};
    final newLocked = <CellKey>{};

    for (final entry in entries) {
      if (isWordComplete(board, entry)) {
        final key = getWordKey(entry);
        newFound.add(key);
        newLocked.addAll(getCellKeys(entry));
      }
    }

    return InitialStateResult(foundWords: newFound, lockedCells: newLocked);
  }

  /// Checks for word completion at a specific cell position.
  /// returns a result containing newly found words and cells to flash/lock.
  WordCompletionResult checkCompletionAtPos({
    required GameBoard board,
    required CellKey pos,
    required Set<String> currentFoundWords,
    required bool Function(GameBoard, PuzzleEntryData) isWordComplete,
    required String Function(PuzzleEntryData) getWordKey,
    required List<CellKey> Function(PuzzleEntryData) getCellKeys,
  }) {
    final allEntries = board.entries;
    if (allEntries == null) {
      return WordCompletionResult.empty;
    }

    final entriesForCell =
        allEntries.where((e) {
          final isAcross = e.directionEnum == EntryDirection.across;
          if (isAcross) {
            return e.y == pos.row &&
                (pos.col >= e.x && pos.col < e.x + e.length);
          } else {
            return e.x == pos.col &&
                (pos.row >= e.y && pos.row < e.y + e.length);
          }
        }).toList();

    if (entriesForCell.isEmpty) {
      return WordCompletionResult.empty;
    }

    final newlyFound = <String>{};
    final cellsToFlash = <CellKey>{};

    for (final e in entriesForCell) {
      if (isWordComplete(board, e)) {
        final key = getWordKey(e);
        if (!currentFoundWords.contains(key)) {
          newlyFound.add(key);
          cellsToFlash.addAll(getCellKeys(e));
        }
      }
    }

    return WordCompletionResult(
      newlyFoundWords: newlyFound,
      cellsToFlash: cellsToFlash,
    );
  }
}

/// Result of checking word completion.
class WordCompletionResult {
  const WordCompletionResult({
    required this.newlyFoundWords,
    required this.cellsToFlash,
  });

  static const empty = WordCompletionResult(
    newlyFoundWords: <String>{},
    cellsToFlash: <CellKey>{},
  );

  final Set<String> newlyFoundWords;
  final Set<CellKey> cellsToFlash;

  bool get hasChanges => newlyFoundWords.isNotEmpty;
}

/// Result of computing initial state from grid.
class InitialStateResult {
  const InitialStateResult({
    required this.foundWords,
    required this.lockedCells,
  });

  static const empty = InitialStateResult(
    foundWords: <String>{},
    lockedCells: <CellKey>{},
  );

  final Set<String> foundWords;
  final Set<CellKey> lockedCells;

  bool get isEmpty => foundWords.isEmpty && lockedCells.isEmpty;
}

/// Provider for the progress service.
final gameProgressServiceProvider = Provider<GameProgressService>(
  (ref) => GameProgressService(),
);
