// ignore_for_file: sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/screens/crossword_body.dart';

class CrosswordScreen extends ConsumerStatefulWidget {
  final String? puzzleId;

  const CrosswordScreen({Key? key, this.puzzleId}) : super(key: key);

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
  Widget build(BuildContext context) => CrosswordBody(controller: _controller);
}
