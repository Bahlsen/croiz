import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/game_timer_provider.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/features/game/controllers/crossword_navigation.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';

class CrosswordInputController {
  CrosswordInputController(WidgetRef ref)
    : _read = (<T>(provider) => ref.read(provider as dynamic) as T);
  CrosswordInputController._(this._read);
  factory CrosswordInputController.fromRef(WidgetRef ref) =>
      CrosswordInputController(ref);
  factory CrosswordInputController.fromContainer(ProviderContainer container) =>
      CrosswordInputController._(
        <T>(provider) => container.read(provider as dynamic) as T,
      );
  final T Function<T>(Object provider) _read;
  Timer? _flashClearTimer;
  bool _disposed = false;
  bool _didAutoSelectFirstAcross = false;

  GameBoard _safeReadBoard() {
    try {
      return _read<GameBoard>(gameBoardProvider);
    } on Object catch (e, st) {
      developer.log('gameBoardProvider read failed', error: e, stackTrace: st);
      // Try to obtain the loaded puzzle synchronously from the loader.
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

  void setLetterAndAdvance(String letter) {
    final board = _safeReadBoard();
    final selected = _read(selectedCellProvider);
    final lockedCells = _read(lockedCellsProvider);
    final dir = _read(wordDirectionProvider);
    final dr = dir == WordDirection.vertical ? 1 : 0;
    final dc = dir == WordDirection.vertical ? 0 : 1;

    if (selected == null) {
      final first = _firstSelectable(board.blackCells);
      if (first == null) {
        return;
      }
      _read(selectedCellProvider.notifier).state = SelectedCell(
        first[0],
        first[1],
      );
      final wasEmpty =
          (board.grid[first[0]][first[1]] == null) ||
          (board.grid[first[0]][first[1]]?.isEmpty ?? true);
      _read(gameBoardProvider.notifier).setLetter(first[0], first[1], letter);
      // Immediate check ensures effects (audio/flash/locks) trigger deterministically.
      _checkForCompletedWords(CellKey(first[0], first[1]));
      // Scheduled check removed - immediate check already handles word completion.
      _moveToNext(
        _safeReadBoard(),
        startRow: first[0],
        startCol: first[1],
        wasEmptyAtStart: wasEmpty,
      );
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
      _read(selectedCellProvider.notifier).state = SelectedCell(
        nextRow,
        nextCol,
      );
      final wasEmpty =
          (board.grid[nextRow][nextCol] == null) ||
          (board.grid[nextRow][nextCol]?.isEmpty ?? true);
      _read(gameBoardProvider.notifier).setLetter(nextRow, nextCol, letter);
      _checkForCompletedWords(CellKey(nextRow, nextCol));
      _moveToNext(
        _safeReadBoard(),
        startRow: nextRow,
        startCol: nextCol,
        wasEmptyAtStart: wasEmpty,
      );
      return;
    }

    final currentValue = board.grid[selected.row][selected.col];
    if (currentValue != null && currentValue.isNotEmpty) {
      final wantAcross = dir == WordDirection.horizontal;
      final entries = board.entries ?? <PuzzleEntryData>[];

      final containing = _findContainingEntry(
        selected.row,
        selected.col,
        wantAcross,
        entries,
      );
      if (containing != null) {
        final f = _firstEmptyInEntry(containing, board, skipLocked: true);
        if (f != null) {
          // f is guaranteed empty by definition
          _read(gameBoardProvider.notifier).setLetter(f.row, f.col, letter);
          _checkForCompletedWords(CellKey(f.row, f.col));
          _moveToNext(
            _safeReadBoard(),
            startRow: f.row,
            startCol: f.col,
            wasEmptyAtStart: true,
          );
          return;
        }

        // No empty cell within the containing entry. If caret is on the
        // last cell and replacing it would still leave the word incomplete,
        // treat this as editing the last letter in-place (no jump).
        final isLastCellOfContaining = wantAcross
            ? (selected.col == containing.x + containing.length - 1)
            : (selected.row == containing.y + containing.length - 1);
        if (isLastCellOfContaining) {
          final hasAuthoritative =
              (board.solutionGrid != null) ||
              (containing.answer?.isNotEmpty ?? false);
          if (hasAuthoritative) {
            // With authoritative answers, treat typing on last cell as editing
            // in place, then let _moveToNext decide advancement.
            _read(
              gameBoardProvider.notifier,
            ).setLetter(selected.row, selected.col, letter);
            _checkForCompletedWords(CellKey(selected.row, selected.col));
            _moveToNext(
              _safeReadBoard(),
              startRow: selected.row,
              startCol: selected.col,
              wasEmptyAtStart: false,
            );
            return;
          }
        }

        // Otherwise, try to advance to the first empty cell of the next entry.
        final nextF = _findNextEmptyFromEntry(
          containing,
          wantAcross,
          board,
          entries,
        );
        if (nextF != null) {
          // nextF is the first empty of the next/other entry
          _read(
            gameBoardProvider.notifier,
          ).setLetter(nextF.row, nextF.col, letter);
          _checkForCompletedWords(CellKey(nextF.row, nextF.col));
          _moveToNext(
            _safeReadBoard(),
            startRow: nextF.row,
            startCol: nextF.col,
            wasEmptyAtStart: true,
          );
          return;
        }
      }
    }

    final wasEmptyHere =
        (board.grid[selected.row][selected.col] == null) ||
        (board.grid[selected.row][selected.col]?.isEmpty ?? true);
    _read(
      gameBoardProvider.notifier,
    ).setLetter(selected.row, selected.col, letter);
    _checkForCompletedWords(CellKey(selected.row, selected.col));
    _moveToNext(
      _safeReadBoard(),
      startRow: selected.row,
      startCol: selected.col,
      wasEmptyAtStart: wasEmptyHere,
    );
  }

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

  void clearCurrent() {
    final sel = _read(selectedCellProvider);
    if (sel == null) {
      return;
    }

    // Check if the cell is locked
    final lockedCells = _read(lockedCellsProvider);
    final cellKey = CellKey(sel.row, sel.col);
    if (lockedCells.contains(cellKey)) {
      return; // Cell is locked, cannot modify
    }

    // delete sound is handled by the virtual keyboard UI

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
          // If the previous filled cell is locked, move selection there
          // but do NOT delete its letter. The virtual keyboard already
          // plays the delete sound before calling into this method, so
          // user hears feedback even when deletion is blocked.
          if (lockedCells.contains(prevKey)) {
            _read(selectedCellProvider.notifier).state = prevSel;
            return;
          }

          _read(selectedCellProvider.notifier).state = prevSel;
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
    _read(selectedCellProvider.notifier).state = SelectedCell(e.y, e.x);
    _read(wordDirectionProvider.notifier).state = WordDirection.horizontal;
    _didAutoSelectFirstAcross = true;
  }

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
      // Use the same deletion logic as the on-screen backspace so that
      // locked cells (found words) are respected and we correctly move
      // to the previous filled cell when current is empty.
      clearCurrent();
      return;
    }

    final keyLabel = logical.keyLabel;
    if (keyLabel.length == 1) {
      final char = keyLabel.toUpperCase();
      if (RegExp(r'[A-ZÀ-ÖØ-Ý]', unicode: true).hasMatch(char)) {
        // Delegate to setLetterAndAdvance so locked cells and advance
        // behavior are handled consistently for physical keyboard input.
        setLetterAndAdvance(char);
      }
    }
  }

