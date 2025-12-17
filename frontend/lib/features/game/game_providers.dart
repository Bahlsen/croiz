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
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/game/utils/clue_numbering.dart';

/// Duration used to schedule clearing of flashed cells after animations.
/// Tests can override this provider to `Duration.zero` to avoid scheduling
/// real timers (FakeAsync-friendly).
/// Default flash clear delay used after animations. Matches UI animation
/// timing used by widget tests (700ms). Tests can override this provider
/// to `Duration.zero` to avoid scheduling real timers when desired.
final flashClearDelayProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 500),
);

class GameBoardNotifier extends Notifier<GameBoard> {
  // Notifier that mirrors `puzzleLoaderProvider`. Attaches a single listener
  // on first `build()` to react to puzzle load events and update dependent
  // providers (found/locked words, etc.).
  bool _listenerAttached = false;

  @override
  GameBoard build() {
    if (!_listenerAttached) {
      _listenerAttached = true;
      // Attach listener but do NOT fire immediately. Firing immediately
      // would call the listener while this notifier is still being
      // initialized which can mutate other providers during initialization
      // (Riverpod disallows that). Instead, attach the listener and then
      // schedule a microtask to process the current value so any
      // cross-provider modifications happen after initialization.
      ref.listen<AsyncValue<GameBoard>>(
        puzzleLoaderProvider,
        _onPuzzleLoaderChanged,
        fireImmediately: false,
      );

      // If the provider already has data, process it asynchronously so
      // modifications to other providers happen outside of build.
      final current = ref.read(puzzleLoaderProvider);
      if (current is AsyncData<GameBoard>) {
        // Ensure the notifier's synchronous state reflects the loaded
        // puzzle immediately so tests calling notifier methods right
        // after creation operate on the correct board. Defer the
        // cross-provider updates (found/locked words) to a microtask
        // so they happen after initialization.
        state = current.value;
        Future.microtask(() => _onPuzzleLoaderChanged(null, current));
      }
    }
    // Do not provide any default board while loading — surface loading
    // / error states as provider errors so callers can react explicitly.
    final puzzleAsync = ref.watch(puzzleLoaderProvider);

    return puzzleAsync.when(
      data: (d) => d,
      loading: () {
        final selected = ref.read(selectedPuzzleIdProvider);
        // If no puzzle is selected (common in unit tests and initial
        // app state), provide a minimal empty board so consumers can
        // operate without a selected puzzle. If a puzzle *is*
        // selected, surface a thrown StateError so UI can show a
        // spinner or navigation can handle loading explicitly.
        // Do not fabricate any board in production. If no puzzle is
        // selected we surface an explicit error so callers (UI/tests)
        // handle the absence of a selected puzzle deliberately.
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
    // If this notifier has been disposed since we scheduled an async
    // microtask to process the current loader value, bail out early to
    // avoid using a disposed `ref` (which throws).
    if (!ref.mounted) {
      return;
    }
    if (next is AsyncData<GameBoard>) {
      // Only replace notifier state if the loaded puzzle ID differs from
      // the current board. This avoids overwriting runtime modifications
      // (e.g. cleared letters) that tests or UI may apply after the
      // initial load but before a scheduled microtask fires.
      if (state.id != next.value.id) {
        state = next.value;
      }

      // Detect any words already complete in the loaded puzzle and update
      // `foundWordsProvider` / `lockedCellsProvider` so the UI reflects
      // the correct state immediately.
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
          // Log and continue on errors from detection.
          debugPrint('Error updating found/locked words: $e\n$stack');
        }
      }
    }
  }

  // (helper removed) _createEmptyBoard was inlined in `build()` above.

