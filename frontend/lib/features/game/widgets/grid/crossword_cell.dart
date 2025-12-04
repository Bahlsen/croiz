import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/features/game/utils/clue_numbering.dart';

/// A single crossword cell rendered in the grid.
/// Extracted for SRP: this widget only concerns rendering one cell.
class CrosswordCell extends ConsumerWidget {
  const CrosswordCell({required this.row, required this.col, Key? key}) : super(key: key);

  final int row;
  final int col;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer watching the live `gameBoardProvider` so the UI updates when
    // the board changes (typing letters, clearing, etc). If watching the
    // provider throws (e.g., during early startup in tests), fall back to
    // the puzzle loader provider for a stable fallback board.
    GameBoard board;
    try {
      board = ref.watch(gameBoardProvider);
    } on Object catch (e, st) {
      developer.log('gameBoardProvider watch failed, falling back to loader', error: e, stackTrace: st);
      final pu = ref.watch(puzzleLoaderProvider);
      board = pu.maybeWhen(data: (d) => d, orElse: () => createEmptyBoard(5));
    }
    final selected = ref.watch(selectedCellProvider);
    final wordDirection = ref.watch(wordDirectionProvider);
    final black = board.blackCells;

    final cellKey = '$row,$col';
    final flashingCells = ref.watch(flashingCellsProvider);
    final clearedFlashingCells = ref.watch(flashingClearedCellsProvider);
    final lockedCells = ref.watch(lockedCellsProvider);

    final isSelected = selected != null && selected.row == row && selected.col == col;
    final isDisabled = black.isDisabled(row, col);
    final isFlashing = flashingCells.contains(cellKey);
    final isClearedFlashing = clearedFlashingCells.contains(cellKey);
    final isLocked = lockedCells.contains(cellKey);

    // Determine if part of selected word
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
      return Container(color: Colors.black);
    }

    final letter = board.grid[row][col];
    final numbers = ClueNumbering.numbersFromBoard(board);
    final cellNumber = numbers[cellKey];

    // Visuals: compute decoration pieces
    final boxShadow = isClearedFlashing
        ? [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.9), blurRadius: 16, offset: Offset.zero)]
        : isFlashing
            ? [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.85), blurRadius: 15, offset: Offset.zero)]
            : isSelected
                ? [BoxShadow(color: Colors.purple.withValues(alpha: 0.32), blurRadius: 10, offset: const Offset(0, 2))]
                : isPartOfSelectedWord
                    ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.28), blurRadius: 8, offset: const Offset(0, 2))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 2, offset: const Offset(0, 1))];

    final borderColor = isClearedFlashing
        ? Colors.redAccent
        : isFlashing
            ? Colors.greenAccent
            : isLocked
                ? Colors.green.shade700
                : isSelected
                    ? Colors.purpleAccent
                    : isPartOfSelectedWord
                        ? Colors.blueAccent
                        : Colors.grey.shade700;

    final borderWidth = isClearedFlashing ? 3.0 : (isFlashing ? 3.0 : (isLocked ? 2.0 : (isSelected ? 2.5 : (isPartOfSelectedWord ? 2.0 : 1.0))));

    final bgColor = isClearedFlashing
        ? Colors.redAccent.withValues(alpha: 0.48)
        : isFlashing
            ? Colors.greenAccent.withValues(alpha: 0.48)
            : isLocked
                ? Colors.green.withValues(alpha: 0.28)
                : isPartOfSelectedWord
                    ? Colors.blue.withValues(alpha: 0.42)
                    : Colors.grey[800]!;

    return GestureDetector(
      onTap: () {
        final wasSelected = isSelected;
        ref.read(selectedCellProvider.notifier).value = SelectedCell(row, col);
        if (wasSelected) {
          final newDir = wordDirection == WordDirection.horizontal ? WordDirection.vertical : WordDirection.horizontal;
          ref.read(wordDirectionProvider.notifier).value = newDir;
        } else {
          ref.read(wordDirectionProvider.notifier).value = WordDirection.horizontal;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: boxShadow,
          border: Border.all(color: borderColor, width: borderWidth),
          color: bgColor,
        ),
        child: Stack(children: [
          if (cellNumber != null)
            Positioned(left: 4, top: 2, child: Text('$cellNumber', style: const TextStyle(fontSize: 9, color: Colors.white70))),
          Center(child: Text(letter ?? '', style: TextStyle(fontSize: isSelected ? 20 : 16, fontWeight: FontWeight.bold, color: Colors.white))),
        ]),
      ),
    );
  }
}
