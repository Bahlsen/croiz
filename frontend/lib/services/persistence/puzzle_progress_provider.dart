import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';
import 'package:croiz/services/persistence/storage_provider.dart';

part 'puzzle_progress_provider.g.dart';

@Riverpod(keepAlive: true)
PuzzleProgressService puzzleProgressService(Ref ref) {
  final storage = ref.watch(puzzleStorageProvider);
  return PuzzleProgressService(
    storage: storage,
    assetLoader: defaultPuzzleJsonLoader,
  );
}
