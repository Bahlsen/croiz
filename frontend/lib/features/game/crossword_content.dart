import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';

class CrosswordContent extends ConsumerWidget {

  const CrosswordContent({required this.controller, Key? key})
    : super(key: key);
  final CrosswordInputController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
      bottom: true,
      top: false,
      child: Stack(
        children: [
          Column(
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 12,
                    bottom: 0,
                  ),
                  child: Container(
                    color: Colors.black,
                    child: const CrosswordGrid(),
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: CrosswordControlsBar(
                        onKey: controller.setLetterAndAdvance,
                        onBackspace: controller.clearCurrent,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),

          const EndGameOverlay(),
        ],
      ),
    );
}
