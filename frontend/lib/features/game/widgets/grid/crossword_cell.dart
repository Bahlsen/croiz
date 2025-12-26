import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/core/theme.dart';

// Note: default box shadows are computed from the active theme in
// `_CrosswordTheme.fromContext` so they can be theme-driven.

// Colors and borders are provided by theme extension at runtime so the
// grid follows the active theme (see AppTheme.CrosswordThemeColors).

// Small helper that centralizes mapping from Theme/extension -> visual
// primitives used by `CrosswordCell` so the rendering code remains simple.
class _CrosswordTheme {
  _CrosswordTheme({
    required this.defaultBg,
    required this.selectedWordBg,
    required this.flashingBg,
    required this.clearedFlashingBg,
    required this.defaultBorder,
    required this.selectedBorder,
    required this.selectedWordBorder,
    required this.flashingBorder,
    required this.clearedFlashingBorder,
    required this.selectedBoxShadow,
    required this.flashingBoxShadow,
    required this.clearedFlashingBoxShadow,
    required this.defaultBoxShadow,
  });

  factory _CrosswordTheme.fromContext(BuildContext context) {
    final ext =
        Theme.of(context).extension<CrosswordThemeColors>() ??
        CrosswordThemeColors.defaults;

    final defaultBg = ext.defaultBgColor;
    final selectedWordBg = ext.selectedWordBgColor;
    final flashingBg = ext.flashingBgColor;
    final clearedFlashingBg = ext.clearedFlashingBgColor;

    final defaultBorder = Border.fromBorderSide(
      BorderSide(color: ext.defaultBorderColor, width: 1),
    );
    final selectedBorder = Border.fromBorderSide(
      BorderSide(color: ext.selectedBorderColor, width: 2.5),
    );
    final selectedWordBorder = Border.fromBorderSide(
      BorderSide(color: ext.selectedWordBorderColor, width: 2),
    );
    final flashingBorder = Border.fromBorderSide(
      BorderSide(color: ext.flashingBorderColor, width: 3),
    );
    final clearedFlashingBorder = Border.fromBorderSide(
      BorderSide(color: ext.clearedFlashingBorderColor, width: 3),
    );

    final defaultBoxShadowColor = ext.defaultBoxShadowColor;
    final defaultBoxShadow = [
      BoxShadow(
        color: defaultBoxShadowColor,
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
    final selectedBoxShadow = [
      BoxShadow(
        color: ext.selectedBoxShadowColor1,
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: ext.selectedBoxShadowColor2,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
    final flashingBoxShadow = [
      BoxShadow(
        color: ext.flashingBoxShadowColor,
        blurRadius: 15,
        offset: Offset.zero,
      ),
    ];
    final clearedFlashingBoxShadow = [
      BoxShadow(
        color: ext.clearedFlashingBoxShadowColor,
        blurRadius: 16,
        offset: Offset.zero,
      ),
    ];

    return _CrosswordTheme(
      defaultBg: defaultBg,
      selectedWordBg: selectedWordBg,
      flashingBg: flashingBg,
      clearedFlashingBg: clearedFlashingBg,
      defaultBorder: defaultBorder,
      selectedBorder: selectedBorder,
      selectedWordBorder: selectedWordBorder,
      flashingBorder: flashingBorder,
      clearedFlashingBorder: clearedFlashingBorder,
      selectedBoxShadow: selectedBoxShadow,
      flashingBoxShadow: flashingBoxShadow,
      clearedFlashingBoxShadow: clearedFlashingBoxShadow,
      defaultBoxShadow: defaultBoxShadow,
    );
  }

  final Color defaultBg;
  final Color selectedWordBg;
  final Color flashingBg;
  final Color clearedFlashingBg;
  final Border defaultBorder;
  final Border selectedBorder;
  final Border selectedWordBorder;
  final Border flashingBorder;
  final Border clearedFlashingBorder;
  final List<BoxShadow> selectedBoxShadow;
  final List<BoxShadow> flashingBoxShadow;
  final List<BoxShadow> clearedFlashingBoxShadow;
  final List<BoxShadow> defaultBoxShadow;
}

/// A single crossword cell rendered in the grid.
/// Extracted for SRP: this widget only concerns rendering one cell.
class CrosswordCell extends ConsumerWidget {
  const CrosswordCell({required this.row, required this.col, Key? key})
    : super(key: key);

  final int row;
  final int col;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extForBlack =
      Theme.of(context).extension<CrosswordThemeColors>() ??
        CrosswordThemeColors.defaults;
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
      return Container(color: extForBlack.blackCellColor);
    }
    final cellKey = CellKey(row, col);
    final isFlashing = ref.watch(cellFlashingProvider(cellKey));
    final isClearedFlashing = ref.watch(cellClearedFlashingProvider(cellKey));

    // Determine if part of selected word (family provider so only cells
    // whose membership changes will rebuild).
    final isPartOfSelectedWord = ref.watch(cellInSelectedWordProvider(cellKey));

    final letter = ref.watch(cellValueProvider(cellKey));
    final cellNumber = ref.watch(clueNumbersProvider.select((m) => m[cellKey]));

    // Centralized theme mapping
    final tt = _CrosswordTheme.fromContext(context);

    List<BoxShadow> boxShadow;
    Border border;
    Color bgColor;

    if (isClearedFlashing) {
      boxShadow = tt.clearedFlashingBoxShadow;
      border = tt.clearedFlashingBorder;
      bgColor = tt.clearedFlashingBg;
    } else if (isFlashing) {
      boxShadow = tt.flashingBoxShadow;
      border = tt.flashingBorder;
      bgColor = tt.flashingBg;
    } else if (isSelected) {
      boxShadow = tt.selectedBoxShadow;
      border = tt.selectedBorder;
      bgColor = tt.selectedWordBg; // selection uses a light primary overlay
    } else if (isPartOfSelectedWord) {
      boxShadow = tt.defaultBoxShadow;
      border = tt.selectedWordBorder;
      bgColor = tt.selectedWordBg;
    } else {
      boxShadow = tt.defaultBoxShadow;
      border = tt.defaultBorder;
      bgColor = tt.defaultBg;
    }

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

  static const _letterPadding = EdgeInsets.all(2);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final numberStyle = TextStyle(
      fontSize: 7,
      color: scheme.onSurface.withAlpha((0.58 * 255).round()),
      fontWeight: FontWeight.w400,
    );
    final letterStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: scheme.onSurface,
    );
    final selectedLetterStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: scheme.onSurface,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cellNumber != null)
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 1, top: 0),
              child: Text('$cellNumber', style: numberStyle),
            ),
          ),
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: _letterPadding,
                child: Text(
                  letter ?? '',
                  style: isSelected ? selectedLetterStyle : letterStyle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
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