  // Physical keyboard handling is intentionally disabled in the UI.
  // Do not route RawKeyEvents into the controller; use the in-app
  // `VirtualKeyboard` and `CrosswordControlsBar` for all input.

  void _moveToDirection(int row, int col, int dr, int dc) {
    final board = _safeReadBoard();
    final black = board.blackCells;
    final entries = board.entries;
    // Try to find next cell that belongs to a valid word. When we encounter
    // a cell that belongs to a word entry, select the first empty cell of
    // that entry (in the entry's direction). If no empty cell exists,
    // fall back to selecting the cell encountered.
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

      // If this cell belongs to a word entry, try to select the first empty
      // cell of that entry (scanning from the entry's start). If that entry
      // is full, advance to the next entry(s) (same direction, then other
      // direction) and pick their first empty cell. Fallback: select the
      // encountered cell.
      if (_cellBelongsToWord(nextRow, nextCol, entries)) {
        try {
          if (entries != null) {
            final wantAcross = dc != 0;
            final containing = _findContainingEntry(
              nextRow,
              nextCol,
              wantAcross,
              entries,
            );
            if (containing != null) {
              final found = _firstEmptyInEntry(
                containing,
                board,
                skipLocked: false,
              );
              if (found != null) {
                if (found.row == row && found.col == col) {
                  _read(selectedCellProvider.notifier).state = SelectedCell(
                    nextRow,
                    nextCol,
                  );
                } else {
                  _read(selectedCellProvider.notifier).state = found;
                }
                return;
              }

              final nextF = _findNextEmptyFromEntry(
                containing,
                wantAcross,
                board,
                entries,
                skipLocked: false,
              );
              if (nextF != null) {
                _read(selectedCellProvider.notifier).state = nextF;
                return;
              }
            }
          }
        } on Object {
          // ignore and fall back to selecting the encountered cell
        }

        // Fallback: select the cell we landed on
        _read(selectedCellProvider.notifier).state = SelectedCell(
          nextRow,
          nextCol,
        );
        return;
      }

      // Continue searching from this cell
      currentRow = nextRow;
      currentCol = nextCol;

      // Avoid infinite loop by breaking if we've returned to start
      if (nextRow == row && nextCol == col) {
        break;
      }
    }
  }

  bool _cellBelongsToWord(int row, int col, List<PuzzleEntryData>? entries) =>
      (() {
        // Prefer fast index when available; fallback to linear check helper.
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
      })();

  void _moveToNext(
    GameBoard board, {
    required int startRow,
    required int startCol,
    required bool wasEmptyAtStart,
  }) {
    final dir = _read(wordDirectionProvider);
    final lockedCells = _read(lockedCellsProvider);
    // If entries are available, and the current cell is the last cell of
    // its entry in the current direction, advance to the FIRST cell of
    // the next entry (by number) in the same direction.
    final entries = board.entries;
    if (entries != null && entries.isNotEmpty) {
      final isAcross = dir == WordDirection.horizontal;
      final sameDir =
          entries
              .where(
                (e) =>
                    (isAcross && e.directionEnum == EntryDirection.across) ||
                    (!isAcross && e.directionEnum == EntryDirection.down),
              )
              .toList()
            ..sort((a, b) => a.number.compareTo(b.number));
      final wordCheck = _read(wordCheckServiceProvider);
      final foundWords = _read(foundWordsProvider);

      if (sameDir.isNotEmpty) {
        PuzzleEntryData? containing;
        for (final e in sameDir) {
          if (isAcross) {
            if (startRow == e.y &&
                startCol >= e.x &&
                startCol < e.x + e.length) {
              containing = e;
              break;
            }
          } else {
            if (startCol == e.x &&
                startRow >= e.y &&
                startRow < e.y + e.length) {
              containing = e;
              break;
            }
          }
        }

        if (containing != null) {
          final isLast = isAcross
              ? (startCol == containing.x + containing.length - 1)
              : (startRow == containing.y + containing.length - 1);
          if (isLast) {
            // Only auto-advance to the next entry if the current word is
            // actually complete (or already found), OR if we just filled an
            // empty last cell (forward typing). When editing the last cell
            // (was not empty), require completion; otherwise stay put.
            final canAdvance = (() {
              if (wasEmptyAtStart) {
                return true;
              }
              final key = wordCheck.getWordKey(containing);
              if (foundWords.contains(key)) {
                return true;
              }
              return wordCheck.isWordComplete(board, containing);
            })();
            if (!canAdvance) {
              return; // keep selection on the last cell
            }
            // find index of containing in sameDir
            final currentNumber = containing.number;
            final idx = sameDir.indexWhere((e) => e.number == currentNumber);
            if (idx != -1) {
              // Move to the next numbered entry in the same direction (wrap around).
              // This ensures that when the last letter of a word is entered,
              // selection advances to the next word number in the current mode.
              if (sameDir.length > 1) {
                // Advance to the next available entry (skip found/locked).
                for (var offset = 1; offset <= sameDir.length; offset++) {
                  final candidate = sameDir[(idx + offset) % sameDir.length];
                  final key = wordCheck.getWordKey(candidate);
                  if (foundWords.contains(key)) {
                    continue;
                  }
                  final candidateKey = CellKey(candidate.y, candidate.x);
                  if (lockedCells.contains(candidateKey)) {
                    continue;
                  }
                  _read(selectedCellProvider.notifier).state = SelectedCell(
                    candidate.y,
                    candidate.x,
                  );
                  return;
                }
              }

              // If there's no other same-direction entry, fall back to other
              // direction's first non-found entry (preserve existing behavior).
              final otherDir =
                  entries
                      .where(
                        (e) =>
                            (isAcross &&
                                e.directionEnum == EntryDirection.down) ||
                            (!isAcross &&
                                e.directionEnum == EntryDirection.across),
                      )
                      .toList()
                    ..sort((a, b) => a.number.compareTo(b.number));
              for (final candidate in otherDir) {
                final key = wordCheck.getWordKey(candidate);
                if (!foundWords.contains(key)) {
                  final candidateKey = CellKey(candidate.y, candidate.x);
                  if (lockedCells.contains(candidateKey)) {
                    continue;
                  }
                  _read(selectedCellProvider.notifier).state = SelectedCell(
                    candidate.y,
                    candidate.x,
                  );
                  _read(wordDirectionProvider.notifier).state = isAcross
                      ? WordDirection.vertical
                      : WordDirection.horizontal;
                  return;
                }
              }
            }
          }
        }
      }
    }

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
      _read(selectedCellProvider.notifier).state = SelectedCell(
        next[0],
        next[1],
      );
    }
  }

  List<int>? _firstSelectable(List<List<bool>> black) => firstSelectable(black);

  PuzzleEntryData? _findContainingEntry(
    int row,
    int col,
    bool wantAcross,
    List<PuzzleEntryData>? entries,
  ) {
    try {
      final index = _read<Map<CellKey, List<PuzzleEntryData>>>(
        cellEntriesIndexProvider,
      );
      final list = index[CellKey(row, col)];
      if (list == null || list.isEmpty) {
        return null;
      }
      final dir = wantAcross ? EntryDirection.across : EntryDirection.down;
      for (final e in list) {
        if (e.directionEnum == dir) {
          return e;
        }
      }
    } on Object {
      // ignore and fallback
    }
    if (entries == null || entries.isEmpty) {
      return null;
    }
    for (final e in entries) {
      if (wantAcross && e.directionEnum != EntryDirection.across) {
        continue;
      }
      if (!wantAcross && e.directionEnum != EntryDirection.down) {
        continue;
      }
      final contains = wantAcross
          ? (row == e.y && col >= e.x && col < e.x + e.length)
          : (col == e.x && row >= e.y && row < e.y + e.length);
      if (contains) {
        return e;
      }
    }
    return null;
  }

  SelectedCell? _firstEmptyInEntry(
    PuzzleEntryData e,
    GameBoard board, {
    bool skipLocked = false,
  }) {
    final locked = skipLocked ? _read(lockedCellsProvider) : <CellKey>{};
    if (e.directionEnum == EntryDirection.across) {
      for (var cc = e.x; cc < e.x + e.length; cc++) {
        final key = CellKey(e.y, cc);
        if (skipLocked && locked.contains(key)) {
          continue;
        }
        final val = board.grid[e.y][cc];
        if (val == null || val.isEmpty) {
          return SelectedCell(e.y, cc);
        }
      }
    } else {
      for (var rr = e.y; rr < e.y + e.length; rr++) {
        final key = CellKey(rr, e.x);
        if (skipLocked && locked.contains(key)) {
          continue;
        }
        final val = board.grid[rr][e.x];
        if (val == null || val.isEmpty) {
          return SelectedCell(rr, e.x);
        }
      }
    }
    return null;
  }

  SelectedCell? _findNextEmptyFromEntry(
    PuzzleEntryData containing,
    bool wantAcross,
    GameBoard board,
    List<PuzzleEntryData>? entries, {
    bool skipLocked = true,
  }) {
    if (entries == null || entries.isEmpty) {
      return null;
    }
    final sameDir =
        entries
            .where(
              (e) =>
                  (wantAcross && e.directionEnum == EntryDirection.across) ||
                  (!wantAcross && e.directionEnum == EntryDirection.down),
            )
            .toList()
          ..sort((a, b) => a.number.compareTo(b.number));
    final idx = sameDir.indexWhere((e) => e.number == containing.number);
    if (idx != -1) {
      for (var j = idx + 1; j < sameDir.length; j++) {
        final candidate = sameDir[j];
        final ff = _firstEmptyInEntry(candidate, board, skipLocked: skipLocked);
        if (ff != null) {
          return ff;
        }
      }
      for (var j = 0; j < idx; j++) {
        final candidate = sameDir[j];
        final ff = _firstEmptyInEntry(candidate, board, skipLocked: skipLocked);
        if (ff != null) {
          return ff;
        }
      }
    }

    final otherDir =
        entries
            .where(
              (e) =>
                  (wantAcross && e.directionEnum == EntryDirection.down) ||
                  (!wantAcross && e.directionEnum == EntryDirection.across),
            )
            .toList()
          ..sort((a, b) => a.number.compareTo(b.number));
    for (final candidate in otherDir) {
      final ff = _firstEmptyInEntry(candidate, board, skipLocked: skipLocked);
      if (ff != null) {
        return ff;
      }
    }
    return null;
  }

  void _checkForCompletedWords([CellKey? changedCell]) {
    final board = _safeReadBoard();
    final entries = board.entries;

    if (entries == null || entries.isEmpty) {
      return;
    }

    final wordCheckService = _read(wordCheckServiceProvider);
    final foundWords = _read(foundWordsProvider);
    final newFoundWords = Set<String>.from(foundWords);
    final lockedCells = _read(lockedCellsProvider);
    final newLockedCells = Set<CellKey>.from(lockedCells);

    // If a changed cell is provided, only check entries that include that cell
    // using the precomputed index for speed. Otherwise check all entries.
    final entriesToCheck = <PuzzleEntryData>[];
    if (changedCell != null) {
      try {
        final index = _read<Map<CellKey, List<PuzzleEntryData>>>(
          cellEntriesIndexProvider,
        );
        final list = index[changedCell];
        if (list != null && list.isNotEmpty) {
          entriesToCheck.addAll(list);
        } else {
          // No entries mapped to this cell; nothing to do.
        }
      } on Object {
        // Fallback to checking all entries if index lookup fails.
        entriesToCheck.addAll(entries);
      }
    } else {
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

        // Collect cells for flash animation (accumulate for all completed words)
        final cellKeys = wordCheckService.getCellKeys(entry);
        allFlashingCells.addAll(cellKeys);

        // Lock cells of the found word
        newLockedCells.addAll(cellKeys);
      }
    }

    // Play success sound once if any words were completed
    if (wordsCompletedThisCheck > 0) {
      try {
        _read(gameAudioServiceProvider).playSuccess();
      } on Object catch (e, st) {
        developer.log('playSuccess failed', error: e, stackTrace: st);
      }

      // Trigger flash animation on ALL completed words' cells at once
      _read(flashingCellsProvider.notifier).state = allFlashingCells;

      // Clear flash after animation (single timer for all words)
      final _delay = _read(flashClearDelayProvider);
      _flashClearTimer?.cancel();
      _flashClearTimer = Timer(_delay, () {
        if (_disposed) {
          return;
        }
        try {
          _read(flashingCellsProvider.notifier).state = <CellKey>{};
        } on Object catch (e, st) {
          developer.log(
            'Clearing flashing cells failed',
            error: e,
            stackTrace: st,
          );
        }
      });
    }

    if (newFoundWords.length > foundWords.length) {
      _read(foundWordsProvider.notifier).state = newFoundWords;
    }

    if (newLockedCells.length > lockedCells.length) {
      _read(lockedCellsProvider.notifier).state = newLockedCells;
    }

    // If all words found -> finalize timer and play victory sound
    try {
      final totalEntries = entries.length;
      if (totalEntries > 0 && newFoundWords.length == totalEntries) {
        try {
          _read(gameTimerProvider(board.id)).finalizeSync();
        } on Object catch (e, st) {
          developer.log('finalizeSync failed', error: e, stackTrace: st);
        }
        try {
          _read(gameAudioServiceProvider).playVictory();
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
    } on Object {
      // ignore
    }
  }
}

// no-op helper removed: using container.read directly
