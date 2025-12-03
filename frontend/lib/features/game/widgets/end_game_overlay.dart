// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/game_timer_provider.dart';

class EndGameOverlay extends ConsumerWidget {
  const EndGameOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GameBoard? board;
    Set<String>? found;
    try {
      board = ref.watch(gameBoardProvider);
      found = ref.watch(foundWordsProvider);
    } on Object catch (e, st) {
      // Provider not ready in tests; skip overlay rendering but log error
      debugPrint('EndGameOverlay provider read failed: $e\n$st');
      return const SizedBox.shrink();
    }

    final entries = board?.entries;

    final completed = entries != null && entries.isNotEmpty && found!.length == entries.length;
    if (!completed) {
      return const SizedBox.shrink();
    }

    String timeText;
    try {
      final timer = ref.read(gameTimerProvider(board!.id));
      timeText = timer.formattedElapsed();
    } on Object catch (e, st) {
      debugPrint('EndGameOverlay: failed to read gameTimerProvider: $e\n$st');
      timeText = '--:--';
    }

    return Stack(
      children: [
        // dim background
          AnimatedOpacity(
          opacity: 0.85,
          duration: const Duration(milliseconds: 300),
          child: const ModalBarrier(dismissible: false, color: Colors.black54),
        ),
        // centered card
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: const Duration(milliseconds: 450),
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: child,
            ),
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bravo !',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    timeText,
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Terminer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
