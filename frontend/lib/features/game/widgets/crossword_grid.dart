import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/features/game/utils/clue_numbering.dart';

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
    final wordDirection = ref.watch(wordDirectionProvider);
    final black = board.blackCells;

    // If selection somehow points to a disabled cell (from older state), clear it.
    if (selected != null && black.isDisabled(selected.row, selected.col)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(selectedCellProvider.notifier).value = null;
        }
      });
    }

    // Compute clue numbers using utility for SRP.
    final numbers = ClueNumbering.numbersFromBoard(board);
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
          final letter = board.grid[row][col];
          final isSelected =
              selected != null && selected.row == row && selected.col == col;
          final isDisabled = black.isDisabled(row, col);

          // Check if this cell is flashing (word just completed)
          final flashingCells = ref.watch(flashingCellsProvider);
          // Check if this cell is flashing because it was cleared (red flash)
          final clearedFlashingCells = ref.watch(flashingClearedCellsProvider);
          final cellKey = '$row,$col';
          final isFlashing = flashingCells.contains(cellKey);
          final isClearedFlashing = clearedFlashingCells.contains(cellKey);

          // Check if this cell is locked (part of a found word)
          final lockedCells = ref.watch(lockedCellsProvider);
          final isLocked = lockedCells.contains(cellKey);

          // Check if this cell is part of the selected word (horizontal or vertical)
          var isPartOfSelectedWord = false;
          if (selected != null) {
            final horizontal = wordDirection == WordDirection.horizontal;
            final bounds = black.wordBounds(
              selected.row,
              selected.col,
              horizontal: horizontal,
            );
            if (horizontal) {
              isPartOfSelectedWord =
                  row == selected.row && col >= bounds[0] && col <= bounds[1];
            } else {
              isPartOfSelectedWord =
                  col == selected.col && row >= bounds[0] && row <= bounds[1];
            }
          }
          if (isDisabled) {
            return Container(color: Colors.black);
          }

          final cellNumber = numbers['$row,$col'];

          return GestureDetector(
              onTap: () {
              final wasSelected = isSelected;
              // Always set the selection (might be same or new cell)
              ref.read(selectedCellProvider.notifier).value = SelectedCell(row, col);
              // Do not request focus — never enable physical keyboard input.

              if (wasSelected) {
                // Second tap on same cell: toggle direction
                final newDir = wordDirection == WordDirection.horizontal
                    ? WordDirection.vertical
                    : WordDirection.horizontal;
                ref.read(wordDirectionProvider.notifier).value = newDir;
              } else {
                // First tap on this cell: reset direction to horizontal
                ref.read(wordDirectionProvider.notifier).value = WordDirection.horizontal;
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                // Flashing cell gets a gold/green glow for success; cleared cells flash red
                boxShadow: isClearedFlashing
                    ? [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.85),
                          blurRadius: 15,
                          offset: Offset.zero,
                        ),
                      ]
                    : (isFlashing
                        ? [
                            BoxShadow(
                              color: Colors.greenAccent.withValues(alpha: 0.8),
                              blurRadius: 15,
                              offset: Offset.zero,
                            ),
                          ]
                        : (isSelected
                        ? [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : (isPartOfSelectedWord
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ])),
                border: Border.all(
                  color: isClearedFlashing
                    ? Colors.redAccent
                    : (isFlashing
                      ? Colors.greenAccent
                      : (isLocked
                        ? Colors.green.shade700
                        : (isSelected
                          ? Colors.purpleAccent
                          : (isPartOfSelectedWord
                            ? Colors.blueAccent
                            : Colors.grey.shade700)))),
                  width: isClearedFlashing
                    ? 3
                    : (isFlashing
                      ? 3
                      : (isLocked
                        ? 2
                        : (isSelected
                          ? 2.5
                          : (isPartOfSelectedWord ? 2 : 1)))),
                ),
                color: isClearedFlashing
                  ? Colors.redAccent.withValues(alpha: 0.5)
                  : (isFlashing
                    ? Colors.greenAccent.withValues(alpha: 0.5)
                    : (isLocked
                      ? Colors.green.withValues(alpha: 0.3)
                      : (isPartOfSelectedWord
                        ? Colors.blue.withValues(alpha: 0.45)
                        : Colors.grey[800]))),
              ),
              child: Stack(
                children: [
                  // clue number in top-left
                  if (cellNumber != null)
                    Positioned(
                      left: 4,
                      top: 2,
                      child: Text(
                        '$cellNumber',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  Center(
                    child: Text(
                      letter ?? '',
                      style: TextStyle(
                        fontSize: isSelected ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
