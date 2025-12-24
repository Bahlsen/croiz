import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'crossword_grid_area.dart';
import 'crossword_controls_area.dart';
import 'game_board_listener.dart';

class CrosswordContent extends ConsumerWidget {
  const CrosswordContent({required this.controller, Key? key})
    : super(key: key);

  final CrosswordInputController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GameBoardListener(
      controller: controller,
      child: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                const CrosswordGridArea(),
                CrosswordControlsArea(controller: controller),
              ],
            ),
            const EndGameOverlay(),
          ],
        ),
      ),
    );
}
