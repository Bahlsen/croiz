import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';

/// Area containing the crossword grid.
///
/// This widget is wrapped in [Expanded] by its parent, so it receives
/// all remaining space after controls are measured.
///
/// The grid maintains a square aspect ratio (min of width/height) and is
/// aligned to the BOTTOM of the available space. This eliminates the gap
/// between the grid and the divider/controls below.
class CrosswordGridArea extends StatelessWidget {
  const CrosswordGridArea({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Use the minimum of width and height to ensure grid fits
      final size = constraints.maxWidth < constraints.maxHeight
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

      // Align to bottom so grid is adjacent to divider (no gap)
      return Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: size,
          height: size,
          child: const CrosswordGrid(),
        ),
      );
    },
  );
}
