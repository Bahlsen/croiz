import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/helpers/board_helpers.dart';
// clue_numbering is used by `CrosswordCell` instead; avoid direct import here.
import 'package:croiz/features/game/widgets/grid/crossword_cell.dart';

class CrosswordGrid extends ConsumerStatefulWidget {
  const CrosswordGrid({super.key});

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
    // Performance: only watch gridSize and blackCells structure, not full board.
    // Individual cells watch their own values via cellValueProvider.
    int size;
    List<List<bool>> black;
    try {
      size = ref.watch(gameBoardProvider.select((b) => b.gridSize));
      black = ref.watch(gameBoardProvider.select((b) => b.blackCells));
    } on Object catch (_) {
      return const SizedBox.shrink();
    }
    final selected = ref.watch(selectedCellProvider);

    // If selection somehow points to a disabled cell (from older state), clear it.
    if (selected != null && black.isDisabled(selected.row, selected.col)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(selectedCellProvider.notifier).select(null);
        }
      });
    }

    // Clue numbering is computed in helpers and used by `CrosswordCell`.

    // Keep the editing controller in sync with the selected cell's value.
    if (selected != null) {
      final current =
          ref.read(gameBoardProvider).grid[selected.row][selected.col] ?? '';
      if (_editingController.text != current) {
        _editingController.text = current;
        _editingController.selection = TextSelection.fromPosition(
          TextPosition(offset: _editingController.text.length),
        );
      }
    }

    // Performance: cache gridDelegate to avoid recreation
    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: size,
      childAspectRatio: 1,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    );

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
        // Performance: add cache extent to keep cells alive and reduce rebuilds
        cacheExtent: 200,
        // Performance: use addAutomaticKeepAlives for smoother interactions
        addAutomaticKeepAlives: true,
        gridDelegate: gridDelegate,
        itemCount: size * size,
        itemBuilder: (context, index) {
          final row = index ~/ size;
          final col = index % size;
          // Performance: wrap each cell in RepaintBoundary to isolate repaints
          return RepaintBoundary(child: CrosswordCell(row: row, col: col));
        },
      ),
    );
  }
}
