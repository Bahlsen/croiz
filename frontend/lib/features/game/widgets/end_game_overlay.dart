// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:go_router/go_router.dart';

class EndGameOverlay extends ConsumerWidget {
  const EndGameOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only counts to avoid rebuilding on every word/key change.
    final entriesLen = ref.watch(
      gameBoardProvider.select((b) => b.entries?.length),
    );
    final foundLen = ref.watch(foundWordsProvider.select((s) => s.length));
    if (entriesLen == null || entriesLen == 0) {
      return const SizedBox.shrink();
    }
    final completed = foundLen == entriesLen;
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
                  'Congratulations!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // No timer displayed — kept intentionally blank/simple
                const SizedBox(height: 42),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Navigate to puzzles list
                    context.go('/puzzles');
                  },
                  child: const Text('View puzzles'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
