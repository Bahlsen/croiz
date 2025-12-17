import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/board_helpers.dart';
// clue_numbering is used by `CrosswordCell` instead; avoid direct import here.
import 'package:croiz/features/game/widgets/grid/crossword_cell.dart';

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
    // Read the active board. If the board isn't available (still loading
    // or errored), bail out gracefully by rendering nothing — the
    // top-level screen is responsible for showing loading/error UI.
    GameBoard board;
    try {
      board = ref.watch(gameBoardProvider);
    } on Object catch (_) {
      return const SizedBox.shrink();
    }
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
        // The grid should not be scrollable: parent controls available
        // space and the controls bar will take remaining area. Use
        // NeverScrollableScrollPhysics so the grid lays out to its
        // parent's constraints instead of enabling scrolling.
        physics: const NeverScrollableScrollPhysics(),
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
