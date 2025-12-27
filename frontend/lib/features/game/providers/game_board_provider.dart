import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/helpers/board_helpers.dart';
import 'package:croiz/features/game/services/incorrect_letter_cleaner.dart';
import 'package:croiz/services/providers.dart';

import 'puzzle_loader_provider.dart';
import 'game_state_providers.dart';

/// Duration used to schedule clearing of flashed cells after animations.
/// Tests can override this provider to `Duration.zero` to avoid scheduling
/// real timers (FakeAsync-friendly).
final flashClearDelayProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 500),
);

/// Debounce delay for word completion checks during fast typing.
/// In production: 16ms (one frame) to batch checks while staying responsive.
/// Tests can override to Duration.zero for synchronous checks.
final wordCheckDebounceDelayProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 16),
);

/// Main notifier for the game board state.
class GameBoardNotifier extends Notifier<GameBoard> {
  bool _listenerAttached = false;

  @override
  GameBoard build() {
    if (!_listenerAttached) {
      _listenerAttached = true;
      ref.listen<AsyncValue<GameBoard>>(
        puzzleLoaderProvider,
        _onPuzzleLoaderChanged,
        fireImmediately: false,
      );

      final current = ref.read(puzzleLoaderProvider);
      if (current is AsyncData<GameBoard>) {
        state = current.value;
        Future.microtask(() => _onPuzzleLoaderChanged(null, current));
      }
    }

    final puzzleAsync = ref.watch(puzzleLoaderProvider);

    return puzzleAsync.when(
      data: (d) => d,
      loading: () {
        final selected = ref.read(selectedPuzzleIdProvider);
        if (selected == null) {
          throw StateError('No puzzle selected');
        }
        throw StateError('Puzzle is loading: $selected');
      },
      error: (e, st) {
        final selected = ref.read(selectedPuzzleIdProvider) ?? '<null>';
        throw StateError('Failed to load puzzle id="$selected": $e');
      },
    );
  }

  void _onPuzzleLoaderChanged(
    AsyncValue<GameBoard>? prev,
    AsyncValue<GameBoard> next,
  ) {
    if (!ref.mounted) {
      return;
    }
    if (next is AsyncData<GameBoard>) {
      if (state.id != next.value.id) {
        state = next.value;
      }

      // Attempt to restore persisted progress for this puzzle id.
      () async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final key = 'puzzle_progress:${state.id}';
          final raw = prefs.getString(key);
          if (raw != null && raw.isNotEmpty) {
            final parsed = jsonDecode(raw) as Map<String, dynamic>;
            final gridData = parsed['grid'];
            if (gridData is List) {
              // Only apply if dimensions match to avoid corrupting board.
              final rows = gridData.length;
              final cols = rows > 0 && gridData[0] is List ? (gridData[0] as List).length : 0;
              if (rows == state.grid.length && cols == state.grid[0].length) {
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
                state = state.copyWith(grid: newGrid);
              }
            }
          }
        } on Object catch (e, st) {
          if (kDebugMode) {
            developer.log('Failed to restore puzzle progress: $e', stackTrace: st);
          }
        }
      }();

      final entries = state.entries;
      if (entries != null && entries.isNotEmpty) {
        try {
          final wordCheck = ref.read(wordCheckServiceProvider);
          final newFound = <String>{};
          final newLocked = <CellKey>{};
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
          if (kDebugMode) {
            debugPrint('Error updating found/locked words: $e\n$stack');
          }
        }
      }
    }
  }

  void setLetter(int row, int col, String? letter) {
    if (state.blackCells.isDisabled(row, col)) {
      return;
    }
    final normalizedLetter = letter == null || letter.isEmpty
        ? null
        : letter.substring(0, 1).toUpperCase();
    if (state.grid[row][col] == normalizedLetter) {
      return;
    }
    final newGrid = List<List<String?>>.of(state.grid);
    final rowCopy = List<String?>.of(newGrid[row]);
    rowCopy[col] = normalizedLetter;
    newGrid[row] = rowCopy;
    state = state.copyWith(grid: newGrid);
    _persistProgress();
  }

  void toggleBlackCell(int row, int col) {
    final newGrid = List<List<String?>>.from(
      state.grid.map(List<String?>.from),
    );
    final newBlack = List<List<bool>>.from(
      state.blackCells.map(List<bool>.from),
    );
    newBlack[row][col] = !newBlack[row][col];
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
    _persistProgress();
  }

  set board(GameBoard board) {
    state = board;
    _persistProgress();
  }

  GameBoard get board => state;

  void clearIncorrectLetters() {
    final cleaner = ref.read(incorrectLetterCleanerProvider);
    final result = cleaner.cleanWithResult(state);
    state = result.board;

    _persistProgress();

    if (result.clearedCells.isNotEmpty) {
      ref.read(flashingClearedCellsProvider.notifier).value = result
          .clearedCells
          .toSet();
      final delay = ref.read(flashClearDelayProvider);
      if (delay == Duration.zero) {
        Future.microtask(() {
          try {
            ref.read(flashingClearedCellsProvider.notifier).value = <CellKey>{};
          } on Object catch (e, st) {
            developer.log(
              'Clearing flashing cleared cells failed',
              error: e,
              stackTrace: st,
            );
          }
        });
      } else {
        Future.delayed(delay, () {
          try {
            ref.read(flashingClearedCellsProvider.notifier).value = <CellKey>{};
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

  Future<void> _persistProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'puzzle_progress:${state.id}';
      final payload = jsonEncode({
        'grid': state.grid,
        'savedAt': DateTime.now().toIso8601String(),
      });
      await prefs.setString(key, payload);
    } on Object catch (e, st) {
      if (kDebugMode) {
        developer.log('Failed to persist puzzle progress: $e', stackTrace: st);
      }
    }
  }
}

/// Main game board provider.
final gameBoardProvider = NotifierProvider<GameBoardNotifier, GameBoard>(
  GameBoardNotifier.new,
);
