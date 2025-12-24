import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/providers/game_timer_provider.dart';
import 'package:croiz/features/game/helpers/board_helpers.dart';
import 'package:croiz/features/game/controllers/crossword_navigation.dart';
import 'package:croiz/features/game/controllers/entry_helpers.dart';
import 'package:croiz/features/game/controllers/word_completion_checker.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';

/// Controller handling crossword input, navigation, and word completion.
///
/// Responsibilities:
/// - Letter input with auto-advance
/// - Backspace/delete handling
/// - Arrow key navigation
/// - Auto-selecting first across entry on game start
class CrosswordInputController {
  CrosswordInputController(WidgetRef ref)
    : _read = (<T>(provider) => ref.read(provider as dynamic) as T) {
    _wordCompletionChecker = _createWordCompletionChecker();
  }
  CrosswordInputController._(this._read) {
    _wordCompletionChecker = _createWordCompletionChecker();
  }
  factory CrosswordInputController.fromRef(WidgetRef ref) =>
      CrosswordInputController(ref);
  factory CrosswordInputController.fromContainer(ProviderContainer container) =>
      CrosswordInputController._(
        <T>(provider) => container.read(provider as dynamic) as T,
      );

  final T Function<T>(Object provider) _read;
  late final WordCompletionChecker _wordCompletionChecker;
  bool _didAutoSelectFirstAcross = false;

  WordCompletionChecker _createWordCompletionChecker() =>
      WordCompletionChecker.fromReaders(
        readBoard: _safeReadBoard,
        readFoundWords: () => _read<Set<String>>(foundWordsProvider),
        writeFoundWords: (v) => _read(foundWordsProvider.notifier).value = v,
        readLockedCells: () => _read<Set<CellKey>>(lockedCellsProvider),
        writeLockedCells: (v) => _read(lockedCellsProvider.notifier).value = v,
        readFlashingCells: () => _read<Set<CellKey>>(flashingCellsProvider),
        writeFlashingCells: (v) =>
            _read(flashingCellsProvider.notifier).value = v,
        readCellEntriesIndex: () => _read<Map<CellKey, List<PuzzleEntryData>>>(
          cellEntriesIndexProvider,
        ),
        readWordCheckService: () => _read(wordCheckServiceProvider),
        readGameAudioService: () => _read(gameAudioServiceProvider),
        readFlashClearDelay: () => _read<Duration>(flashClearDelayProvider),
        readCheckDebounceDelay: () =>
            _read<Duration>(wordCheckDebounceDelayProvider),
        finalizeTimer: (boardId) =>
            _read(gameTimerProvider(boardId)).finalizeSync(),
      );

