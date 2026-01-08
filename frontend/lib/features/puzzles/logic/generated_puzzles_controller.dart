import 'package:croiz/features/generation/data/generated_puzzles_repository.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated_puzzles_controller.g.dart';

@Riverpod(dependencies: [generatedPuzzlesRepository, puzzles])
class GeneratedPuzzlesController extends _$GeneratedPuzzlesController {
  @override
  FutureOr<void> build() {
    // No initial state to maintain beyond async loading status
  }

  Future<void> deletePuzzle(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(generatedPuzzlesRepositoryProvider);
      await repo.deletePuzzle(id);

      // Invalidate the puzzles provider to trigger a refresh of the list
      ref.invalidate(puzzlesProvider);
    });
  }
}
