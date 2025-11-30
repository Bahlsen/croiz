import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/crossword_grid.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/domain/entities/game_entities.dart';

class CrosswordScreen extends ConsumerStatefulWidget {
  const CrosswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends ConsumerState<CrosswordScreen> {
  bool _isAzerty = true; // Default AZERTY as requested
  final TextEditingController _textController = TextEditingController();

  void _setLetterAndAdvance(String letter) {
    final board = ref.read(gameBoardProvider);
    final selected = ref.read(selectedCellProvider);
    if (selected == null) {
      // If nothing selected, select first available cell and type there
      final first = _firstSelectable(board.blackCells);
      if (first == null) {
        return;
      }
      ref.read(selectedCellProvider.notifier).state = SelectedCell(
        first[0],
        first[1],
      );
      ref
          .read(gameBoardProvider.notifier)
          .setLetter(first[0], first[1], letter);
      _moveToNext(board, startRow: first[0], startCol: first[1]);
      return;
    }
    ref
        .read(gameBoardProvider.notifier)
        .setLetter(selected.row, selected.col, letter);
    _moveToNext(board, startRow: selected.row, startCol: selected.col);
  }

  void _clearCurrent() {
    final sel = ref.read(selectedCellProvider);
    if (sel == null) {
      return;
    }
    final board = ref.read(gameBoardProvider);
    final current = board.grid[sel.row][sel.col];
    if (current == null || current.isEmpty) {
      // Move backwards skipping empty cells until a letter is found, then clear it.
      final dir = ref.read(wordDirectionProvider);
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
          final prevSel = SelectedCell(fromR, fromC);
          ref.read(selectedCellProvider.notifier).state = prevSel;
          ref
              .read(gameBoardProvider.notifier)
              .setLetter(prevSel.row, prevSel.col, '');
          _flashCell(fromR, fromC);
          break;
        }
      }
    } else {
      // Clear current cell but keep selection
      ref.read(gameBoardProvider.notifier).setLetter(sel.row, sel.col, '');
      _flashCell(sel.row, sel.col);
    }
  }

  // Enter no longer toggles direction; kept for potential future use.

  void _moveToNext(
    GameBoard board, {
    required int startRow,
    required int startCol,
  }) {
    final dir = ref.read(wordDirectionProvider);
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
      ref.read(selectedCellProvider.notifier).state = SelectedCell(
        next[0],
        next[1],
      );
    }
  }

  List<int>? _firstSelectable(List<List<bool>> black) {
    for (var r = 0; r < black.length; r++) {
      for (var c = 0; c < (black[r].length); c++) {
        if (!black.isDisabled(r, c)) {
          return [r, c];
        }
      }
    }
    return null;
  }

  void _flashCell(int r, int c) {
    ref.read(flashCellProvider.notifier).state = '$r,$c';
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted && ref.read(flashCellProvider) == '$r,$c') {
        ref.read(flashCellProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(gameBoardProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Crossword'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                color: Colors.black,
                child: const CrosswordGrid(),
              ),
            ),
          ),
          _buildKeyboardBar(context, board),
        ],
      ),
    );
  }

  Widget _buildKeyboardBar(BuildContext context, GameBoard board) {
    final layout = _isAzerty
        ? VirtualKeyboard.azertyLayout
        : VirtualKeyboard.qwertyLayout;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Basculer AZERTY/QWERTY',
              icon: const Icon(Icons.keyboard_alt, color: Colors.white70),
              onPressed: () => setState(() => _isAzerty = !_isAzerty),
            ),
          ),
          VirtualKeyboard(
            layout: layout,
            onKey: _setLetterAndAdvance,
            onBackspace: _clearCurrent,
            // onEnter: null, // Enter no-op per request
            enableFeedback: true,
            keyHeight: 44,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          ),
        ],
      ),
    );
  }
}
