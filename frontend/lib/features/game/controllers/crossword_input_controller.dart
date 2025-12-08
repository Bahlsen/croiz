import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/game_timer_provider.dart';
import 'package:croiz/features/game/board_helpers.dart';
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
  bool _didAutoSelectFirstAcross = false;

  GameBoard _safeReadBoard([int fallbackSize = 5]) {
    try {
      return _read<GameBoard>(gameBoardProvider);
    } on Object catch (e, st) {
      developer.log(
        'gameBoardProvider read failed, falling back to puzzleLoader',
        error: e,
        stackTrace: st,
      );
      try {
        final pa = _read<AsyncValue<GameBoard>>(puzzleLoaderProvider);
        return pa.maybeWhen(
          data: (d) => d,
          orElse: () => createEmptyBoard(fallbackSize),
        );
      } on Object catch (e2, st2) {
        developer.log(
          'puzzleLoaderProvider read failed, returning empty board',
          error: e2,
          stackTrace: st2,
        );
        return createEmptyBoard(fallbackSize);
      }
    }
  }

  void setLetterAndAdvance(String letter) {
    final board = _safeReadBoard();
    final selected = _read(selectedCellProvider);

    if (selected == null) {
      final first = _firstSelectable(board.blackCells);
      if (first == null) {
        return;
      }
      _read(selectedCellProvider.notifier).value = SelectedCell(
        first[0],
        first[1],
      );
      _read(gameBoardProvider.notifier).setLetter(first[0], first[1], letter);
      _checkForCompletedWords();
      _moveToNext(board, startRow: first[0], startCol: first[1]);
      return;
    }

    // Check if the cell is locked
    final lockedCells = _read(lockedCellsProvider);
    final cellKey = '${selected.row},${selected.col}';
    if (lockedCells.contains(cellKey)) {
      // If current cell is locked, insert into the next selectable cell
      final dir = _read(wordDirectionProvider);
      final dr = dir == WordDirection.vertical ? 1 : 0;
      final dc = dir == WordDirection.vertical ? 0 : 1;
      final next = board.blackCells.nextSelectableFrom(
        selected.row,
        selected.col,
        dr,
        dc,
        wrap: true,
      );
      if (next == null) {
        return; // No next cell available
      }
      final nextRow = next[0];
      final nextCol = next[1];
      _read(gameBoardProvider.notifier).setLetter(nextRow, nextCol, letter);
      _checkForCompletedWords();
      _moveToNext(board, startRow: nextRow, startCol: nextCol);
      return;
    }

    _read(
      gameBoardProvider.notifier,
    ).setLetter(selected.row, selected.col, letter);
    _checkForCompletedWords();
    _moveToNext(board, startRow: selected.row, startCol: selected.col);
  }

  void clearCurrent() {
    final sel = _read(selectedCellProvider);
    if (sel == null) {
      return;
    }

    // Check if the cell is locked
    final lockedCells = _read(lockedCellsProvider);
    final cellKey = '${sel.row},${sel.col}';
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
          final prevKey = '$fromR,$fromC';
          final prevSel = SelectedCell(fromR, fromC);
          // If the previous filled cell is locked, move selection there
          // but do NOT delete its letter. The virtual keyboard already
          // plays the delete sound before calling into this method, so
          // user hears feedback even when deletion is blocked.
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
    final firstAcross = entries.where((e) => e.direction == 'across').toList()
      ..sort((a, b) => a.number.compareTo(b.number));
    if (firstAcross.isEmpty) {
      return;
    }
    final e = firstAcross.first;
    _read(selectedCellProvider.notifier).value = SelectedCell(e.y, e.x);
    _read(wordDirectionProvider.notifier).value = WordDirection.horizontal;
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

    // Try to find next cell that belongs to a valid word
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

      // Check if this cell belongs to at least one word entry
      if (_cellBelongsToWord(nextRow, nextCol, entries)) {
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

  bool _cellBelongsToWord(int row, int col, List<PuzzleEntryData>? entries) {
    if (entries == null || entries.isEmpty) {
      return true; // If no entries defined, allow all non-black cells
    }

    for (final entry in entries) {
      final isAcross = entry.direction == 'across';
      if (isAcross) {
        // Check if cell is in this horizontal word
        if (row == entry.y && col >= entry.x && col < entry.x + entry.length) {
          return true;
        }
      } else {
        // Check if cell is in this vertical word
        if (col == entry.x && row >= entry.y && row < entry.y + entry.length) {
          return true;
        }
      }
    }
    return false;
  }

  void _moveToNext(
    GameBoard board, {
    required int startRow,
    required int startCol,
  }) {
    final dir = _read(wordDirectionProvider);
    final dr = dir == WordDirection.vertical ? 1 : 0;
    final dc = dir == WordDirection.vertical ? 0 : 1;
    final next = board.blackCells.nextSelectableFrom(
      startRow,
      startCol,
      dr,
      dc,
      wrap: true,
    );
    if (next != null) {
      _read(selectedCellProvider.notifier).state = SelectedCell(
        next[0],
        next[1],
      );
    }
  }

  List<int>? _firstSelectable(List<List<bool>> black) {
    for (var r = 0; r < black.length; r++) {
      for (var c = 0; c < black[r].length; c++) {
        if (!black.isDisabled(r, c)) {
          return [r, c];
        }
      }
    }
    return null;
  }

  void _checkForCompletedWords() {
    final board = _safeReadBoard();
    final entries = board.entries;

    if (entries == null || entries.isEmpty) {
      return;
    }

    final wordCheckService = _read(wordCheckServiceProvider);
    final foundWords = _read(foundWordsProvider);
    final newFoundWords = Set<String>.from(foundWords);
    final lockedCells = _read(lockedCellsProvider);
    final newLockedCells = Set<String>.from(lockedCells);

    for (final entry in entries) {
      final wordKey = wordCheckService.getWordKey(entry);

      // Skip if already found
      if (foundWords.contains(wordKey)) {
        continue;
      }

      // Check if word is complete
      if (wordCheckService.isWordComplete(board, entry)) {
        newFoundWords.add(wordKey);

        // Play success sound
        try {
          _read(gameAudioServiceProvider).playSuccess();
        } on Object catch (e, st) {
          developer.log('playSuccess failed', error: e, stackTrace: st);
        }

        // Trigger flash animation on cells
        final cellKeys = wordCheckService.getCellKeys(entry);
        _read(flashingCellsProvider.notifier).value = cellKeys.toSet();

        // Lock cells of the found word
        newLockedCells.addAll(cellKeys);

        // Clear flash after animation (will be handled by UI)
        Future.delayed(const Duration(milliseconds: 500), () {
          try {
            _read(flashingCellsProvider.notifier).value = <String>{};
          } on Object catch (e, st) {
            developer.log(
              'Clearing flashing cells failed',
              error: e,
              stackTrace: st,
            );
            // Provider might be disposed if user navigated away
          }
        });
      }
    }

    if (newFoundWords.length > foundWords.length) {
      _read(foundWordsProvider.notifier).value = newFoundWords;
    }

    if (newLockedCells.length > lockedCells.length) {
      _read(lockedCellsProvider.notifier).value = newLockedCells;
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
}

// no-op helper removed: using container.read directly
