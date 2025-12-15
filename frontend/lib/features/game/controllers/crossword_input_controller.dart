import 'dart:developer' as developer;
import 'dart:async';
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
      _read(selectedCellProvider.notifier).value = SelectedCell(
        first[0],
        first[1],
      );
      _read(gameBoardProvider.notifier).setLetter(first[0], first[1], letter);
      _checkForCompletedWords();
      _moveToNext(board, startRow: first[0], startCol: first[1]);
      return;
    }

    final cellKey = '${selected.row},${selected.col}';
    if (lockedCells.contains(cellKey)) {
      // Current cell is locked: move to the next editable cell (non-black,
      // non-locked) and type there. This avoids the UX where the cursor stays
      // on a locked cell but the letter appears one cell to the right.
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

  List<int>? _nextEditableCell(
    GameBoard board, {
    required int fromRow,
    required int fromCol,
    required int dr,
    required int dc,
    required bool wrap,
  }) {
    final lockedCells = _read(lockedCellsProvider);
    var r = fromRow;
    var c = fromCol;
    final maxSteps = board.gridSize * board.gridSize;
    for (var i = 0; i < maxSteps; i++) {
      final next = board.blackCells.nextSelectableFrom(
        r,
        c,
        dr,
        dc,
        wrap: wrap,
      );
      if (next == null) {
        return null;
      }
      final nr = next[0];
      final nc = next[1];
      if (!lockedCells.contains('$nr,$nc')) {
        return [nr, nc];
      }
      r = nr;
      c = nc;
    }
    return null;
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
    final lockedCells = _read(lockedCellsProvider);
    // If entries are available, and the current cell is the last cell of
    // its entry in the current direction, advance to the FIRST cell of
    // the next entry (by number) in the same direction.
    final entries = board.entries;
    if (entries != null && entries.isNotEmpty) {
      final isAcross = dir == WordDirection.horizontal;
      final dirString = isAcross ? 'across' : 'down';
      final sameDir = entries.where((e) => e.direction == dirString).toList()
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
            // find index of containing in sameDir
            final idx = sameDir.indexWhere(
              (e) => e.number == containing!.number,
            );
            if (idx != -1) {
              // Search forward for next entry in sameDir that is NOT already found
              for (var j = idx + 1; j < sameDir.length; j++) {
                final candidate = sameDir[j];
                final key = wordCheck.getWordKey(candidate);
                if (!foundWords.contains(key)) {
                  final candidateKey = '${candidate.y},${candidate.x}';
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
              // Wrap-around search
              for (var j = 0; j < idx; j++) {
                final candidate = sameDir[j];
                final key = wordCheck.getWordKey(candidate);
                if (!foundWords.contains(key)) {
                  final candidateKey = '${candidate.y},${candidate.x}';
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

              // No available same-direction entries -> try other direction's first non-found
              final otherDirString = isAcross ? 'down' : 'across';
              final otherDir =
                  entries.where((e) => e.direction == otherDirString).toList()
                    ..sort((a, b) => a.number.compareTo(b.number));
              for (final candidate in otherDir) {
                final key = wordCheck.getWordKey(candidate);
                if (!foundWords.contains(key)) {
                  final candidateKey = '${candidate.y},${candidate.x}';
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

        // Clear flash after animation (will be handled by UI).
        // Use configured delay provider: tests can override to Duration.zero
        // which will schedule a microtask (no Timer), otherwise use a Timer.
        final _delay = _read(flashClearDelayProvider);
        // Cancel any previously scheduled clear to avoid dangling timers
        _flashClearTimer?.cancel();
        if (_delay == Duration.zero) {
          Future.microtask(() {
            if (_disposed) {
              return;
            }
            try {
              _read(flashingCellsProvider.notifier).value = <String>{};
            } on Object catch (e, st) {
              developer.log(
                'Clearing flashing cells failed',
                error: e,
                stackTrace: st,
              );
            }
          });
        } else {
          _flashClearTimer = Timer(_delay, () {
            if (_disposed) {
              return;
            }
            try {
              _read(flashingCellsProvider.notifier).value = <String>{};
            } on Object catch (e, st) {
              developer.log(
                'Clearing flashing cells failed',
                error: e,
                stackTrace: st,
              );
            }
          });
        }
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
