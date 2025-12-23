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

// Performance: cached colors and borders
const _kClearedFlashingBgColor = Color.fromRGBO(255, 82, 82, 0.48);
const _kFlashingBgColor = Color.fromRGBO(105, 240, 174, 0.48);
const _kSelectedWordBgColor = Color.fromRGBO(33, 150, 243, 0.42);
const _kDefaultBgColor = Color(0xFF424242); // Colors.grey[800]
const _kSelectedBorderColor = Color.fromARGB(255, 110, 32, 124);
const _kDefaultBorderColor = Color(0xFF616161); // Colors.grey.shade700

// Performance: cached border instances
const _kClearedFlashingBorder = Border.fromBorderSide(
  BorderSide(color: Colors.redAccent, width: 3),
);
const _kFlashingBorder = Border.fromBorderSide(
  BorderSide(color: Colors.greenAccent, width: 3),
);
const _kSelectedBorder = Border.fromBorderSide(
  BorderSide(color: _kSelectedBorderColor, width: 2.5),
);
const _kSelectedWordBorder = Border.fromBorderSide(
  BorderSide(color: Colors.blueAccent, width: 2),
);
const _kDefaultBorder = Border.fromBorderSide(
  BorderSide(color: _kDefaultBorderColor, width: 1),
);

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
    // Only watch wordDirection if cell is selected (needed for direction toggle).
    // Other cells get direction from cellInSelectedWordProvider which already
    // incorporates direction changes.
    final wordDirection = isSelected ? ref.watch(wordDirectionProvider) : null;
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

    final letter = ref.watch(cellValueProvider(cellKey));
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

    // Performance: use cached static borders instead of Border.all()
    final border = isClearedFlashing
        ? _kClearedFlashingBorder
        : isFlashing
        ? _kFlashingBorder
        : isSelected
        ? _kSelectedBorder
        : isPartOfSelectedWord
        ? _kSelectedWordBorder
        : _kDefaultBorder;

    // Performance: use cached static colors
    final bgColor = isClearedFlashing
        ? _kClearedFlashingBgColor
        : isFlashing
        ? _kFlashingBgColor
        : isPartOfSelectedWord
        ? _kSelectedWordBgColor
        : _kDefaultBgColor;

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.zero,
      boxShadow: boxShadow,
      border: border,
      color: bgColor,
    );

    final content = _CellContent(
      cellNumber: cellNumber,
      letter: letter,
      isSelected: isSelected,
    );

    // Accessibility: semantic label for screen readers
    final semanticLabel = _buildSemanticLabel(
      row: row,
      col: col,
      letter: letter,
      cellNumber: cellNumber,
      isSelected: isSelected,
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () {
          final wasSelected = isSelected;
          // Preserve the current word direction when selecting a different cell.
          // Only toggle direction when the user taps the already-selected cell.
          ref.read(selectedCellProvider.notifier).value = SelectedCell(
            row,
            col,
          );
          if (wasSelected) {
            // wordDirection is non-null when isSelected is true
            final currentDir = wordDirection!;
            final newDir = currentDir == WordDirection.horizontal
                ? WordDirection.vertical
                : WordDirection.horizontal;
            ref.read(wordDirectionProvider.notifier).value = newDir;
          }
        },
        // Performance: use plain Container for instant visual feedback.
        // AnimatedContainer causes perceived delay on touch.
        child: Container(decoration: decoration, child: content),
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

  // Performance: cached TextStyles to avoid recreation on each build
  static const _numberTextStyle = TextStyle(
    fontSize: 7,
    color: Colors.white38,
    fontWeight: FontWeight.w400,
  );
  static const _letterTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static const _selectedLetterTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static const _letterPadding = EdgeInsets.all(2);

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      if (cellNumber != null)
        Positioned(
          left: 1,
          top: 0,
          child: Text('$cellNumber', style: _numberTextStyle),
        ),
      Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: _letterPadding,
            child: Text(
              letter ?? '',
              style: isSelected ? _selectedLetterTextStyle : _letterTextStyle,
            ),
          ),
        ),
      ),
    ],
  );
}

/// Builds an accessibility label for screen readers.
String _buildSemanticLabel({
  required int row,
  required int col,
  required String? letter,
  required int? cellNumber,
  required bool isSelected,
}) {
  final buffer = StringBuffer()
    ..write('Cell row ${row + 1}, column ${col + 1}');
  if (cellNumber != null) {
    buffer.write(', number $cellNumber');
  }
  if (letter != null && letter.isNotEmpty) {
    buffer.write(', letter $letter');
  } else {
    buffer.write(', empty');
  }
  if (isSelected) {
    buffer.write(', selected');
  }
  return buffer.toString();
}
