import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

/// A single crossword cell rendered in the grid.
/// Extracted for SRP: this widget only concerns rendering one cell.
class CrosswordCell extends ConsumerWidget {
  const CrosswordCell({required this.row, required this.col, Key? key})
    : super(key: key);

  final int row;
  final int col;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Narrow watches to only what this cell needs.
    final isSelected = ref.watch(
      selectedCellProvider.select(
        (s) => s != null && s.row == row && s.col == col,
      ),
    );
    final wordDirection = ref.watch(wordDirectionProvider);
    final isBlack = ref.watch(
      gameBoardProvider.select((b) => b.blackCells[row][col]),
    );
    if (isBlack) {
      return Container(color: Colors.black);
    }
    final cellKey = CellKey(row, col);
    final flashingCells = ref.watch(flashingCellsProvider);
    final clearedFlashingCells = ref.watch(flashingClearedCellsProvider);
    final selectedWordCells = ref.watch(selectedWordCellsProvider);
    final isFlashing = flashingCells.contains(cellKey);
    final isClearedFlashing = clearedFlashingCells.contains('$row,$col');

    // Determine if part of selected word
    final isPartOfSelectedWord = selectedWordCells.contains(cellKey);

    final letter = ref.watch(cellValueProvider([row, col]));
    final cellNumber = ref.watch(
      clueNumbersProvider.select((m) => m['$row,$col']),
    );

    // Visuals: compute decoration pieces
    final boxShadow = isClearedFlashing
        ? [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.9),
              blurRadius: 16,
              offset: Offset.zero,
            ),
          ]
        : isFlashing
        ? [
            BoxShadow(
              color: Colors.greenAccent.withValues(alpha: 0.85),
              blurRadius: 15,
              offset: Offset.zero,
            ),
          ]
        : isSelected
        ? [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.32),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.28),
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
          ];

    final borderColor = isClearedFlashing
        ? Colors.redAccent
        : isFlashing
        ? Colors.greenAccent
        : isSelected
        ? const Color.fromARGB(255, 110, 32, 124)
        : isPartOfSelectedWord
        ? Colors.blueAccent
        : Colors.grey.shade700;

    final borderWidth = isClearedFlashing
        ? 3.0
        : (isFlashing
              ? 3.0
              : (isSelected ? 2.5 : (isPartOfSelectedWord ? 2.0 : 1.0)));

    final bgColor = isClearedFlashing
        ? Colors.redAccent.withValues(alpha: 0.48)
        : isFlashing
        ? Colors.greenAccent.withValues(alpha: 0.48)
        : isPartOfSelectedWord
        ? Colors.blue.withValues(alpha: 0.42)
        : Colors.grey[800]!;

    final animate =
        isSelected || isPartOfSelectedWord || isFlashing || isClearedFlashing;
    final animDuration = animate
        ? const Duration(milliseconds: 150)
        : Duration.zero;

    return GestureDetector(
      onTap: () {
        final wasSelected = isSelected;
        // Preserve the current word direction when selecting a different cell.
        // Only toggle direction when the user taps the already-selected cell.
        ref.read(selectedCellProvider.notifier).value = SelectedCell(row, col);
        if (wasSelected) {
          final newDir = wordDirection == WordDirection.horizontal
              ? WordDirection.vertical
              : WordDirection.horizontal;
          ref.read(wordDirectionProvider.notifier).value = newDir;
        }
      },
      child: AnimatedContainer(
        duration: animDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero,
          boxShadow: boxShadow,
          border: Border.all(color: borderColor, width: borderWidth),
          color: bgColor,
        ),
        child: _CellContent(
          cellNumber: cellNumber,
          letter: letter,
          isSelected: isSelected,
        ),
      ),
    );
  }
}

class _CellContent extends StatelessWidget {
  const _CellContent({
    required this.cellNumber,
    required this.letter,
    required this.isSelected,
  });
  final int? cellNumber;
  final String? letter;
  final bool isSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cellW = constraints.maxWidth;
      final cellH = constraints.maxHeight;
      final numberFont = (cellW * 0.22).clamp(6.0, 12.0);
      final numberLeft = (cellW * 0.07).clamp(2.0, 8.0);
      final numberTop = (cellH * 0.05).clamp(1.0, 6.0);
      final letterFont = (isSelected ? cellW * 0.6 : cellW * 0.5).clamp(
        10.0,
        28.0,
      );
      return Stack(
        children: [
          if (cellNumber != null)
            Positioned(
              left: numberLeft,
              top: numberTop,
              child: Text(
                '$cellNumber',
                style: TextStyle(fontSize: numberFont, color: Colors.white70),
              ),
            ),
          Center(
            child: Text(
              letter ?? '',
              style: TextStyle(
                fontSize: letterFont,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    },
  );
}
