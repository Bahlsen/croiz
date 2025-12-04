import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_keyboard_bar.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_timer_provider.dart';
import 'package:croiz/domain/entities/game_entities.dart';

class CrosswordScreen extends ConsumerStatefulWidget {
  const CrosswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends ConsumerState<CrosswordScreen> {
  late final CrosswordInputController _controller;
  bool _boardListenerAttached = false;

  @override
  void initState() {
    super.initState();
    _controller = CrosswordInputController(ref);
    // Controller created here; provider listeners are attached in build().
  }

  // Input and navigation logic moved to CrosswordInputController

  

  // Enter no longer toggles direction; kept for potential future use.

  

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Attach listener once during build (required by Riverpod). It will
    // react to the board becoming available and start the timer.
    if (!_boardListenerAttached) {
      _boardListenerAttached = true;
      ref.listen<GameBoard?>(gameBoardProvider, (previous, next) {
        if (next == null) {
          return;
        }
        try {
          _controller.tryAutoSelectFirstAcross(next);
        } on Object catch (e, st) {
          debugPrint('Error auto-selecting first across: $e\n$st');
        }

        try {
          ref.read(gameTimerProvider(next.id)).start();
        } on Object catch (e, st) {
          debugPrint('Error starting game timer: $e\n$st');
        }
      });

      // Do not force immediate auto-select here; the listener above will
      // react to changes and perform auto-selection when appropriate.
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Crossword'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 2, // Give more space to grid
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    color: Colors.black,
                    child: const CrosswordGrid(),
                  ),
                ),
              ),
              Flexible(
                flex: 1, // Keyboard takes proportional space
                child: CrosswordKeyboardBar(
                  onKey: _controller.setLetterAndAdvance,
                  onBackspace: _controller.clearCurrent,
                ),
              ),
            ],
          ),
          const EndGameOverlay(),
        ],
      ),
    );
  }
}

// Clue banner moved to dedicated widget file.
