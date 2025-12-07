import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 'dart:math' not needed in this file after layout changes
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
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
    // Hide system UI (navigation buttons) for full-screen gameplay.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  @override
  void dispose() {
    // Restore system UI when leaving the screen.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT DESIGN NOTE:
    // The controls area (the widget `CrosswordControlsBar`) MUST take the
    // remaining vertical space available after the grid is laid out. This
    // is intentional and critical for usability:
    // - the grid should size itself (loose/flexible) according to its
    //   content and available width, NOT by forcing or calculating the
    //   controls height.
    // - the controls must then expand to fill the remainder of the
    //   screen so the keyboard and icons are always usable and not
    //   overlapped by the grid or system UI.
    // Implementation rule: use `Flexible(fit: FlexFit.loose)` for the
    // grid and `Expanded` for the controls (see below). Avoid computing
    // explicit pixel heights in the screen — sizing should be driven by
    // parent constraints and simple Expanded/Flexible layout.

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
    // Determine grid size so we can weight available vertical space
    // between grid and controls dynamically. The grid provider always
    // returns a board (fallback empty), so this is synchronous.
    final board = ref.watch(gameBoardProvider);
    // We no longer use gridSize for explicit calculations here; keep
    // it available for future logic if needed.
    final gridSize = board.gridSize.clamp(3, 12);
    if (kDebugMode) {
      debugPrint('CrosswordScreen gridSize=$gridSize');
    }
    // Use a simple fraction-based allocation: controls get a percentage
    // of the body height based on grid size (smaller grid → larger controls).
    // This keeps the calculation predictable and avoids the grid starving the controls.

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Crossword'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 0),
                    child: Container(
                      color: Colors.black,
                      child: const CrosswordGrid(),
                    ),
                  ),
                ),

                // Controls always take the remaining space.
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: CrosswordControlsBar(
                          onKey: _controller.setLetterAndAdvance,
                          onBackspace: _controller.clearCurrent,
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
    ));
  }
}

// Clue banner moved to dedicated widget file.