  GameBoard _safeReadBoard() {
    try {
      return _read<GameBoard>(gameBoardProvider);
    } on Object catch (e, st) {
      developer.log('gameBoardProvider read failed', error: e, stackTrace: st);
      try {
        final pa = _read<AsyncValue<GameBoard>>(puzzleLoaderProvider);
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
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Letter Input
  // ─────────────────────────────────────────────────────────────────────────

  void setLetterAndAdvance(String letter) {
    final board = _safeReadBoard();
    final selected = _read(selectedCellProvider);
    final lockedCells = _read(lockedCellsProvider);
    final dir = _read(wordDirectionProvider);
    final dr = dir == WordDirection.vertical ? 1 : 0;
    final dc = dir == WordDirection.vertical ? 0 : 1;

    if (selected == null) {
      final first = firstSelectable(board.blackCells);
      if (first == null) {
        return;
      }
      _read(selectedCellProvider.notifier).value = SelectedCell(
        first[0],
        first[1],
      );
      _read(gameBoardProvider.notifier).setLetter(first[0], first[1], letter);
      _wordCompletionChecker.scheduleCheck(CellKey(first[0], first[1]));
      _advanceToNextEmptyFrom(first[0], first[1]);
      return;
    }

    final cellKey = CellKey(selected.row, selected.col);
    if (lockedCells.contains(cellKey)) {
      final next = _nextEditableCell(
        board,
        fromRow: selected.row,
        fromCol: selected.col,
        dr: dr,
        dc: dc,
        wrap: true,
      );
      if (next == null) {
        return;
      }
      final nextRow = next[0];
      final nextCol = next[1];
      _read(selectedCellProvider.notifier).value = SelectedCell(
        nextRow,
        nextCol,
      );
      _read(gameBoardProvider.notifier).setLetter(nextRow, nextCol, letter);
      _wordCompletionChecker.scheduleCheck(CellKey(nextRow, nextCol));
      _advanceToNextEmptyFrom(nextRow, nextCol);
      return;
    }

    // When the selected cell already has a letter, REPLACE it in-place.
    // This allows users to correct mistakes by tapping on a filled cell
    // and typing the correct letter. The old behavior of jumping to the
    // next empty cell was confusing and prevented corrections.
    _read(
      gameBoardProvider.notifier,
    ).setLetter(selected.row, selected.col, letter);
    _wordCompletionChecker.scheduleCheck(CellKey(selected.row, selected.col));
    _advanceToNextEmptyFrom(selected.row, selected.col);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Backspace / Clear
  // ─────────────────────────────────────────────────────────────────────────

  void clearCurrent() {
    final sel = _read(selectedCellProvider);
    if (sel == null) {
      return;
    }

    final lockedCells = _read(lockedCellsProvider);
    final cellKey = CellKey(sel.row, sel.col);
    if (lockedCells.contains(cellKey)) {
      return;
    }

    final board = _safeReadBoard();
    final current = board.grid[sel.row][sel.col];
    if (current == null || current.isEmpty) {
      final dir = _read(wordDirectionProvider);
      final dr = dir == WordDirection.vertical ? -1 : 0;
      final dc = dir == WordDirection.vertical ? 0 : -1;

      var fromR = sel.row;
      var fromC = sel.col;
      final maxSteps = board.gridSize * board.gridSize;
      for (var i = 0; i < maxSteps; i++) {
        final prev = board.blackCells.nextSelectableFrom(
          fromR,
          fromC,
          dr,
          dc,
          wrap: true,
        );
        if (prev == null) {
          break;
        }
        fromR = prev[0];
        fromC = prev[1];
        final letter = board.grid[fromR][fromC];
        if (letter != null && letter.isNotEmpty) {
          final prevKey = CellKey(fromR, fromC);
          final prevSel = SelectedCell(fromR, fromC);
          if (lockedCells.contains(prevKey)) {
            _read(selectedCellProvider.notifier).value = prevSel;
            return;
          }

          _read(selectedCellProvider.notifier).value = prevSel;
          _read(
            gameBoardProvider.notifier,
          ).setLetter(prevSel.row, prevSel.col, '');
          break;
        }
      }
    } else {
      _read(gameBoardProvider.notifier).setLetter(sel.row, sel.col, '');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Auto-select first across entry
  // ─────────────────────────────────────────────────────────────────────────

  void tryAutoSelectFirstAcross(GameBoard board) {
    if (_didAutoSelectFirstAcross) {
      return;
    }
    final alreadySelected = _read(selectedCellProvider);
    if (alreadySelected != null) {
      return;
    }
    final entries = board.entries;
    if (entries == null || entries.isEmpty) {
      return;
    }
    final firstAcross =
        entries.where((e) => e.directionEnum == EntryDirection.across).toList()
          ..sort((a, b) => a.number.compareTo(b.number));
    if (firstAcross.isEmpty) {
      return;
    }
    final e = firstAcross.first;
    _read(selectedCellProvider.notifier).value = SelectedCell(e.y, e.x);
    _read(wordDirectionProvider.notifier).value = WordDirection.horizontal;
    _didAutoSelectFirstAcross = true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Physical Keyboard Input
  // ─────────────────────────────────────────────────────────────────────────

  void handleKey(KeyEvent event, [int? _]) {
    if (event is! KeyDownEvent) {
      return;
    }
    final sel = _read(selectedCellProvider);
    final row = sel?.row ?? 0;
    final col = sel?.col ?? 0;
    final black = _safeReadBoard().blackCells;
    if (sel != null && black.isDisabled(sel.row, sel.col)) {
      return;
    }

    final logical = event.logicalKey;
    if (logical == LogicalKeyboardKey.arrowRight) {
      _moveToDirection(row, col, 0, 1);
      return;
    }
    if (logical == LogicalKeyboardKey.arrowLeft) {
      _moveToDirection(row, col, 0, -1);
      return;
    }
    if (logical == LogicalKeyboardKey.arrowDown) {
      _moveToDirection(row, col, 1, 0);
      return;
    }
    if (logical == LogicalKeyboardKey.arrowUp) {
      _moveToDirection(row, col, -1, 0);
      return;
    }

    if (logical == LogicalKeyboardKey.backspace ||
        logical == LogicalKeyboardKey.delete) {
      clearCurrent();
      return;
    }

    final keyLabel = logical.keyLabel;
    if (keyLabel.length == 1) {
      final char = keyLabel.toUpperCase();
      if (RegExp(r'[A-ZÀ-ÖØ-Ý]', unicode: true).hasMatch(char)) {
        setLetterAndAdvance(char);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigation Helpers
  // ─────────────────────────────────────────────────────────────────────────

  List<int>? _nextEditableCell(
    GameBoard board, {
    required int fromRow,
    required int fromCol,
    required int dr,
    required int dc,
    required bool wrap,
  }) {
    final lockedCells = _read(lockedCellsProvider);
    return nextEditableCell(
      board,
      fromRow: fromRow,
      fromCol: fromCol,
      dr: dr,
      dc: dc,
      wrap: wrap,
      lockedCells: lockedCells,
    );
  }

  void _advanceToNextEmptyFrom(int startRow, int startCol) {
    final board = _safeReadBoard();
    final dir = _read(wordDirectionProvider);
    final isAcross = dir == WordDirection.horizontal;
    final entries = board.entries;
    final lockedCells = _read<Set<CellKey>>(lockedCellsProvider);

    // Try to find containing entry and then the next empty cell after the current
    // position within the same entry.
    if (entries != null && entries.isNotEmpty) {
      final index = _tryReadCellEntriesIndex();
      final containing = findContainingEntry(
        row: startRow,
        col: startCol,
        wantAcross: isAcross,
        entries: entries,
        index: index,
      );
      if (containing != null) {
        // Search within containing entry after the current position
        if (isAcross) {
          for (
            var cc = startCol + 1;
            cc < containing.x + containing.length;
            cc++
          ) {
            final key = CellKey(containing.y, cc);
            if (lockedCells.contains(key)) {
              continue;
            }
            final val = board.grid[containing.y][cc];
            if (val == null || val.isEmpty) {
              _read(selectedCellProvider.notifier).value = SelectedCell(
                containing.y,
                cc,
              );
              return;
            }
          }
        } else {
          for (
            var rr = startRow + 1;
            rr < containing.y + containing.length;
            rr++
          ) {
            final key = CellKey(rr, containing.x);
            if (lockedCells.contains(key)) {
              continue;
            }
            final val = board.grid[rr][containing.x];
            if (val == null || val.isEmpty) {
              _read(selectedCellProvider.notifier).value = SelectedCell(
                rr,
                containing.x,
              );
              return;
            }
          }
        }

        // Not found in same entry -> find next empty in other entries
        // Performance: use pre-sorted entry lists from providers
        final sortedSame = _trySortedEntries(isAcross);
        final sortedOther = _trySortedEntries(!isAcross);
        final nextEmpty = findNextEmptyFromEntry(
          containing: containing,
          wantAcross: isAcross,
          board: board,
          entries: entries,
          lockedCells: lockedCells,
          skipLocked: true,
          sortedSameDir: sortedSame,
          sortedOtherDir: sortedOther,
        );
        if (nextEmpty != null) {
          _read(selectedCellProvider.notifier).value = nextEmpty;
          // Prefer keeping the current direction if the found empty belongs
          // to an entry in the same direction. Only switch if no same-dir
          // entry exists at that cell.
          final idxMap = _tryReadCellEntriesIndex();
          final sameContaining = findContainingEntry(
            row: nextEmpty.row,
            col: nextEmpty.col,
            wantAcross: isAcross,
            entries: entries,
            index: idxMap,
          );
          if (sameContaining != null) {
            // keep current direction
            _read(wordDirectionProvider.notifier).value = dir;
            return;
          }

          // No same-direction entry found -> pick the other direction if present
          final otherContaining = findContainingEntry(
            row: nextEmpty.row,
            col: nextEmpty.col,
            wantAcross: !isAcross,
            entries: entries,
            index: idxMap,
          );
          if (otherContaining != null) {
            _read(
              wordDirectionProvider.notifier,
            ).value = (otherContaining.directionEnum == EntryDirection.across)
                ? WordDirection.horizontal
                : WordDirection.vertical;
          }
          return;
        }
      }
    }

    // Fallback: select the next editable cell in the current direction
    final dr = dir == WordDirection.vertical ? 1 : 0;
    final dc = dir == WordDirection.vertical ? 0 : 1;
    final next = _nextEditableCell(
      board,
      fromRow: startRow,
      fromCol: startCol,
      dr: dr,
      dc: dc,
      wrap: true,
    );
    if (next != null) {
      _read(selectedCellProvider.notifier).value = SelectedCell(
        next[0],
        next[1],
      );
    }
  }

  void _moveToDirection(int row, int col, int dr, int dc) {
    final board = _safeReadBoard();
    final black = board.blackCells;
    final entries = board.entries;
    final maxAttempts = board.gridSize * board.gridSize;
    var currentRow = row;
    var currentCol = col;

    for (var i = 0; i < maxAttempts; i++) {
      final next = black.nextSelectableFrom(
        currentRow,
        currentCol,
        dr,
        dc,
        wrap: true,
      );
      if (next == null) {
        break;
      }

      final nextRow = next[0];
      final nextCol = next[1];

      if (_cellBelongsToWord(nextRow, nextCol, entries)) {
        try {
          if (entries != null) {
            final wantAcross = dc != 0;
            final index = _tryReadCellEntriesIndex();
            final containing = findContainingEntry(
              row: nextRow,
              col: nextCol,
              wantAcross: wantAcross,
              entries: entries,
              index: index,
            );
            if (containing != null) {
              final found = firstEmptyInEntry(
                containing,
                board,
                skipLocked: false,
              );
              if (found != null) {
                if (found.row == row && found.col == col) {
                  _read(selectedCellProvider.notifier).value = SelectedCell(
                    nextRow,
                    nextCol,
                  );
                } else {
                  _read(selectedCellProvider.notifier).value = found;
                }
                return;
              }

              final nextF = findNextEmptyFromEntry(
                containing: containing,
                wantAcross: wantAcross,
                board: board,
                entries: entries,
                skipLocked: false,
              );
              if (nextF != null) {
                _read(selectedCellProvider.notifier).value = nextF;
                return;
              }
            }
          }
        } on Object {
          // ignore and fall back to selecting the encountered cell
        }

        _read(selectedCellProvider.notifier).value = SelectedCell(
          nextRow,
          nextCol,
        );
        return;
      }

      currentRow = nextRow;
      currentCol = nextCol;

      if (nextRow == row && nextCol == col) {
        break;
      }
    }
  }

  bool _cellBelongsToWord(int row, int col, List<PuzzleEntryData>? entries) {
    try {
      final index = _read<Map<CellKey, List<PuzzleEntryData>>>(
        cellEntriesIndexProvider,
      );
      if (index.isEmpty && (entries == null || entries.isEmpty)) {
        return true;
      }
      return (index[CellKey(row, col)]?.isNotEmpty ?? false) ||
          cellBelongsToWord(row, col, entries);
    } on Object {
      return cellBelongsToWord(row, col, entries);
    }
  }

  Map<CellKey, List<PuzzleEntryData>>? _tryReadCellEntriesIndex() {
    try {
      return _read<Map<CellKey, List<PuzzleEntryData>>>(
        cellEntriesIndexProvider,
      );
    } on Object {
      return null;
    }
  }

  /// Get pre-sorted entries for given direction. Returns null on error.
  List<PuzzleEntryData>? _trySortedEntries(bool wantAcross) {
    try {
      return wantAcross
          ? _read<List<PuzzleEntryData>>(sortedAcrossEntriesProvider)
          : _read<List<PuzzleEntryData>>(sortedDownEntriesProvider);
    } on Object {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Disposal
  // ─────────────────────────────────────────────────────────────────────────

  void dispose() {
    _wordCompletionChecker.dispose();
  }
}
