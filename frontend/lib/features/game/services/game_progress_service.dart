import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/features/game/providers/word_check_provider.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart'
    show PuzzleStorageInterface;
import 'package:croiz/services/persistence/storage_provider.dart';

part 'game_progress_service.g.dart';

/// Result of computing initial state from grid.
class InitialStateResult {
  InitialStateResult({required this.foundWords, required this.lockedCells});
  final Set<String> foundWords;
  final Set<CellKey> lockedCells;
  bool get isEmpty => foundWords.isEmpty && lockedCells.isEmpty;
}

/// Service responsible for loading and restoring puzzle progress.
///
/// Extracted from GameBoardNotifier to follow Single Responsibility Principle.
/// Handles coordinate mapping and state reconstruction from persistent storage.
class GameProgressService {
  GameProgressService(this._wordCheck, this._storage);

  final WordCheckService _wordCheck;
  final PuzzleStorageInterface _storage;

  /// Loads progress for a given puzzle from storage and applies it to the board.
  ///
  /// This operation is asynchronous and reconstructs foundWords, lockedCells,
  /// and the play grid.
  Future<void> loadProgress({
    required GameBoard board,
    required void Function(List<List<String?>> grid) setGrid,
    required void Function(Set<String> found) setFoundWords,
    required void Function(Set<CellKey> locked) setLockedCells,
    required void Function(int seconds)? setElapsedSeconds,
  }) async {
    try {
      print('GameProgressService: Attempting to load progress for ${board.id}');
      final savedData = await _storage.load(board.id);
      print(
        'GameProgressService: Loaded data for ${board.id}: ${savedData != null ? 'Found' : 'Null'}',
      );
      if (savedData == null) return;

      // 1. Restore Grid
      final savedGrid = savedData['grid'];
      if (savedGrid is List) {
        final newGrid = board.grid.map(List<String?>.from).toList();
        for (var r = 0; r < savedGrid.length && r < newGrid.length; r++) {
          final rowData = savedGrid[r];
          if (rowData is List) {
            for (var c = 0; c < rowData.length && c < newGrid[r].length; c++) {
              final val = rowData[c];
              if (val is String?) {
                newGrid[r][c] = val;
              }
            }
          }
        }
        setGrid(newGrid);
      }

      // 2. Restore Found Words
      final savedFound = savedData['foundWords'];
      if (savedFound is List) {
        setFoundWords(savedFound.map((e) => e.toString()).toSet());
      } else {
        // Legacy/Fallback: Re-scan grid if foundWords is missing
        final found = _wordCheck.scanForCompletedWords(board, board.grid);
        setFoundWords(found);
      }

      // 3. Restore Locked Cells
      final savedLocked = savedData['lockedCells'];
      print('Restoring progress for ${board.id}, savedLocked: $savedLocked');
      if (savedLocked is List) {
        final locked = <CellKey>{};
        for (final entry in savedLocked) {
          final parts = entry.toString().split(',');
          if (parts.length == 2) {
            final r = int.tryParse(parts[0]);
            final c = int.tryParse(parts[1]);
            if (r != null && c != null) {
              locked.add(CellKey(r, c));
            }
          }
        }
        print('Restored locked cells: $locked');
        setLockedCells(locked);
      }

      // 4. Restore Elapsed Time
      final savedElapsed = savedData['elapsedSeconds'];
      if (savedElapsed is int && setElapsedSeconds != null) {
        setElapsedSeconds(savedElapsed);
      }
    } on Object catch (e, st) {
      print('GameProgressService: Failed to load progress: $e\n$st');
    }
  }

  /// Scans the grid for completed words and returns the found/locked sets.
  InitialStateResult computeInitialState({required GameBoard board}) {
    final found = _wordCheck.scanForCompletedWords(board, board.grid);
    final locked = <CellKey>{};
    if (board.entries != null) {
      for (final entry in board.entries!) {
        if (found.contains(_wordCheck.getWordKey(entry))) {
          locked.addAll(_wordCheck.getCellKeys(entry));
        }
      }
    }
    return InitialStateResult(foundWords: found, lockedCells: locked);
  }

  /// Helper to check completion at a specific position.
  CheckCompletionResult checkCompletionAtPos({
    required GameBoard board,
    required CellKey pos,
    required Set<String> currentFoundWords,
  }) {
    final newlyFound = <String>{};
    final cellsToFlash = <CellKey>{};
    final entries = board.entries;

    if (entries == null) {
      return CheckCompletionResult(
        newlyFoundWords: {},
        cellsToFlash: {},
        hasChanges: false,
      );
    }

    for (final entry in entries) {
      final key = _wordCheck.getWordKey(entry);
      if (currentFoundWords.contains(key)) continue;

      final keys = _wordCheck.getCellKeys(entry);
      if (keys.contains(pos)) {
        if (_wordCheck.isWordComplete(board, entry)) {
          newlyFound.add(key);
          cellsToFlash.addAll(keys);
        }
      }
    }

    return CheckCompletionResult(
      newlyFoundWords: newlyFound,
      cellsToFlash: cellsToFlash,
      hasChanges: newlyFound.isNotEmpty,
    );
  }
}

/// Result of checking completion at a position.
class CheckCompletionResult {
  CheckCompletionResult({
    required this.newlyFoundWords,
    required this.cellsToFlash,
    required this.hasChanges,
  });
  final Set<String> newlyFoundWords;
  final Set<CellKey> cellsToFlash;
  final bool hasChanges;
}

@Riverpod(keepAlive: true, dependencies: [wordCheckService, puzzleStorage])
GameProgressService gameProgressService(Ref ref) {
  print('DEBUG: gameProgressService provider called');
  final wordCheck = ref.watch(wordCheckServiceProvider);
  final storage = ref.watch(puzzleStorageProvider);
  return GameProgressService(wordCheck, storage);
}
