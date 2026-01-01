import 'dart:developer' as developer;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/helpers/board_helpers.dart';
import 'package:croiz/features/game/services/incorrect_letter_cleaner.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/services/game_persistence_service.dart';
import 'package:croiz/features/game/services/game_progress_service.dart';
import 'package:croiz/features/game/services/game_reveal_service.dart';
import 'package:croiz/features/game/services/game_endgame_service.dart';

import 'puzzle_loader_provider.dart';
import 'game_state_providers.dart';
import 'game_timer_provider.dart';

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
  // Track the last loaded puzzle ID to detect changes
  String? _lastLoadedPuzzleId;
  // Track the previous board's grid for persistence on puzzle switch
  List<List<String?>>? _previousGrid;

  // Use the service via provider if available, otherwise fallback to local instance
  late final GamePersistenceService _persistenceService = ref.read(
    gamePersistenceServiceProvider,
  );
  late final GameProgressService _progressService = ref.read(
    gameProgressServiceProvider,
  );
  late final GameRevealService _revealService = ref.read(
    gameRevealServiceProvider,
  );
  late final GameEndgameService _endgameService = ref.read(
    gameEndgameServiceProvider,
  );

  // Compatibility helper used by tests and legacy call sites.
  void setBoard(GameBoard board) => state = board;

  @override
  GameBoard build() {
    // Listen for changes to puzzleLoaderProvider to restore progress.
    // Note: Riverpod manages the subscription lifecycle - we don't need
    // to track _listenerAttached because ref.listen is designed to be
    // called in build() and is automatically cleaned up on rebuild.
    ref
      ..listen<AsyncValue<GameBoard>>(
        puzzleLoaderProvider,
        _onPuzzleLoaderChanged,
        fireImmediately: true, // Fire immediately to handle initial load
      )
      // Cancel any pending timers when the notifier is disposed by Riverpod.
      ..onDispose(_persistenceService.dispose);

    final puzzleAsync = ref.watch(puzzleLoaderProvider);

    return puzzleAsync.when(
      data: (board) {
        // Detect puzzle change: if we had a previous puzzle and the ID changed,
        // clear all game state (selection, foundWords, lockedCells, etc.)
        final prevId = _lastLoadedPuzzleId;
        final newId = board.id;
        if (prevId != null && prevId != newId) {
          // IMPORTANT: Capture current state BEFORE clearing, so we can persist
          // the previous puzzle's progress (foundWords, lockedCells) correctly.
          final prevFoundWords = ref.read(foundWordsProvider).toList();
          final prevLockedCells =
              ref
                  .read(lockedCellsProvider)
                  .map((c) => '${c.row},${c.col}')
                  .toList();
          // Read the current grid from _previousGrid which we update on each
          // state change (see _schedulePersist)
          final prevGrid = _previousGrid;

          // Now clear all game state for the new puzzle
          _clearGameStateOnPuzzleChange(board);

          // Persist the previous puzzle's state asynchronously
          if (prevGrid != null) {
            _persistPreviousPuzzle(
              prevId,
              prevGrid,
              prevFoundWords,
              prevLockedCells,
            );
          }
        }
        _lastLoadedPuzzleId = newId;
        // Initialize _previousGrid when loading a new board
        _previousGrid = board.grid.map(List<String?>.from).toList();
        return board;
      },
      loading: _handleLoading,
      error: _handleError,
    );
  }

  /// Handle loading state - throws appropriate error.
  Never _handleLoading() {
    final selected = ref.read(selectedPuzzleIdProvider);
    if (selected == null) {
      throw StateError('No puzzle selected');
    }
    throw StateError('Puzzle is loading: $selected');
  }

  /// Handle error state - throws with details.
  Never _handleError(Object e, StackTrace st) {
    final selected = ref.read(selectedPuzzleIdProvider) ?? '<null>';
    throw StateError('Failed to load puzzle id="$selected": $e');
  }

  /// Called when puzzle changes - clears selection, foundWords, lockedCells, etc.
  void _clearGameStateOnPuzzleChange(GameBoard newBoard) {
    // Clear selection from previous puzzle
    try {
      ref.read(selectedCellProvider.notifier).select(null);
    } on Object {
      // ignore
    }
    // Clear foundWords from previous puzzle
    try {
      ref.read(foundWordsProvider.notifier).setFoundWords(<String>{});
    } on Object {
      // ignore
    }
    // Clear lockedCells from previous puzzle
    try {
      ref.read(lockedCellsProvider.notifier).setLockedCells(<CellKey>{});
    } on Object {
      // ignore
    }
    // Clear flashing cells
    try {
      ref.read(flashingCellsProvider.notifier).setFlashingCells(<CellKey>{});
    } on Object {
      // ignore
    }
    try {
      ref
          .read(flashingClearedCellsProvider.notifier)
          .setFlashingClearedCells(<CellKey>{});
    } on Object {
      // ignore
    }
  }

  /// Persist the previous puzzle's state asynchronously.
  /// This is called from build() BEFORE clearing state, so the values
  /// are captured correctly.
  void _persistPreviousPuzzle(
    String puzzleId,
    List<List<String?>> grid,
    List<String> foundWords,
    List<String> lockedCells,
  ) {
    _persistenceService.persistPreviousPuzzle(
      puzzleId: puzzleId,
      grid: grid,
      foundWords: foundWords,
      lockedCells: lockedCells,
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

    final puzzleId = next.value.id;
    _restoreProgress(puzzleId, next.value);
  }

  Future<void> _restoreProgress(String puzzleId, GameBoard board) async {
    try {
      final result = await _progressService.loadProgress(
        puzzleId,
        expectedRows: board.grid.length,
        expectedCols: board.grid.isNotEmpty ? board.grid[0].length : 0,
      );

      if (!ref.mounted) {
        return;
      }

      if (result.hasData) {
        if (result.grid != null) {
          state = state.copyWith(grid: result.grid);
        }
        if (result.foundWords != null) {
          ref
              .read(foundWordsProvider.notifier)
              .setFoundWords(result.foundWords!);
          _triggerEndGameIfSolved(playVictorySound: false);
        }
        if (result.lockedCells != null) {
          ref
              .read(lockedCellsProvider.notifier)
              .setLockedCells(result.lockedCells!);
        }
        if (result.elapsedSeconds != null) {
          unawaited(
            ref
                .read(gameTimerProvider(board.id))
                .setElapsed(result.elapsedSeconds!),
          );
        }
      } else {
        _populateInitialFoundLockedFromGrid(board);
      }
    } on Object catch (e, st) {
      if (kDebugMode) {
        developer.log('Failed to restore puzzle progress: $e', stackTrace: st);
      }
      if (ref.mounted) {
        _populateInitialFoundLockedFromGrid(board);
      }
    }
  }

  /// Populate initial found/locked sets based on current grid state.
  /// Called only when there's no stored progress to restore.
  void _populateInitialFoundLockedFromGrid(GameBoard board) {
    if (!ref.mounted) {
      return;
    }
    final entries = board.entries;
    if (entries != null && entries.isNotEmpty) {
      try {
        final wordCheck = ref.read(wordCheckServiceProvider);
        final result = _progressService.computeInitialState(
          board: board,
          isWordComplete: wordCheck.isWordComplete,
          getWordKey: wordCheck.getWordKey,
          getCellKeys: wordCheck.getCellKeys,
        );
        if (!result.isEmpty) {
          ref
              .read(foundWordsProvider.notifier)
              .setFoundWords(result.foundWords);
          ref
              .read(lockedCellsProvider.notifier)
              .setLockedCells(result.lockedCells);
          _triggerEndGameIfSolved(playVictorySound: false);
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
    final normalizedLetter =
        letter == null || letter.isEmpty
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
      ref
          .read(flashingClearedCellsProvider.notifier)
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
    if (state.grid[row][col] != null) {
      return;
    }

    final letter = _revealService.revealLetterAt(
      board: state,
      row: row,
      col: col,
    );

    if (letter == null) {
      return;
    }

    state = state.updateCell(row, col, letter);
    _checkWordCompletionAfterReveal(CellKey(row, col));
    _schedulePersist();
  }

  /// Helper to check for word completion after a single cell reveal.
  void _checkWordCompletionAfterReveal(CellKey pos) {
    try {
      final wordCheck = ref.read(wordCheckServiceProvider);
      final result = _progressService.checkCompletionAtPos(
        board: state,
        pos: pos,
        currentFoundWords: ref.read(foundWordsProvider),
        isWordComplete: wordCheck.isWordComplete,
        getWordKey: wordCheck.getWordKey,
        getCellKeys: wordCheck.getCellKeys,
      );

      if (result.hasChanges) {
        final newFound = Set<String>.from(ref.read(foundWordsProvider))
          ..addAll(result.newlyFoundWords);
        final newLocked = Set<CellKey>.from(ref.read(lockedCellsProvider))
          ..addAll(result.cellsToFlash);

        ref.read(foundWordsProvider.notifier).setFoundWords(newFound);
        ref.read(lockedCellsProvider.notifier).setLockedCells(newLocked);

        _revealService.triggerFlash(
          cells: result.cellsToFlash,
          setFlashingCells:
              (v) =>
                  ref.read(flashingCellsProvider.notifier).setFlashingCells(v),
          getFlashDelay: () => ref.read(flashClearDelayProvider),
          playSuccess: () => ref.read(gameAudioServiceProvider).playSuccess(),
          shouldPlaySound: () => !ref.read(gameAudioMutedProvider),
        );
        _triggerEndGameIfSolved();
      }
    } on Object {
      // ignore
    }
  }

  /// Reveal the full entry (word) for the given PuzzleEntryData.
  void revealEntry(PuzzleEntryData entry) {
    final wordCheck = ref.read(wordCheckServiceProvider);
    final result = _revealService.revealEntry(
      board: state,
      entry: entry,
      currentFoundWords: ref.read(foundWordsProvider),
      currentLockedCells: ref.read(lockedCellsProvider),
      getWordKey: wordCheck.getWordKey,
      getCellKeys: wordCheck.getCellKeys,
    );

    if (!result.hasChanges) {
      return;
    }

    state = state.copyWith(grid: result.newGrid);
    ref.read(foundWordsProvider.notifier).setFoundWords(result.newFoundWords);
    ref
        .read(lockedCellsProvider.notifier)
        .setLockedCells(result.newLockedCells);
    _schedulePersist();

    _revealService.triggerFlash(
      cells: result.cellsToFlash,
      setFlashingCells:
          (v) => ref.read(flashingCellsProvider.notifier).setFlashingCells(v),
      getFlashDelay: () => ref.read(flashClearDelayProvider),
      playSuccess: () => ref.read(gameAudioServiceProvider).playSuccess(),
      shouldPlaySound: () => !ref.read(gameAudioMutedProvider),
    );

    _triggerEndGameIfSolved();
  }

  /// Reveal the entire puzzle (fill all non-black cells from the solution grid).
  void revealAll() {
    final sol = state.solutionGrid;
    if (sol == null) {
      return;
    }

    // Early return if puzzle is already fully revealed
    // Check if all entries are already marked as found
    final entries = state.entries;
    if (entries != null && entries.isNotEmpty) {
      final foundCount = ref.read(foundWordsProvider).length;
      if (foundCount == entries.length) {
        // Puzzle is already complete, nothing to reveal
        return;
      }
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
      // Capture previously found words and locked cells so we don't flash
      // words that were already marked as found or whose cells were already
      // locked (previously flashed) before revealAll was invoked.
      final priorLocked = Set<CellKey>.from(ref.read(lockedCellsProvider));
      final priorFound = Set<String>.from(ref.read(foundWordsProvider));
      try {
        for (final e in state.entries!) {
          final key = wordCheck.getWordKey(e);
          allKeys.add(key);
          // If this entry was incomplete before but is complete after reveal,
          // treat it as newly found and include its cells for flashing.
          // Determine newly found solely from the board before/after state
          // and whether its cells were previously locked. This avoids
          // relying on `foundWordsProvider` which may be momentarily out of
          // sync and could cause already-completed words to be flashed.
          final wasComplete = wordCheck.isWordComplete(beforeBoard, e);
          final isCompleteNow = wordCheck.isWordComplete(state, e);
          final cellKeys = wordCheck.getCellKeys(e);
          final wasLocked = priorLocked.containsAll(cellKeys);
          // Only consider this entry newly found if it was incomplete before,
          // is complete now, and its cells were not already locked (previous flash).
          if (!wasComplete &&
              isCompleteNow &&
              !priorFound.contains(key) &&
              !wasLocked) {
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
          // Filter out any cells that are already flashing to avoid
          // re-flashing the same visual elements (helps when revealAll is
          // invoked while a previous reveal's flash is active). Do NOT
          // filter locked cells here — entries that are partially locked
          // but newly completed should still flash their cells.
          final currentlyFlashing = Set<CellKey>.from(
            ref.read(flashingCellsProvider),
          );
          final toFlash =
              newCells.where((c) => !currentlyFlashing.contains(c)).toSet();
          if (toFlash.isNotEmpty) {
            _revealService.triggerFlash(
              cells: toFlash,
              setFlashingCells:
                  (v) => ref
                      .read(flashingCellsProvider.notifier)
                      .setFlashingCells(v),
              getFlashDelay: () => ref.read(flashClearDelayProvider),
              playSuccess:
                  () => ref.read(gameAudioServiceProvider).playSuccess(),
              shouldPlaySound: () => !ref.read(gameAudioMutedProvider),
            );
          }
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
        _revealService.triggerFlash(
          cells: all,
          setFlashingCells:
              (v) =>
                  ref.read(flashingCellsProvider.notifier).setFlashingCells(v),
          getFlashDelay: () => ref.read(flashClearDelayProvider),
          playSuccess: () => ref.read(gameAudioServiceProvider).playSuccess(),
          shouldPlaySound: () => !ref.read(gameAudioMutedProvider),
        );
      } on Object {
        // ignore
      }
    }
  }

  void _schedulePersist() {
    try {
      _previousGrid = state.grid.map(List<String?>.from).toList();
    } on Object {
      // ignore if state not ready
    }
    _persistenceService.schedulePersist(
      puzzleId: state.id,
      grid: state.grid,
      foundWords: ref.read(foundWordsProvider),
      lockedCells: ref.read(lockedCellsProvider),
      elapsedSeconds: ref.read(gameTimerProvider(state.id)).elapsedSeconds,
    );
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
    // After a reset we deliberately clear selection so UI doesn't retain
    // focus on previously-selected cells from the prior game state.
    try {
      ref.read(selectedCellProvider.notifier).select(null);
    } on Object {
      // ignore
    }
    ref.read(flashingCellsProvider.notifier).setFlashingCells(<CellKey>{});
    ref
        .read(flashingClearedCellsProvider.notifier)
        .setFlashingClearedCells(<CellKey>{});

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
    final solved = _endgameService.checkAndTriggerEndGame(
      board: state,
      foundWords: ref.read(foundWordsProvider),
      lastLoadedPuzzleId: _lastLoadedPuzzleId,
      timer: ref.read(gameTimerProvider(state.id)),
      persistenceService: _persistenceService,
      lockedCells: ref.read(lockedCellsProvider),
      isMuted: ref.read(gameAudioMutedProvider),
      audioService: ref.read(gameAudioServiceProvider),
      playVictorySound: playVictorySound,
    );

    if (solved) {
      // Any additional local cleanup if needed
    }
  }
}

/// Main game board provider.
final gameBoardProvider = NotifierProvider<GameBoardNotifier, GameBoard>(
  GameBoardNotifier.new,
);
