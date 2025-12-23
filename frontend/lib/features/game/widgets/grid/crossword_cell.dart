import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

// Performance: cached static BoxShadows to avoid recreating objects on each build
const _kDefaultBoxShadow = [
  BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.5),
    blurRadius: 2,
    offset: Offset(0, 1),
  ),
];

const _kSelectedBoxShadow = [
  BoxShadow(
    color: Color.fromRGBO(128, 0, 128, 0.32),
    blurRadius: 10,
    offset: Offset(0, 2),
  ),
  BoxShadow(
    color: Color.fromRGBO(0, 0, 255, 0.28),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
];

const _kFlashingBoxShadow = [
  BoxShadow(
    color: Color.fromRGBO(105, 240, 174, 0.85),
    blurRadius: 15,
    offset: Offset.zero,
  ),
];

const _kClearedFlashingBoxShadow = [
  BoxShadow(
    color: Color.fromRGBO(255, 82, 82, 0.9),
    blurRadius: 16,
    offset: Offset.zero,
  ),
];

// Performance: cached colors
const _kClearedFlashingBgColor = Color.fromRGBO(255, 82, 82, 0.48);
const _kFlashingBgColor = Color.fromRGBO(105, 240, 174, 0.48);
const _kSelectedWordBgColor = Color.fromRGBO(33, 150, 243, 0.42);
const _kDefaultBgColor = Color(0xFF424242); // Colors.grey[800]
const _kSelectedBorderColor = Color.fromARGB(255, 110, 32, 124);

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
    final isFlashing = ref.watch(cellFlashingProvider(cellKey));
    final isClearedFlashing = ref.watch(cellClearedFlashingProvider(cellKey));

    // Determine if part of selected word (family provider so only cells
    // whose membership changes will rebuild).
    final isPartOfSelectedWord = ref.watch(cellInSelectedWordProvider(cellKey));

    final letter = ref.watch(cellValueProvider([row, col]));
    final cellNumber = ref.watch(
      clueNumbersProvider.select((m) => m['$row,$col']),
    );

    // Performance: use cached static BoxShadows instead of creating new lists
    final boxShadow = isClearedFlashing
        ? _kClearedFlashingBoxShadow
        : isFlashing
        ? _kFlashingBoxShadow
        : isSelected
        ? _kSelectedBoxShadow
        : _kDefaultBoxShadow;

    final borderColor = isClearedFlashing
        ? Colors.redAccent
        : isFlashing
        ? Colors.greenAccent
        : isSelected
        ? _kSelectedBorderColor
        : isPartOfSelectedWord
        ? Colors.blueAccent
        : Colors.grey.shade700;

    final borderWidth = isClearedFlashing
        ? 3.0
        : (isFlashing
              ? 3.0
              : (isSelected ? 2.5 : (isPartOfSelectedWord ? 2.0 : 1.0)));

    // Performance: use cached static colors
    final bgColor = isClearedFlashing
        ? _kClearedFlashingBgColor
        : isFlashing
        ? _kFlashingBgColor
        : isPartOfSelectedWord
        ? _kSelectedWordBgColor
        : _kDefaultBgColor;

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

  // Performance: use FractionallySizedBox and FittedBox instead of LayoutBuilder
  // This avoids per-frame constraint calculations for each cell
  @override
  Widget build(BuildContext context) => Stack(
      children: [
        if (cellNumber != null)
          Positioned(
            left: 2,
            top: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$cellNumber',
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ),
          ),
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                letter ?? '',
                style: TextStyle(
                  fontSize: isSelected ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
}
