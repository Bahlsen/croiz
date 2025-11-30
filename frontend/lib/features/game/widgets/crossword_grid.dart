import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/board_helpers.dart';

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

    // Request focus so keyboard events are received when the grid is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _editingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event, int size) {
    if (event is! KeyDownEvent) {
      return;
    }

    final sel = ref.read(selectedCellProvider);
    var row = sel?.row ?? 0;
    var col = sel?.col ?? 0;
    final blackCellsForKey = ref.read(gameBoardProvider).blackCells;
    // If the currently selected cell is disabled (black), ignore keyboard input.
    if (sel != null && blackCellsForKey.isDisabled(sel.row, sel.col)) {
      return;
    }

    final keyLabel = event.logicalKey.keyLabel;

    // Arrow keys: move to the next non-black cell in the given direction.
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final next = _findNextSelectableInDirection(row, col, 0, 1, size, ref.read(gameBoardProvider).blackCells);
      if (next != null) {
        ref.read(selectedCellProvider.notifier).state = next;
      }
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final next = _findNextSelectableInDirection(row, col, 0, -1, size, ref.read(gameBoardProvider).blackCells);
      if (next != null) {
        ref.read(selectedCellProvider.notifier).state = next;
      }
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final next = _findNextSelectableInDirection(row, col, 1, 0, size, ref.read(gameBoardProvider).blackCells);
      if (next != null) {
        ref.read(selectedCellProvider.notifier).state = next;
      }
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final next = _findNextSelectableInDirection(row, col, -1, 0, size, ref.read(gameBoardProvider).blackCells);
      if (next != null) {
        ref.read(selectedCellProvider.notifier).state = next;
      }
      return;
    }

    // Backspace / Delete clears the current cell
    if (event.logicalKey == LogicalKeyboardKey.backspace || event.logicalKey == LogicalKeyboardKey.delete) {
      ref.read(gameBoardProvider.notifier).setLetter(row, col, '');
      return;
    }

    // Character input: if single-character label (e.g., 'a', 'A', 'é' etc.)
    if (keyLabel.length == 1) {
      final char = keyLabel.toUpperCase();
        if (RegExp(r'[A-ZÀ-ÖØ-Ý]', unicode: true).hasMatch(char)) {
        ref.read(gameBoardProvider.notifier).setLetter(row, col, char);
        // move to the next cell after typing; _findNextSelectable derives step from mode
        final next = _findNextSelectable(row, col, size, ref.read(gameBoardProvider).blackCells);
        if (next != null) {
          ref.read(selectedCellProvider.notifier).state = next;
        }
      }
    }
  }

  // Return the next non-black selectable cell after (row,col).
  // Step is derived from the current `wordDirectionProvider`:
  // - vertical   => move down (row+1)
  // - horizontal => move right (col+1)
  // Arrow keys bypass this by calling `_findNextSelectableInDirection`.
  // Returns null if none in bounds.
  SelectedCell? _findNextSelectable(int row, int col, int size, List<List<bool>> black) {
    final currentDir = ref.read(wordDirectionProvider);
    final dr = (currentDir == WordDirection.vertical) ? 1 : 0;
    final dc = (currentDir == WordDirection.vertical) ? 0 : 1;
    return _findNextSelectableInDirection(row, col, dr, dc, size, black);
  }

  // Find the next selectable in an explicit direction (dr,dc). Used for arrow keys.
  SelectedCell? _findNextSelectableInDirection(int row, int col, int dr, int dc, int size, List<List<bool>> black) {
    // Use the helper in `board_helpers.dart` which supports wrapping across
    // rows/columns and handles non-rectangular grids. We enable wrap so that
    // when the linear advance hits out-of-bounds (or a run of disabled cells
    // followed by out-of-bounds), it will continue to the next row/column.
    final next = black.nextSelectableFrom(row, col, dr, dc, wrap: true);
    if (next == null) return null;
    return SelectedCell(next[0], next[1]);
  }


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
          ref.read(selectedCellProvider.notifier).state = null;
        }
      });
    }

    // compute clue numbers for display
    // Number across (horizontal) starts first (row-major), then down (vertical) starts.
    final numbers = <String, int>{};
    var count = 1;

    // First pass: assign numbers to across starts only
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (black.isDisabled(r, c)) {
          continue;
        }
        final isStartAcross = (c == 0) || black.isDisabled(r, c - 1);
        if (isStartAcross) {
          numbers['$r,$c'] = count++;
        }
      }
    }

    // Second pass: assign numbers to down starts that haven't been numbered yet
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (black.isDisabled(r, c)) {
          continue;
        }
        final isStartDown = (r == 0) || black.isDisabled(r - 1, c);
        final key = '$r,$c';
        if (isStartDown && !numbers.containsKey(key)) {
          numbers[key] = count++;
        }
      }
    }

    // Keep the editing controller in sync with the selected cell's value.
    if (selected != null) {
      final current = board.grid[selected.row][selected.col] ?? '';
      if (_editingController.text != current) {
        _editingController.text = current;
        _editingController.selection = TextSelection.fromPosition(TextPosition(offset: _editingController.text.length));
      }
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) => _handleKey(event, size),
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
          final isSelected = selected != null && selected.row == row && selected.col == col;
          final isDisabled = black.isDisabled(row, col);


          // Check if this cell is part of the selected word (horizontal or vertical)
          var isPartOfSelectedWord = false;
          if (selected != null) {
            final horizontal = wordDirection == WordDirection.horizontal;
            final bounds = black.wordBounds(selected.row, selected.col, horizontal: horizontal);
            if (horizontal) {
              isPartOfSelectedWord = row == selected.row && col >= bounds[0] && col <= bounds[1];
            } else {
              isPartOfSelectedWord = col == selected.col && row >= bounds[0] && row <= bounds[1];
            }
          }
          if (isDisabled) {
            return Container(
              color: Colors.black,
            );
          }

          final cellNumber = numbers['$row,$col'];

          return GestureDetector(
            onTap: () {
              final wasSelected = isSelected;
              // Always set the selection (might be same or new cell)
              ref.read(selectedCellProvider.notifier).state = SelectedCell(row, col);
              _focusNode.requestFocus();
              
              if (wasSelected) {
                // Second tap on same cell: toggle direction
                final newDir = wordDirection == WordDirection.horizontal 
                    ? WordDirection.vertical 
                    : WordDirection.horizontal;
                ref.read(wordDirectionProvider.notifier).state = newDir;
              } else {
                // First tap on this cell: reset direction to horizontal
                ref.read(wordDirectionProvider.notifier).state = WordDirection.horizontal;
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                // Selected cell gets a purple glow; selected-word keeps blue.
                boxShadow: isSelected
                  ? [BoxShadow(color: Colors.purple.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(0, 2))]
                  : (isPartOfSelectedWord
                    ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 2, offset: const Offset(0, 1))]),
                border: Border.all(
                  color: isSelected
                      ? Colors.purpleAccent
                      : (isPartOfSelectedWord ? Colors.blueAccent : Colors.grey.shade700),
                  width: isSelected ? 2.5 : (isPartOfSelectedWord ? 2 : 1),
                ),
                color: isPartOfSelectedWord ? Colors.blue.withValues(alpha: 0.45) : Colors.grey[800],
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
                        style: const TextStyle(fontSize: 9, color: Colors.white70),
                      ),
                    ),
                  Center(
                    child: isSelected
                        ? SizedBox(
                            width: 36,
                            child: TextField(
                              // When the TextField itself is tapped while already selected,
                              // toggle the word direction. This ensures a second tap
                              // toggles to vertical even though the TextField absorbs taps.
                              onTap: () {
                                final current = ref.read(wordDirectionProvider);
                                final newDir = current == WordDirection.horizontal
                                    ? WordDirection.vertical
                                    : WordDirection.horizontal;
                                ref.read(wordDirectionProvider.notifier).state = newDir;
                              },
                              controller: _editingController,
                              textAlign: TextAlign.center,
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 1,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(counterText: '', border: InputBorder.none, isDense: true),
                              onChanged: (value) {
                                ref.read(gameBoardProvider.notifier).setLetter(row, col, value);
                              },
                              onSubmitted: (value) {
                                // move selection in the current direction, skipping black cells
                                final next = _findNextSelectable(row, col, size, ref.read(gameBoardProvider).blackCells);
                                if (next != null) {
                                  ref.read(selectedCellProvider.notifier).state = next;
                                }
                              },
                            ),
                          )
                        : Text(
                            letter ?? '',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
