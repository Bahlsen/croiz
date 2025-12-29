import 'dart:developer' as developer;
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/helpers/board_helpers.dart';
import 'package:croiz/features/game/services/incorrect_letter_cleaner.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/utils/flash_utils.dart';

import 'puzzle_loader_provider.dart';
import 'game_state_providers.dart';
import 'game_timer_provider.dart';
import 'package:croiz/services/persistence/hive_puzzle_storage.dart';

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
  Timer? _persistTimer;
  static const Duration _persistDebounce = Duration(milliseconds: 200);

  // Compatibility helper used by tests and legacy call sites.
  void setBoard(GameBoard board) => state = board;

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
        unawaited(
          Future.microtask(() => _onPuzzleLoaderChanged(null, current)),
        );
      }
      // Cancel any pending timers when the notifier is disposed by Riverpod.
      ref.onDispose(() {
        try {
          _persistTimer?.cancel();
        } on Object {
          // ignore
        }
      });
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
    if (next is! AsyncData<GameBoard>) {
      return;
    }

    // Ensure local state reflects the loaded puzzle. Only replace the local
    // state when a different puzzle is loaded to avoid overwriting any
    // in-memory modifications (e.g. tests that call notifier methods
    // immediately after provider resolution).
    final loaded = next.value;
    try {
      if (state.id != loaded.id) {
        state = loaded;
      }
    } on Object {
      // If state is not yet initialised or any error occurs, fall back to
      // assigning the loaded value.
      state = loaded;
    }

    // Attempt to restore persisted progress for this puzzle id.
    () async {
      try {
        final stored = await HivePuzzleStorage.load(state.id);
        if (!ref.mounted) {
          return;
        }
        if (stored != null) {
          final gridData = stored['grid'];
          if (gridData is List) {
            final rows = gridData.length;
            final cols = rows > 0 && gridData[0] is List
                ? (gridData[0] as List).length
                : 0;
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

          // restore found/locked words or timer when present
          try {
            final found = stored['foundWords'];
              if (found is List) {
              ref
                .read(foundWordsProvider.notifier)
                .setFoundWords(found.cast<String>().toSet());
              try {
                _triggerEndGameIfSolved(playVictorySound: false);
              } on Object {
                // ignore
              }
            }
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
              ref.read(lockedCellsProvider.notifier).setLockedCells(set);
            }
            final timerVal = stored['elapsedSeconds'];
            if (timerVal is num) {
              unawaited(
                ref
                    .read(gameTimerProvider(state.id))
                    .setElapsed(timerVal.toInt()),
              );
            }
          } on Object catch (_) {
            // ignore per-field restore errors
          }
        }
      } on Object catch (e, st) {
        if (kDebugMode) {
          developer.log(
            'Failed to restore puzzle progress: $e',
            stackTrace: st,
          );
        }
      }
    }();

    // Populate initial found/locked sets based on current grid state.
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
          ref.read(foundWordsProvider.notifier).setFoundWords(newFound);
        }
        if (newLocked.isNotEmpty) {
          ref.read(lockedCellsProvider.notifier).setLockedCells(newLocked);
        }
        try {
          _triggerEndGameIfSolved(playVictorySound: false);
        } on Object {
          // ignore
        }
      } on Object catch (e, stack) {
        if (kDebugMode) {
          debugPrint('Error updating found/locked words: $e\n$stack');
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
    _schedulePersist();
    // Check end-game in case foundWords were updated elsewhere synchronously
    try {
      _triggerEndGameIfSolved();
    } on Object {
      // ignore
    }
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
    _schedulePersist();
  }

  // Deprecated public property accessors removed in favor of explicit API.
  // Use `setBoard(GameBoard)` to update the board and read the provider
  // state via `ref.watch(gameBoardProvider)` or `container.read(gameBoardProvider)`.

  void clearIncorrectLetters() {
    final cleaner = ref.read(incorrectLetterCleanerProvider);
    final result = cleaner.cleanWithResult(state);
    state = result.board;

    _schedulePersist();

        if (result.clearedCells.isNotEmpty) {
        ref.read(flashingClearedCellsProvider.notifier)
          .setFlashingClearedCells(result.clearedCells.toSet());
      final delay = ref.read(flashClearDelayProvider);
            if (delay == Duration.zero) {
        unawaited(
          Future.microtask(() {
            try {
              ref
                  .read(flashingClearedCellsProvider.notifier)
                  .setFlashingClearedCells(<CellKey>{});
            } on Object catch (e, st) {
              developer.log(
                'Clearing flashing cleared cells failed',
                error: e,
                stackTrace: st,
              );
            }
          }),
        );
      } else {
        Future.delayed(delay, () {
          try {
            ref
                .read(flashingClearedCellsProvider.notifier)
                .setFlashingClearedCells(<CellKey>{});
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

  /// Reveal the solution letter at the given cell (if available).
  void revealLetterAt(int row, int col) {
    final sol = state.solutionGrid;
    if (sol == null) {
      return;
    }
    if (row < 0 || row >= sol.length) {
      return;
    }
    if (col < 0 || col >= sol[row].length) {
      return;
    }
    final letter = sol[row][col];
    if (letter == null) {
      return;
    }
    final newGrid = state.grid.map(List<String?>.from).toList();
    newGrid[row][col] = letter;
    state = state.copyWith(grid: newGrid);
    _schedulePersist();
    // After revealing a letter via the reveal menu, run the same
    // completion check as when the user types so completed words
    // are detected and flash as if the user had filled them.
    try {
      // Directly detect any entries that became complete due to this reveal
      // Use the updated local state directly to avoid stale reads.
      final boardNow = state;
      final allEntries = state.entries;
      List<PuzzleEntryData>? entriesForCell;
      if (allEntries != null && allEntries.isNotEmpty) {
        entriesForCell = allEntries.where((e) {
          final isAcross = e.directionEnum == EntryDirection.across;
          if (isAcross) {
            return e.y == row && (col >= e.x && col < e.x + e.length);
          } else {
            return e.x == col && (row >= e.y && row < e.y + e.length);
          }
        }).toList();
      } else {
        entriesForCell = null;
      }
      if (entriesForCell != null && entriesForCell.isNotEmpty) {
        final wordCheck = ref.read(wordCheckServiceProvider);
        final foundWords = ref.read(foundWordsProvider);
        final locked = ref.read(lockedCellsProvider);
        final newFound = Set<String>.from(foundWords);
        final newLocked = Set<CellKey>.from(locked);
        final allFlashing = <CellKey>{};
        var completed = 0;
        for (final entry in entriesForCell) {
          final key = wordCheck.getWordKey(entry);
          if (foundWords.contains(key)) {
            continue;
          }
          if (wordCheck.isWordComplete(boardNow, entry)) {
            completed++;
            newFound.add(key);
            final keys = wordCheck.getCellKeys(entry);
            newLocked.addAll(keys);
            allFlashing.addAll(keys);
          }
        }
        if (completed > 0) {
          ref.read(foundWordsProvider.notifier).setFoundWords(newFound);
          ref.read(lockedCellsProvider.notifier).setLockedCells(newLocked);
          triggerFlashAndClear(
            allFlashing,
            (v) => ref.read(flashingCellsProvider.notifier).setFlashingCells(v),
            () => ref.read(flashClearDelayProvider),
          );
          try {
            _triggerEndGameIfSolved();
          } on Object {
            // ignore
          }
        }
      }
    } on Object {
      // ignore
    }
  }

  /// Reveal the full entry (word) for the given PuzzleEntryData.
  void revealEntry(PuzzleEntryData entry) {
    final sol = state.solutionGrid;
    if (sol == null) {
      return;
    }
    final newGrid = state.grid.map(List<String?>.from).toList();
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

    state = state.copyWith(grid: newGrid);
    // Mark word as found and lock its cells
    final wordCheck = ref.read(wordCheckServiceProvider);
    final key = wordCheck.getWordKey(entry);
    final newFound = Set<String>.from(ref.read(foundWordsProvider))..add(key);
    ref.read(foundWordsProvider.notifier).setFoundWords(newFound);
    final newLocked = Set<CellKey>.from(ref.read(lockedCellsProvider))
      ..addAll(cells);
    ref.read(lockedCellsProvider.notifier).setLockedCells(newLocked);
    _schedulePersist();
    // Flash the revealed entry cells using shared helper
      try {
        triggerFlashAndClear(
          cells,
          (v) => ref.read(flashingCellsProvider.notifier).setFlashingCells(v),
          () => ref.read(flashClearDelayProvider),
        );
    } on Object {
      // ignore
    }
    try {
      _triggerEndGameIfSolved();
    } on Object {
      // ignore
    }
  }

  /// Reveal the entire puzzle (fill all non-black cells from the solution grid).
  void revealAll() {
    final sol = state.solutionGrid;
    if (sol == null) {
      return;
    }
    // Capture the board before applying the reveal to detect which entries
    // become completed by this action (so we can flash only those).
    final beforeBoard = state;
    final newGrid = sol.map(List<String?>.from).toList();
    state = state.copyWith(grid: newGrid);

    // Mark all entries as found (if entries exist) and lock all non-black cells
    // Only flash the cells that belong to entries that were *not* already
    // marked as found so the revealAll animation highlights newly revealed
    // words instead of flashing the entire board.
    if (state.entries != null) {
      final wordCheck = ref.read(wordCheckServiceProvider);
      final allKeys = <String>{};
      final newlyFound = <String>{};
      try {
        for (final e in state.entries!) {
          final key = wordCheck.getWordKey(e);
          allKeys.add(key);
          // If this entry was incomplete before but is complete after reveal,
          // treat it as newly found and include its cells for flashing.
          final wasComplete = wordCheck.isWordComplete(beforeBoard, e);
          final isCompleteNow = wordCheck.isWordComplete(state, e);
          if (!wasComplete && isCompleteNow) {
            newlyFound.add(key);
          }
        }
        // Update authoritative found words to include all entries.
        ref.read(foundWordsProvider.notifier).setFoundWords(allKeys);

        if (newlyFound.isNotEmpty) {
          final newCells = <CellKey>{};
          for (final e in state.entries!) {
            final key = wordCheck.getWordKey(e);
            if (newlyFound.contains(key)) {
              newCells.addAll(wordCheck.getCellKeys(e));
            }
          }
             triggerFlashAndClear(
               newCells,
               (v) => ref.read(flashingCellsProvider.notifier).setFlashingCells(v),
               () => ref.read(flashClearDelayProvider),
             );
        }
      } on Object {
        // ignore
      }
    }
    final locked = <CellKey>{};
    for (var r = 0; r < state.grid.length; r++) {
      for (var c = 0; c < state.grid[r].length; c++) {
        if (!state.blackCells.isDisabled(r, c)) {
          locked.add(CellKey(r, c));
        }
      }
    }
    ref.read(lockedCellsProvider.notifier).setLockedCells(locked);
    _schedulePersist();

    // After revealAll, check end-game once.
    try {
      _triggerEndGameIfSolved();
    } on Object {
      // ignore
    }
    // If there were no entries metadata, fall back to flashing all
    // non-black cells so the reveal is still visible.
    if (state.entries == null || state.entries!.isEmpty) {
      try {
        final all = <CellKey>{};
        for (var r = 0; r < state.grid.length; r++) {
          for (var c = 0; c < state.grid[r].length; c++) {
            if (!state.blackCells.isDisabled(r, c)) {
              all.add(CellKey(r, c));
            }
          }
        }
           triggerFlashAndClear(
             all,
             (v) => ref.read(flashingCellsProvider.notifier).setFlashingCells(v),
             () => ref.read(flashClearDelayProvider),
           );
      } on Object {
        // ignore
      }
    }
  }

  void _schedulePersist() {
    try {
      _persistTimer?.cancel();
      _persistTimer = Timer(_persistDebounce, () async {
        await _persistProgress();
      });
    } on Object catch (e, st) {
      if (kDebugMode) {
        developer.log('Failed scheduling persist: $e', stackTrace: st);
      }
    }
  }

  Future<void> _persistProgress() async {
    try {
      final payload = {
        'schemaVersion': 1,
        'grid': state.grid,
        'savedAt': DateTime.now().toIso8601String(),
        // extended state
        'foundWords': ref.read(foundWordsProvider).toList(),
        'lockedCells': ref
            .read(lockedCellsProvider)
            .map((c) => '${c.row},${c.col}')
            .toList(),
        'elapsedSeconds': ref.read(gameTimerProvider(state.id)).elapsedSeconds,
      };
      await HivePuzzleStorage.save(state.id, jsonDecode(jsonEncode(payload)));
    } on Object catch (e, st) {
      if (kDebugMode) {
        developer.log('Failed to persist puzzle progress: $e', stackTrace: st);
      }
    }
  }

  /// Reset the puzzle to its initial state (clear all user progress).
  void resetPuzzle() {
    // Clear the grid
    final newGrid = List<List<String?>>.generate(
      state.grid.length,
      (r) => List<String?>.generate(
        state.grid[r].length,
        (c) => state.blackCells.isDisabled(r, c) ? null : null,
      ),
    );
    state = state.copyWith(grid: newGrid);

    // Clear all game state
    ref.read(foundWordsProvider.notifier).setFoundWords(<String>{});
    ref.read(lockedCellsProvider.notifier).setLockedCells(<CellKey>{});
    ref.read(selectedCellProvider.notifier).select(null);
    ref.read(flashingCellsProvider.notifier).setFlashingCells(<CellKey>{});
    ref.read(flashingClearedCellsProvider.notifier).setFlashingClearedCells(<CellKey>{});

    // Reset timer
    try {
      ref.read(gameTimerProvider(state.id)).clear();
    } on Object {
      // ignore
    }

    // Clear persistence
    _schedulePersist();
  }

  /// Centralized end-game check: finalize timer and play victory when all
  /// entries are found. Call this from any code path that may complete the
  /// puzzle (typing, reveal actions, etc.). This uses `foundWordsProvider`
  /// which is the authoritative source of found entries.
  ///
  /// [playVictorySound]: If true, plays the victory sound. Set to false when
  /// loading an already-completed puzzle to avoid playing the sound.
  void _triggerEndGameIfSolved({bool playVictorySound = true}) {
    try {
      final entriesNow = state.entries;
      if (entriesNow == null || entriesNow.isEmpty) {
        return;
      }
      final foundCount = ref.read(foundWordsProvider).length;
      if (foundCount == entriesNow.length) {
        try {
          ref.read(gameTimerProvider(state.id)).finalizeSync();
        } on Object {
          // ignore
        }
        if (playVictorySound) {
          try {
            // Only attempt to play audio if Flutter bindings are initialized.
            // Some unit tests run without WidgetsFlutterBinding and calling
            // into audioplayers' global scope will throw. Guard to avoid
            // creating the audio service in pure unit tests.
            try {
              WidgetsBinding.instance;
            } on Object {
              // Binding not initialized (unit test) — skip audio.
              return;
            }

            ref.read(gameAudioServiceProvider).playVictory();
          } on Object catch (e, st) {
            if (kDebugMode) {
              debugPrint('playVictory from GameBoardNotifier failed: $e\n$st');
            }
          }
        }
      }
    } on Object {
      // ignore
    }
  }
}

/// Main game board provider.
final gameBoardProvider = NotifierProvider<GameBoardNotifier, GameBoard>(
  GameBoardNotifier.new,
);
