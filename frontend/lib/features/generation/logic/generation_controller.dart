import 'package:croiz/core/exceptions/user_friendly_exception.dart';
import 'package:croiz/features/generation/services/generation_orchestrator.dart';
import 'package:croiz/features/puzzles/pending_puzzles_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'generation_controller.g.dart';

@riverpod
class GenerationController extends _$GenerationController {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<void> generateInBackgroundTask({
    required String topic,
    required String language,
    required int difficulty,
    required int size,
  }) async {
    // Enforce single generation at a time
    final isAlreadyGenerating = ref.read(pendingPuzzlesProvider).isNotEmpty;
    if (isAlreadyGenerating) {
      throw UserFriendlyException(
        'A puzzle is already being generated. Please wait until it completes.',
        technicalDetails: 'Generation limit exceeded: 1',
      );
    }

    final tempId = const Uuid().v4();
    final pending = PendingPuzzle(
      tempId: tempId,
      topic: topic,
      language: language,
      difficulty: difficulty,
    );

    // Add to pending list
    ref.read(pendingPuzzlesProvider.notifier).add(pending);

    state = const AsyncValue.loading();

    try {
      final orchestrator = ref.read(puzzleGenerationOrchestratorProvider);
      final puzzleId = await orchestrator.generateAndSave(
        topic: topic,
        language: language,
        difficulty: difficulty,
        size: size,
      );

      // On success, the orchestrator invalidates the puzzlesProvider,
      // but we need to remove from pending
      ref.read(pendingPuzzlesProvider.notifier).remove(tempId);
      state = AsyncValue.data(puzzleId);
    } on Object catch (e, st) {
      ref.read(pendingPuzzlesProvider.notifier).remove(tempId);
      state = AsyncValue.error(e, st);

      // Log error for the user to see later if needed,
      // but since the dialog is closed, we might want to show a SnackBar or similar.
      debugPrint('Background generation failed for $topic: $e');
    }
  }
}
