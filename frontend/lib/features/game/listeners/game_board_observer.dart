// Observes game board changes and triggers controller actions and timer start.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_timer_provider.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';

class GameBoardObserver extends ConsumerStatefulWidget {
  const GameBoardObserver({
    required this.controller,
    required this.child,
    super.key,
  });
  final CrosswordInputController controller;
  final Widget child;

  @override
  ConsumerState<GameBoardObserver> createState() => _GameBoardObserverState();
}

class _GameBoardObserverState extends ConsumerState<GameBoardObserver> {
  bool _attached = false;

  @override
  Widget build(BuildContext context) {
    if (!_attached) {
      _attached = true;
      ref.listen<GameBoard>(gameBoardProvider, (
        GameBoard? previous,
        GameBoard next,
      ) {
        try {
          // If the puzzle changed, reset controller navigation state and
          // allow the controller to auto-select again.
          if (previous == null || previous.id != next.id) {
            widget.controller.resetNavigationState();
            widget.controller.resetAutoSelectFirstAcross();
          }
          widget.controller.tryAutoSelectFirstAcross(next);
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

        Future.microtask(() {
        try {
          final current = ref.read(gameBoardProvider);
          widget.controller.resetNavigationState();
          widget.controller.tryAutoSelectFirstAcross(current);
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

    return widget.child;
  }
}
