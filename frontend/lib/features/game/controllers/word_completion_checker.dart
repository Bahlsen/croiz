import 'dart:async';
import 'dart:developer' as developer;

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/audio_service.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/features/game/providers/game_timer_provider.dart';
import 'package:croiz/features/game/services/endgame_service.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Handles word completion checking and related side effects.
///
/// This class is responsible for:
/// - Batching cell changes for debounced word checks
/// - Checking if entries are complete
/// - Triggering flash animations for completed words
/// - Playing success and victory sounds
/// - Locking completed word cells
class WordCompletionChecker {
  WordCompletionChecker({
    required this.readBoard,
    required this.readFoundWords,
    required this.writeFoundWords,
    required this.readLockedCells,
    required this.writeLockedCells,
    required this.readFlashingCells,
    required this.writeFlashingCells,
    required this.readCellEntriesIndex,
    required this.readWordCheckService,
    required this.readGameAudioService,
    required this.readEndGameService,
    required this.readFlashClearDelay,
    required this.readCheckDebounceDelay,
    required this.finalizeTimer,
  });

  /// Creates a WordCompletionChecker from provider reads.
  factory WordCompletionChecker.fromReaders({
    required GameBoard Function() readBoard,
    required Set<String> Function() readFoundWords,
    required void Function(Set<String>) writeFoundWords,
    required Set<CellKey> Function() readLockedCells,
    required void Function(Set<CellKey>) writeLockedCells,
    required Set<CellKey> Function() readFlashingCells,
    required void Function(Set<CellKey>) writeFlashingCells,
    required Map<CellKey, List<PuzzleEntryData>> Function()
    readCellEntriesIndex,
    required WordCheckService Function() readWordCheckService,
    required AudioService Function() readGameAudioService,
    required EndGameService Function() readEndGameService,
    required Duration Function() readFlashClearDelay,
    required Duration Function() readCheckDebounceDelay,
    required void Function(String boardId) finalizeTimer,
  }) => WordCompletionChecker(
    readBoard: readBoard,
    readFoundWords: readFoundWords,
    writeFoundWords: writeFoundWords,
    readLockedCells: readLockedCells,
    writeLockedCells: writeLockedCells,
    readFlashingCells: readFlashingCells,
    writeFlashingCells: writeFlashingCells,
    readCellEntriesIndex: readCellEntriesIndex,
    readWordCheckService: readWordCheckService,
    readGameAudioService: readGameAudioService,
    readEndGameService: readEndGameService,
    readFlashClearDelay: readFlashClearDelay,
    readCheckDebounceDelay: readCheckDebounceDelay,
    finalizeTimer: finalizeTimer,
  );

  final GameBoard Function() readBoard;
  final Set<String> Function() readFoundWords;
  final void Function(Set<String>) writeFoundWords;
  final Set<CellKey> Function() readLockedCells;
  final void Function(Set<CellKey>) writeLockedCells;
  final Set<CellKey> Function() readFlashingCells;
  final void Function(Set<CellKey>) writeFlashingCells;
  final Map<CellKey, List<PuzzleEntryData>> Function() readCellEntriesIndex;
  final WordCheckService Function() readWordCheckService;
  final AudioService Function() readGameAudioService;
  final EndGameService Function() readEndGameService;
  final Duration Function() readFlashClearDelay;
  final Duration Function() readCheckDebounceDelay;
  final void Function(String boardId) finalizeTimer;

  Timer? _flashClearTimer;
  Timer? _checkDebounceTimer;
  final Set<CellKey> _pendingChecks = {};
  bool _disposed = false;

  /// Schedule a debounced check for completed words.
  /// Accumulates changed cells and runs a single batch check after delay.
  /// If debounce delay is zero (tests), runs synchronously.
  void scheduleCheck(CellKey changedCell) {
    _pendingChecks.add(changedCell);
    final delay = readCheckDebounceDelay();
    if (delay == Duration.zero) {
      // Synchronous mode for tests: run immediately
      _runBatchCheck();
      return;
    }
    _checkDebounceTimer?.cancel();
    _checkDebounceTimer = Timer(delay, () {
      if (_disposed) {
        return;
      }
      _runBatchCheck();
    });
  }

  /// Run the actual word check for all pending cells.
  void _runBatchCheck() {
    if (_pendingChecks.isEmpty) {
      return;
    }
    final cellsToCheck = Set<CellKey>.from(_pendingChecks);
    _pendingChecks.clear();
    _checkForCompletedWordsBatch(cellsToCheck);
  }

