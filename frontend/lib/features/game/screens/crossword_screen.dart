import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/screens/crossword_body.dart';

class CrosswordScreen extends ConsumerStatefulWidget {
  const CrosswordScreen({super.key, this.puzzleId});
  final String? puzzleId;

  @override
  ConsumerState<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends ConsumerState<CrosswordScreen> {
  late final CrosswordInputController _controller;
  // The board listener is now handled by `CrosswordBody`.

  @override
  void initState() {
    super.initState();
    _controller = CrosswordInputController(ref);
    // If a puzzle id is provided (via route query), attempt to load it and
    // set the selected puzzle id so the loader provider will load it.
    _setSelectedPuzzleId(widget.puzzleId);
    // Hide system UI (navigation buttons) for full-screen gameplay.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didUpdateWidget(CrosswordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle case where GoRouter reuses the widget with a different puzzleId
    if (widget.puzzleId != oldWidget.puzzleId) {
      _setSelectedPuzzleId(widget.puzzleId);
      // Reset controller navigation state for the new puzzle
      _controller
        ..resetNavigationState()
        ..resetAutoSelectFirstAcross();
    }
  }

  void _setSelectedPuzzleId(String? puzzleId) {
    if (puzzleId != null) {
      final decoded = Uri.decodeComponent(puzzleId);
      // Delay setting the provider until after the widget tree has
      // finished building to avoid Riverpod runtime errors.
      Future.microtask(() {
        try {
          final current = ref.read(selectedPuzzleIdProvider);
          if (current != decoded) {
            ref.read(selectedPuzzleIdProvider.notifier).setSelected(decoded);
          }
        } on Object catch (e, st) {
          if (kDebugMode) {
            debugPrint('Failed to set selected puzzle id: $e\n$st');
          }
        }
      });
    }
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
  Widget build(BuildContext context) => CrosswordBody(controller: _controller);
}
