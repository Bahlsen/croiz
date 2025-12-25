import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';

class CrosswordControlsArea extends StatelessWidget {
  const CrosswordControlsArea({required this.controller, Key? key})
    : super(key: key);

  final CrosswordInputController controller;

  @override
  Widget build(BuildContext context) => Expanded(
        child: CrosswordControlsBar(
          onKey: controller.setLetterAndAdvance,
          onBackspace: controller.clearCurrent,
        ),
      );
}