  /// Check words for multiple cells at once (batch mode).
  void _checkForCompletedWordsBatch(Set<CellKey> changedCells) {
    GameBoard board;
    try {
      board = readBoard();
      // ignore: avoid_catching_errors
    } on StateError {
      // Board no longer available (disposed or reset) — skip check.
      return;
    }
    final entries = board.entries;

    if (entries == null || entries.isEmpty) {
      return;
    }

    final wordCheckService = readWordCheckService();
    final foundWords = readFoundWords();
    final newFoundWords = Set<String>.from(foundWords);
    final lockedCells = readLockedCells();
    final newLockedCells = Set<CellKey>.from(lockedCells);

    // Collect all entries that contain any of the changed cells
    final entriesToCheck = <PuzzleEntryData>{};
    try {
      final index = readCellEntriesIndex();
      for (final cell in changedCells) {
        final list = index[cell];
        if (list != null) {
          entriesToCheck.addAll(list);
        }
      }
    } on Object {
      // Fallback to checking all entries if index lookup fails.
      entriesToCheck.addAll(entries);
    }

    // Collect all cells that need to flash for all completed words
    final allFlashingCells = <CellKey>{};
    var wordsCompletedThisCheck = 0;

    for (final entry in entriesToCheck) {
      final wordKey = wordCheckService.getWordKey(entry);

      // Skip if already found
      if (foundWords.contains(wordKey)) {
        continue;
      }

      // Check if word is complete
      if (wordCheckService.isWordComplete(board, entry)) {
        newFoundWords.add(wordKey);
        wordsCompletedThisCheck++;

        // Collect cells for flash animation
        final cellKeys = wordCheckService.getCellKeys(entry);
        allFlashingCells.addAll(cellKeys);

        // Lock cells of the found word
        newLockedCells.addAll(cellKeys);
      }
    }

    // Play success sound once if any words were completed
    if (wordsCompletedThisCheck > 0) {
      try {
        readGameAudioService().playSuccess();
      } on Object catch (e, st) {
        developer.log('playSuccess failed', error: e, stackTrace: st);
      }

      // Trigger flash animation on ALL completed words' cells at once using
      // the shared helper so the reveal-path can reuse the same behavior.
      triggerFlashAndClear(
        allFlashingCells,
        writeFlashingCells,
        readFlashClearDelay,
      );
    }

    if (newFoundWords.length > foundWords.length) {
      writeFoundWords(newFoundWords);
    }

    if (newLockedCells.length > lockedCells.length) {
      writeLockedCells(newLockedCells);
    }

    // If all words found -> finalize timer and play victory sound
    try {
      final totalEntries = entries.length;
      if (totalEntries > 0 && newFoundWords.length == totalEntries) {
        try {
          developer.log('All words completed: triggering finalize and victory');
        } on Object catch (_) {}
        try {
          finalizeTimer(board.id);
        } on Object catch (e, st) {
          developer.log('finalizeSync failed', error: e, stackTrace: st);
        }
        try {
          readGameAudioService().playVictory();
        } on Object catch (e, st) {
          developer.log('playVictory failed', error: e, stackTrace: st);
        }
      }
    } on Object catch (e, st) {
      developer.log(
        'Error checking for completed words',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Cancel any scheduled timers and mark disposed.
  void dispose() {
    _disposed = true;
    try {
      _flashClearTimer?.cancel();
      _checkDebounceTimer?.cancel();
    } on Object {
      // ignore
    }
  }
}

/// Provider factory helper for creating WordCompletionChecker from WidgetRef.
WordCompletionChecker createWordCompletionCheckerFromRef(
  WidgetRef ref,
  T Function<T>(Object provider) read,
) => WordCompletionChecker.fromReaders(
  readBoard: () {
    try {
      return read<GameBoard>(gameBoardProvider);
    } on Object catch (e, st) {
      developer.log('gameBoardProvider read failed', error: e, stackTrace: st);
      // Try to obtain the loaded puzzle synchronously from the loader.
      try {
        final pa = read<AsyncValue<GameBoard>>(puzzleLoaderProvider);
        return pa.when(
          data: (d) => d,
          loading: () => throw StateError('No board available'),
          error: (e2, st2) => throw StateError('No board available'),
        );
      } on Object catch (e2, st2) {
        developer.log(
          'puzzleLoaderProvider read failed',
          error: e2,
          stackTrace: st2,
        );
        throw StateError('No board available');
      }
    }
  },
  readFoundWords: () => read<Set<String>>(foundWordsProvider),
  writeFoundWords: (v) => read(foundWordsProvider.notifier).setFoundWords(v),
  readLockedCells: () => read<Set<CellKey>>(lockedCellsProvider),
  writeLockedCells: (v) => read(lockedCellsProvider.notifier).setLockedCells(v),
  readFlashingCells: () => read<Set<CellKey>>(flashingCellsProvider),
  writeFlashingCells: (v) => read(flashingCellsProvider.notifier).setFlashingCells(v),
  readCellEntriesIndex: () =>
      read<Map<CellKey, List<PuzzleEntryData>>>(cellEntriesIndexProvider),
  readWordCheckService: () => read<WordCheckService>(wordCheckServiceProvider),
  readGameAudioService: () => read<AudioService>(gameAudioServiceProvider),
  readEndGameService: () => read(endGameServiceProvider),
  readFlashClearDelay: () => read<Duration>(flashClearDelayProvider),
  readCheckDebounceDelay: () => read<Duration>(wordCheckDebounceDelayProvider),
  finalizeTimer: (boardId) => read(gameTimerProvider(boardId)).finalizeSync(),
);

/// Helper to set flashing cells and clear them after the configured delay.
///
/// This centralizes the common pattern used both when the user completes a
/// word via typing and when a word is revealed via the menu.
void triggerFlashAndClear(
  Set<CellKey> cells,
  void Function(Set<CellKey>) writeFlashingCells,
  Duration Function() readFlashClearDelay,
) {
  try {
    writeFlashingCells(cells);
    final delay = readFlashClearDelay();
    if (delay == Duration.zero) {
      // Synchronous test mode: clear on next microtask
      unawaited(
        Future.microtask(() {
          try {
            writeFlashingCells(<CellKey>{});
          } on Object catch (_) {
            // ignore
          }
        }),
      );
    } else {
      Future.delayed(delay, () {
        try {
          writeFlashingCells(<CellKey>{});
        } on Object catch (_) {
          // ignore
        }
      });
    }
  } on Object catch (_) {
    // ignore errors from callers
  }
}
