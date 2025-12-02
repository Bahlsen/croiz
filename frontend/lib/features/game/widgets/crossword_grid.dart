import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/board_helpers.dart';
// clue_numbering is used by `CrosswordCell` instead; avoid direct import here.
import 'package:croiz/features/game/widgets/crossword_cell.dart';

class CrosswordGrid extends ConsumerStatefulWidget {
  const CrosswordGrid({Key? key}) : super(key: key);

  @override
  ConsumerState<CrosswordGrid> createState() => _CrosswordGridState();
}

class _CrosswordGridState extends ConsumerState<CrosswordGrid> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'crossword-grid');
  final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Do not request focus: physical keyboard must never be active in-app.
  }

  @override
  void dispose() {
    _editingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Physical keyboard is disabled in-app; controller.handleKey is callable
  // by tests or other non-UI code when needed.

  // Return the next non-black selectable cell after (row,col).
  // Step is derived from the current `wordDirectionProvider`:
  // - vertical   => move down (row+1)
  // - horizontal => move right (col+1)
  // Arrow keys bypass this by calling `_findNextSelectableInDirection`.
  // Returns null if none in bounds.
  // Removed: handled by CrosswordInputController

  // Find the next selectable in an explicit direction (dr,dc). Used for arrow keys.
  // Removed: handled by CrosswordInputController

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(gameBoardProvider);
    final size = board.gridSize;
    final selected = ref.watch(selectedCellProvider);
    final black = board.blackCells;

    // If selection somehow points to a disabled cell (from older state), clear it.
    if (selected != null && black.isDisabled(selected.row, selected.col)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(selectedCellProvider.notifier).value = null;
        }
      });
    }

    // Compute clue numbers using utility for SRP (used by `CrosswordCell`).
    // Kept here for compatibility with any logic that may rely on numbering.
    // final numbers = ClueNumbering.numbersFromBoard(board);
    // If entries are missing (e.g. during loading or in tests), skip numbering gracefully.
    // numbers.isEmpty simply means no clue numbers to overlay.
    // No further validation: numbering is placed strictly at entry coordinates.

    // Keep the editing controller in sync with the selected cell's value.
    if (selected != null) {
      final current = board.grid[selected.row][selected.col] ?? '';
      if (_editingController.text != current) {
        _editingController.text = current;
        _editingController.selection = TextSelection.fromPosition(
          TextPosition(offset: _editingController.text.length),
        );
      }
    }

    return KeyboardListener(
      focusNode: _focusNode,
      // Never attach onKeyEvent: ignore physical keyboard entirely.
      onKeyEvent: null,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
          childAspectRatio: 1,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: size * size,
        itemBuilder: (context, index) {
          final row = index ~/ size;
          final col = index % size;
          return CrosswordCell(row: row, col: col);
        },
      ),
    );
  }
}
