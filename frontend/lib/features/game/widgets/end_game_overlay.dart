// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

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
      debugPrint('EndGameOverlay provider read failed: $e\n$st');
      return const SizedBox.shrink();
    }

    final entries = board?.entries;
    final completed =
        entries != null &&
        entries.isNotEmpty &&
        found!.length == entries.length;
    if (!completed) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        const ModalBarrier(dismissible: false, color: Colors.black54),
        Center(
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
                // No timer displayed — kept intentionally blank/simple
                const SizedBox(height: 42),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Terminer'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
