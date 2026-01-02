import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';

/// Area containing the crossword grid.
///
/// This widget is wrapped in [Expanded] by its parent, so it receives
/// all remaining space after controls are measured.
///
/// The grid maintains a square aspect ratio (min of width/height) and is
/// aligned to the TOP of the available space to eliminate the gap
/// between the top of the screen and the grid.
class CrosswordGridArea extends StatelessWidget {
  const CrosswordGridArea({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Use the minimum of width and height to ensure grid fits
      final size =
          constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;

      if (kDebugMode) {
        debugPrint(
          'CrosswordGridArea: '
          'constraints w=${constraints.maxWidth.toStringAsFixed(0)} '
          'h=${constraints.maxHeight.toStringAsFixed(0)} '
          '-> grid size=${size.toStringAsFixed(0)}',
        );
      }

      // Align to top so grid is adjacent to the top of the screen (no gap)
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: size,
          height: size,
          child: const CrosswordGrid(),
        ),
      );
    },
  );
}
