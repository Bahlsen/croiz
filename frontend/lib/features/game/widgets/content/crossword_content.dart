import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/widgets/layout/crossword_grid_area.dart';
import 'package:croiz/features/game/widgets/layout/crossword_controls_area.dart';
import 'package:croiz/features/game/listeners/game_board_observer.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';

/// Main content layout for the crossword game.
///
/// Layout strategy following Flutter's constraint system:
/// - Controls (with intrinsic sizing) are measured FIRST
/// - The grid (Expanded) takes all remaining space
/// - Grid centers itself and maintains square aspect ratio
/// - This ensures no overlap: "Constraints go down. Sizes go up."
///
/// Structure:
/// ```
/// Column
/// ├── Expanded (CrosswordGridArea) - takes remaining space, grid centered
/// ├── Divider - fixed 1px
/// └── CrosswordControlsArea - intrinsic height (clue + keyboard)
/// ```
class CrosswordContent extends ConsumerWidget {
  const CrosswordContent({required this.controller, super.key});

  final CrosswordInputController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GameBoardObserver(
    controller: controller,
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (kDebugMode) {
          debugPrint(
            'CrosswordContent constraints: '
            'w=${constraints.maxWidth.toStringAsFixed(0)} '
            'h=${constraints.maxHeight.toStringAsFixed(0)}',
          );
        }
        return Stack(
          children: [
            Column(
              children: [
                // Grid takes ALL remaining space after controls are measured.
                const Expanded(
                  child: CrosswordGridArea(),
                ),
                // Spacing between grid and controls
                const SizedBox(height: 8),
                // Simple divider - fixed height
                const Divider(height: 1, thickness: 0.5),
                // Spacing after divider
                const SizedBox(height: 8),
                // Controls area with intrinsic height.
                // This is measured FIRST, then grid gets the rest.
                CrosswordControlsArea(controller: controller),
              ],
            ),
            const Positioned.fill(child: EndGameOverlay()),
          ],
        );
      },
    ),
  );
}
