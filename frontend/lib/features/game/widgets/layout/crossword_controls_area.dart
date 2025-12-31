import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/core/responsive/responsive.dart';

class CrosswordControlsArea extends StatelessWidget {
  const CrosswordControlsArea({required this.controller, super.key});

  final CrosswordInputController controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).padding.bottom + 6.h,
    ),
    child: CrosswordControlsBar(
      onKey: controller.setLetterAndAdvance,
      onBackspace: controller.clearCurrent,
    ),
  );
}
