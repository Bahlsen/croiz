import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';

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

    final keyLabel = event.logicalKey.keyLabel;

    // Arrow keys
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      col = (col + 1).clamp(0, size - 1);
      ref.read(selectedCellProvider.notifier).state = SelectedCell(row, col);
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      col = (col - 1).clamp(0, size - 1);
      ref.read(selectedCellProvider.notifier).state = SelectedCell(row, col);
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      row = (row + 1).clamp(0, size - 1);
      ref.read(selectedCellProvider.notifier).state = SelectedCell(row, col);
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      row = (row - 1).clamp(0, size - 1);
      ref.read(selectedCellProvider.notifier).state = SelectedCell(row, col);
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
        // move right after typing
        col = (col + 1) % size;
        if (col == 0) {
          row = (row + 1).clamp(0, size - 1);
        }
        ref.read(selectedCellProvider.notifier).state = SelectedCell(row, col);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(gameBoardProvider);
    final size = board.gridSize;
    final selected = ref.watch(selectedCellProvider);
    final wordDirection = ref.watch(wordDirectionProvider);
    final black = board.blackCells;

    // compute clue numbers for display
    final numbers = <String, int>{};
    var count = 1;
    for (var r = 0; r < size; r++) {
        for (var c = 0; c < size; c++) {
        if (black[r][c]) {
          continue;
        }
        final isStartAcross = (c == 0) || black[r][c - 1];
        final isStartDown = (r == 0) || black[r - 1][c];
        if (isStartAcross || isStartDown) {
          numbers['$r,$c'] = count++;
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
          final isBlack = black[row][col];


          // Check if this cell is part of the selected word (horizontal or vertical)
          var isPartOfSelectedWord = false;
          if (selected != null) {
            if (wordDirection == WordDirection.horizontal) {
              isPartOfSelectedWord = (row == selected.row);
            } else {
              isPartOfSelectedWord = (col == selected.col);
            }
          }
          if (isBlack) {
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
                boxShadow: isPartOfSelectedWord
                    ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 2, offset: const Offset(0, 1))],
                border: Border.all(
                  color: isPartOfSelectedWord ? Colors.blueAccent : Colors.grey.shade700,
                  width: isPartOfSelectedWord ? 2 : 1,
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
                                // move selection in the current direction
                                var newRow = row;
                                var newCol = col;
                                if (wordDirection == WordDirection.horizontal) {
                                  newCol = (col + 1) % size;
                                  if (newCol == 0) {
                                    newRow = (row + 1).clamp(0, size - 1);
                                  }
                                } else {
                                  newRow = (row + 1) % size;
                                  if (newRow == 0) {
                                    newCol = (col + 1).clamp(0, size - 1);
                                  }
                                }
                                ref.read(selectedCellProvider.notifier).state = SelectedCell(newRow, newCol);
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