  void setLetter(int row, int col, String? letter) {
    // No-op when cell is black.
    if (state.blackCells.isDisabled(row, col)) {
      return;
    }
    // Optimize updates: copy only the changed row instead of cloning the
    // entire grid, and reuse blackCells since they are unchanged here.
    final newGrid = List<List<String?>>.of(state.grid);
    final rowCopy = List<String?>.of(newGrid[row]);
    rowCopy[col] = letter == null || letter.isEmpty
        ? null
        : letter.substring(0, 1).toUpperCase();
    newGrid[row] = rowCopy;
    state = GameBoard(
      id: state.id,
      title: state.title,
      gridSize: state.gridSize,
      createdAt: state.createdAt,
      grid: newGrid,
      clues: state.clues,
      blackCells: state.blackCells,
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

  /// Public helper to replace the entire board from outside the notifier.
  /// Use this instead of setting `state` directly to avoid using a
  /// protected member from outside the notifier class.
  set board(GameBoard board) {
    state = board;
  }

  // Expose current board as a read-only getter to complement the setter.
  GameBoard get board => state;

  /// Clear any letters that do not match puzzle answers.
  /// Uses `incorrectLetterCleaner` service and flashes cleared cells.
  void clearIncorrectLetters() {
    final cleaner = ref.read(incorrectLetterCleanerProvider);
    final result = cleaner.cleanWithResult(state);
    // Update board with cleaned result
    state = result.board;

    if (result.clearedCells.isNotEmpty) {
      // Flash cleared cells via provider then clear the flash.
      // Use microtask to avoid scheduling a Timer which can interfere
      // with FakeAsync-based tests.
      ref.read(flashingClearedCellsProvider.notifier).value = result
          .clearedCells
          .toSet();
      // flashingClearedCellsProvider set here; tests may override delay.
      final _delay = ref.read(flashClearDelayProvider);
      if (_delay == Duration.zero) {
        Future.microtask(() {
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
      } else {
        Future.delayed(_delay, () {
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
}

/// Holds the currently selected puzzle id.
///
/// IMPORTANT: null means "no puzzle selected" (there is no default puzzle).
class SelectedPuzzleIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  String? get value => state;
  set value(String? v) => state = v;
}

final selectedPuzzleIdProvider =
    NotifierProvider<SelectedPuzzleIdNotifier, String?>(
      SelectedPuzzleIdNotifier.new,
    );

/// Provider to load the puzzle asynchronously from JSON.
///
/// IMPORTANT: this does **not** load any default puzzle. A puzzle id must be
/// selected via `selectedPuzzleIdProvider` (or tests must override this
/// provider). This guarantees we never silently load the same puzzle.
final puzzleLoaderProvider = FutureProvider<GameBoard>((ref) async {
  final selected = ref.watch(selectedPuzzleIdProvider);
  if (selected == null || selected.isEmpty) {
    throw StateError('No puzzle selected');
  }

  // Strict behaviour: resolve the selected id by looking it up in the
  // precomputed index. If the id is not present in the index we fail
  // loudly instead of attempting heuristic fallbacks.
  final index = await ref.watch(puzzlesProvider.future);
  final match = index.firstWhere(
    (p) => p.id == selected,
    orElse: () =>
        throw StateError('Selected puzzle id not found in index: $selected'),
  );
  // Use the indexed path (normalized by providers) and build a proper
  // asset key for `rootBundle` by prefixing `data/`.
  final assetPath = 'assets/data/${match.path}';
  final loader = ref.read(puzzleAssetLoaderProvider);
  return loader(assetPath);
});

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

/// Resolve a puzzle id to a strict asset path under `assets/data/`.
String assetPathForPuzzleId(String id) => 'assets/data/$id.json';

/// Provider for the loader function so tests can override loading behavior.
final puzzleAssetLoaderProvider = Provider<Future<GameBoard> Function(String)>(
  (ref) => loadPuzzleFromAsset,
);

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

/// (removed) `createSampleBoard` and `createEmptyBoard` were removed
/// as the empty board creation is now inlined inside `GameBoardNotifier`.

// Note: `createEmptyBoard` and `createSampleBoard` intentionally removed.
// Production code must not fabricate a default board; callers should
// explicitly handle loading/error states from `puzzleLoaderProvider`.

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
class FlashingCellsNotifier extends Notifier<Set<CellKey>> {
  @override
  Set<CellKey> build() => _initialFlashingCells(ref);
  Set<CellKey> get value => state;
  set value(Set<CellKey> v) => state = v;
}

final flashingCellsProvider =
    NotifierProvider<FlashingCellsNotifier, Set<CellKey>>(
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
class LockedCellsNotifier extends Notifier<Set<CellKey>> {
  @override
  Set<CellKey> build() => _initialLockedCells(ref);
  Set<CellKey> get value => state;
  set value(Set<CellKey> v) => state = v;
}

final lockedCellsProvider = NotifierProvider<LockedCellsNotifier, Set<CellKey>>(
  LockedCellsNotifier.new,
);

/// Index of entries by cell for fast lookups.
/// Maps a CellKey to the list of entries (across/down) that include it.
final cellEntriesIndexProvider = Provider<Map<CellKey, List<PuzzleEntryData>>>((
  ref,
) {
  // Recompute index only when entries change (grid changes do not matter).
  final entries = ref.watch(gameBoardProvider.select((b) => b.entries));
  if (entries == null || entries.isEmpty) {
    return const {};
  }
  final map = <CellKey, List<PuzzleEntryData>>{};
  for (final e in entries) {
    final isAcross = e.directionEnum == EntryDirection.across;
    for (var i = 0; i < e.length; i++) {
      final r = isAcross ? e.y : e.y + i;
      final c = isAcross ? e.x + i : e.x;
      final key = CellKey(r, c);
      map.putIfAbsent(key, () => <PuzzleEntryData>[]).add(e);
    }
  }
  return map;
});

/// Precomputed clue numbers map for quick per-cell lookup.
final clueNumbersProvider = Provider<Map<String, int>>((ref) {
  // Only depend on gridSize and entries, which are sufficient for numbering.
  final size = ref.watch(gameBoardProvider.select((b) => b.gridSize));
  final entries = ref.watch(gameBoardProvider.select((b) => b.entries));
  return ClueNumbering.numbersFrom(size, entries);
});
// Provider tear-offs for initial values.
SelectedCell? _initialSelectedCell(ref) => null;
WordDirection _initialWordDirection(ref) => WordDirection.horizontal;
Set<String> _initialFoundWords(ref) => <String>{};
Set<CellKey> _initialFlashingCells(ref) => <CellKey>{};
Set<CellKey> _initialLockedCells(ref) => <CellKey>{};
Set<String> _initialFlashingClearedCells(ref) => <String>{};

/// Provider family exposing a single cell's value. Widgets should watch
/// `cellValueProvider([r, c])` to rebuild only when that cell's letter
/// changes, avoiding large grid rebuilds.
final cellValueProvider = Provider.family<String?, List<int>>((ref, coords) {
  final r = coords[0];
  final c = coords[1];
  // Only rebuild when this specific cell value changes.
  return ref.watch(gameBoardProvider.select((b) => b.grid[r][c]));
});

/// Provider family exposing whether a word (by wordKey) has been found.
/// Widgets showing entry-level UI should watch this to avoid listening to
/// the whole `foundWordsProvider` set.
final entryFoundProvider = Provider.family<bool, String>(
  (ref, wordKey) => ref.watch(foundWordsProvider).contains(wordKey),
);

/// Provider family exposing whether a cell is locked.
final cellLockedProvider = Provider.family<bool, CellKey>(
  (ref, key) => ref.watch(lockedCellsProvider).contains(key),
);

/// Set of cells belonging to the currently selected word (by selection + direction).
/// Computed once per selection/direction change to avoid per-cell wordBounds calls.
final selectedWordCellsProvider = Provider<Set<CellKey>>((ref) {
  final selected = ref.watch(selectedCellProvider);
  final dir = ref.watch(wordDirectionProvider);
  if (selected == null) {
    return const <CellKey>{};
  }
  final black = ref.watch(gameBoardProvider.select((b) => b.blackCells));
  final horizontal = dir == WordDirection.horizontal;
  final bounds = black.wordBounds(
    selected.row,
    selected.col,
    horizontal: horizontal,
  );
  final cells = <CellKey>{};
  if (horizontal) {
    for (var c = bounds[0]; c <= bounds[1]; c++) {
      cells.add(CellKey(selected.row, c));
    }
  } else {
    for (var r = bounds[0]; r <= bounds[1]; r++) {
      cells.add(CellKey(r, selected.col));
    }
  }
  return cells;
});
