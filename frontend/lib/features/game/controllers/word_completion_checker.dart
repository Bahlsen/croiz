// ignore_for_file: provider_dependencies
import 'dart:async';
import 'dart:developer' as developer;

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/audio_service.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/features/game/providers/game_timer_provider.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/utils/flash_utils.dart';
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
    required this.readAudioMuted,
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
    required bool Function() readAudioMuted,
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
    readAudioMuted: readAudioMuted,
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
  final bool Function() readAudioMuted;
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
    } on Object catch (e) {
      if (e is StateError) {
        // Board no longer available (disposed or reset) — skip check.
        return;
      }
      rethrow;
    }
    final entries = board.entries;

    if (entries == null || entries.isEmpty) {
      return;
    }

    final wordCheckService = readWordCheckService();
    final foundWords = readFoundWords();
    final lockedCells = readLockedCells();

    // Lazy copy: only create mutable sets if we actually find a completed word
    Set<String>? newFoundWords;
    Set<CellKey>? newLockedCells;

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
      final complete = wordCheckService.isWordComplete(board, entry);

      // Skip if already found
      if (foundWords.contains(wordKey)) {
        continue;
      }

      // Check if word is complete
      if (complete) {
        // Initialize mutable sets on first write
        newFoundWords ??= Set<String>.from(foundWords);
        newLockedCells ??= Set<CellKey>.from(lockedCells);

        newFoundWords.add(wordKey);
        wordsCompletedThisCheck++;

        // Collect cells for flash animation
        final cellKeys = wordCheckService.getCellKeys(entry);
        allFlashingCells.addAll(cellKeys);

        // Lock cells of the found word
        newLockedCells.addAll(cellKeys);
      }
    }

    // Trigger flash animation and play success once via the helper when any
    // words completed in this batch.
    if (wordsCompletedThisCheck > 0) {
      triggerFlashAndPlaySuccess(
        allFlashingCells,
        writeFlashingCells,
        readFlashClearDelay,
        playSuccess: () => readGameAudioService().playSuccess(),
        shouldPlaySound: () => !readAudioMuted(),
      );
    }

    if (newFoundWords != null) {
      writeFoundWords(newFoundWords);
    }

    if (newLockedCells != null) {
      writeLockedCells(newLockedCells);
    }

    // If all words found -> finalize timer and play victory sound
    try {
      final totalEntries = entries.length;
      final currentFoundCount =
          newFoundWords != null ? newFoundWords.length : foundWords.length;

      if (totalEntries > 0 && currentFoundCount == totalEntries) {
        try {
          developer.log('All words completed: triggering finalize and victory');
        } on Object catch (_) {}
        try {
          finalizeTimer(board.id);
        } on Object catch (e, st) {
          developer.log('finalizeSync failed', error: e, stackTrace: st);
        }
        try {
          if (!readAudioMuted()) {
            readGameAudioService().playVictory();
          }
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
  writeFlashingCells:
      (v) => read(flashingCellsProvider.notifier).setFlashingCells(v),
  readCellEntriesIndex:
      () => read<Map<CellKey, List<PuzzleEntryData>>>(cellEntriesIndexProvider),
  readWordCheckService: () => read<WordCheckService>(wordCheckServiceProvider),
  readGameAudioService: () => read<AudioService>(gameAudioServiceProvider),
  readAudioMuted: () => read<bool>(gameAudioMutedProvider),
  readFlashClearDelay: () => read<Duration>(flashClearDelayProvider),
  readCheckDebounceDelay: () => read<Duration>(wordCheckDebounceDelayProvider),
  finalizeTimer: (boardId) => read(gameTimerProvider(boardId)).finalizeSync(),
);

// Uses `triggerFlashAndClear` from utils/flash_utils.dart.
