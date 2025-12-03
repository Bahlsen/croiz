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

  // Physical keyboard is disabled; input is handled by the controller.

  @override
  Widget build(BuildContext context) {
    // Use the puzzle loader provider as a stable source when gameBoard may
    // not be synchronously available (e.g., during tests). This avoids
    // swallowing errors while keeping the UI deterministic.
    final pu = ref.watch(puzzleLoaderProvider);
    final board = pu.maybeWhen(data: (d) => d, orElse: () => createEmptyBoard(5));
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

    // Clue numbering is computed in helpers and used by `CrosswordCell`.

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
