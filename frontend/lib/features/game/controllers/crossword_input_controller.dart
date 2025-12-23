import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/game_timer_provider.dart';
import 'package:croiz/features/game/board_helpers.dart';
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
        writeFoundWords: (v) => _read(foundWordsProvider.notifier).state = v,
        readLockedCells: () => _read<Set<CellKey>>(lockedCellsProvider),
        writeLockedCells: (v) => _read(lockedCellsProvider.notifier).state = v,
        readFlashingCells: () => _read<Set<CellKey>>(flashingCellsProvider),
        writeFlashingCells: (v) =>
            _read(flashingCellsProvider.notifier).state = v,
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
      _read(selectedCellProvider.notifier).state = SelectedCell(
        first[0],
        first[1],
      );
      final wasEmpty =
          (board.grid[first[0]][first[1]] == null) ||
          (board.grid[first[0]][first[1]]?.isEmpty ?? true);
      _read(gameBoardProvider.notifier).setLetter(first[0], first[1], letter);
      _wordCompletionChecker.scheduleCheck(CellKey(first[0], first[1]));
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
      _wordCompletionChecker.scheduleCheck(CellKey(nextRow, nextCol));
      _moveToNext(
        _safeReadBoard(),
        startRow: nextRow,
        startCol: nextCol,
        wasEmptyAtStart: wasEmpty,
      );
      return;
    }

    // When the selected cell already has a letter, REPLACE it in-place.
    // This allows users to correct mistakes by tapping on a filled cell
    // and typing the correct letter. The old behavior of jumping to the
    // next empty cell was confusing and prevented corrections.
    final wasEmptyHere =
        (board.grid[selected.row][selected.col] == null) ||
        (board.grid[selected.row][selected.col]?.isEmpty ?? true);
    _read(
      gameBoardProvider.notifier,
    ).setLetter(selected.row, selected.col, letter);
    _wordCompletionChecker.scheduleCheck(CellKey(selected.row, selected.col));
    _moveToNext(
      _safeReadBoard(),
      startRow: selected.row,
      startCol: selected.col,
      wasEmptyAtStart: wasEmptyHere,
    );
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
    _read(selectedCellProvider.notifier).state = SelectedCell(e.y, e.x);
    _read(wordDirectionProvider.notifier).state = WordDirection.horizontal;
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
                  _read(selectedCellProvider.notifier).state = SelectedCell(
                    nextRow,
                    nextCol,
                  );
                } else {
                  _read(selectedCellProvider.notifier).state = found;
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
                _read(selectedCellProvider.notifier).state = nextF;
                return;
              }
            }
          }
        } on Object {
          // ignore and fall back to selecting the encountered cell
        }

        _read(selectedCellProvider.notifier).state = SelectedCell(
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

  void _moveToNext(
    GameBoard board, {
    required int startRow,
    required int startCol,
    required bool wasEmptyAtStart,
  }) {
    final dir = _read(wordDirectionProvider);
    final lockedCells = _read(lockedCellsProvider);
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
              return;
            }
            final currentNumber = containing.number;
            final idx = sameDir.indexWhere((e) => e.number == currentNumber);
            if (idx != -1) {
              if (sameDir.length > 1) {
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
                  // Find the first empty cell in the candidate word
                  final firstEmpty = firstEmptyInEntry(
                    candidate,
                    board,
                    lockedCells: lockedCells,
                    skipLocked: true,
                  );
                  if (firstEmpty != null) {
                    _read(selectedCellProvider.notifier).state = firstEmpty;
                  } else {
                    // Fallback to first cell if no empty cell found
                    _read(selectedCellProvider.notifier).state = SelectedCell(
                      candidate.y,
                      candidate.x,
                    );
                  }
                  return;
                }
              }

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
                  // Find the first empty cell in the candidate word
                  final firstEmpty = firstEmptyInEntry(
                    candidate,
                    board,
                    lockedCells: lockedCells,
                    skipLocked: true,
                  );
                  if (firstEmpty != null) {
                    _read(selectedCellProvider.notifier).state = firstEmpty;
                  } else {
                    // Fallback to first cell if no empty cell found
                    _read(selectedCellProvider.notifier).state = SelectedCell(
                      candidate.y,
                      candidate.x,
                    );
                  }
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

  Map<CellKey, List<PuzzleEntryData>>? _tryReadCellEntriesIndex() {
    try {
      return _read<Map<CellKey, List<PuzzleEntryData>>>(
        cellEntriesIndexProvider,
      );
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
