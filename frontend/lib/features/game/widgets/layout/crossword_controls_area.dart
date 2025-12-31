import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';

/// Area containing the game controls (clue banner and virtual keyboard).
///
/// This widget has intrinsic height - it sizes itself based on its content.
/// The parent Column measures this first, then gives remaining space to the
/// grid (which uses Expanded).
///
/// Uses [mainAxisSize: MainAxisSize.min] to only take necessary space.
class CrosswordControlsArea extends StatelessWidget {
  const CrosswordControlsArea({
    required this.controller,
    super.key,
  });

  final CrosswordInputController controller;

  @override
  Widget build(BuildContext context) => Padding(
      // Safe area padding at bottom for system navigation bar
      padding: const EdgeInsets.only(bottom: 45),
      child: CrosswordControlsBar(
        onKey: controller.setLetterAndAdvance,
        onBackspace: controller.clearCurrent,
      ),
    );
}
