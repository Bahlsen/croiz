// ignore_for_file: sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_timer_provider.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/game_providers.dart';

class CrosswordScreen extends ConsumerStatefulWidget {
  final String? puzzleId;

  const CrosswordScreen({Key? key, this.puzzleId}) : super(key: key);

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
    // If a puzzle id is provided (via route query), attempt to load it and
    // set the selected puzzle id so the loader provider will load it.
    if (widget.puzzleId != null) {
      final decoded = Uri.decodeComponent(widget.puzzleId!);
      // Delay setting the provider until after the widget tree has
      // finished building to avoid Riverpod runtime errors.
      Future.microtask(() {
        try {
          final current = ref.read(selectedPuzzleIdProvider);
          if (current != decoded) {
            ref.read(selectedPuzzleIdProvider.notifier).value = decoded;
          }
        } on Object catch (e, st) {
          if (kDebugMode) {
            debugPrint('Failed to set selected puzzle id: $e\n$st');
          }
        }
      });
    }
    // Hide system UI (navigation buttons) for full-screen gameplay.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  // Note: loading is handled by `puzzleLoaderProvider` which watches
  // `selectedPuzzleIdProvider`. The GameBoardNotifier listens to the
  // loader and updates the active board accordingly.

  @override
  void dispose() {
    // Restore system UI when leaving the screen.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    try {
      _controller.dispose();
    } on Object {
      // ignore
    }
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

    // NOTE: do not attach the game board listener until after we have
    // checked the loader state below. Attaching it earlier forces the
    // `gameBoardProvider` to build while the puzzle loader may still be
    // loading, which can synchronously throw. We'll attach the listener
    // after confirming the loader is not loading or errored.
    // Watch the loader provider first so we can display loading/error
    // UI before attempting to read the active board (which may throw
    // if the loader is in an error state).
    final puzzleAsync = ref.watch(puzzleLoaderProvider);

    // If the loader is still loading, show a centered spinner instead of
    // the default board UI.
    if (puzzleAsync is AsyncLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Crossword'),
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Puzzles',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/puzzles'),
          ),
        ),
        body: const SafeArea(
          bottom: true,
          top: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Chargement du puzzle...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Patientez un instant',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If the loader errored, display a clear error containing the selected id.
    if (puzzleAsync is AsyncError) {
      final selected = ref.read(selectedPuzzleIdProvider) ?? '<null>';
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Crossword'),
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Puzzles',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/puzzles'),
          ),
        ),
        body: SafeArea(
          bottom: true,
          top: false,
          child: Center(
            child: Text(
              'Erreur au chargement du puzzle id="$selected"',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Determine grid size so we can weight available vertical space
    // between grid and controls dynamically. The board provider now
    // can be read safely because the loader isn't loading or errored.
    // Safe to attach/listen now: loader isn't loading or errored.
    if (!_boardListenerAttached) {
      _boardListenerAttached = true;
      ref.listen<GameBoard>(gameBoardProvider, (
        GameBoard? previous,
        GameBoard next,
      ) {
        try {
          _controller.tryAutoSelectFirstAcross(next);
        } on Object catch (e, st) {
          if (kDebugMode) {
            debugPrint('Error auto-selecting first across: $e\n$st');
          }
        }

        try {
          ref.read(gameTimerProvider(next.id)).start();
        } on Object catch (e, st) {
          if (kDebugMode) {
            debugPrint('Error starting game timer: $e\n$st');
          }
        }
      });

      // Also perform an immediate auto-select/start on the current board
      // since `ref.listen` may not fire synchronously in this environment.
      // Defer modifications to providers until after build to avoid
      // Riverpod runtime errors about modifying providers during widget
      // lifecycle methods.
      Future.microtask(() {
        try {
          final current = ref.read(gameBoardProvider);
          _controller.tryAutoSelectFirstAcross(current);
        } on Object catch (e, st) {
          if (kDebugMode) {
            debugPrint('Error auto-selecting first across (initial): $e\n$st');
          }
        }
        try {
          final current = ref.read(gameBoardProvider);
          ref.read(gameTimerProvider(current.id)).start();
        } on Object catch (e, st) {
          if (kDebugMode) {
            debugPrint('Error starting game timer (initial): $e\n$st');
          }
        }
      });
    }

    // Performance: only watch gridSize, not the entire board which changes
    // on every keystroke. This prevents unnecessary rebuilds.
    final gridSize = ref
        .watch(gameBoardProvider.select((b) => b.gridSize))
        .clamp(3, 12);
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
        leading: IconButton(
          tooltip: 'Puzzles',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/puzzles'),
        ),
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
      ),
    );
  }
}

// Clue banner moved to dedicated widget file.
// Clue banner moved to dedicated widget file.
