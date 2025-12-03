import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/crossword_grid.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/widgets/crossword_keyboard_bar.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_timer_provider.dart';

class CrosswordScreen extends ConsumerStatefulWidget {
  const CrosswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends ConsumerState<CrosswordScreen> {
  late final CrosswordInputController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CrosswordInputController(ref);
    // Try once after the first frame in case data already exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.tryAutoSelectFirstAcross(ref.read(gameBoardProvider));
      // Ensure timer is started (will restore if already started)
      try {
        final board = ref.read(gameBoardProvider);
        ref.read(gameTimerProvider(board.id)).start();
      } on Object catch (_) {}
    });
  }

  // Input and navigation logic moved to CrosswordInputController

  

  // Enter no longer toggles direction; kept for potential future use.

  

  


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // One-time microtask to catch late-loaded entries (compatible with tests)
    Future.microtask(() {
      _controller.tryAutoSelectFirstAcross(ref.read(gameBoardProvider));
    });
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
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    color: Colors.black,
                    child: const CrosswordGrid(),
                  ),
                ),
              ),
              CrosswordKeyboardBar(
                onKey: _controller.setLetterAndAdvance,
                onBackspace: _controller.clearCurrent,
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
