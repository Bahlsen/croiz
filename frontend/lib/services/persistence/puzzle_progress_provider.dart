import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';
import 'package:croiz/services/persistence/storage_provider.dart';

part 'puzzle_progress_provider.g.dart';

@Riverpod(keepAlive: true)
PuzzleJsonLoader puzzleJsonLoader(Ref ref) => defaultPuzzleJsonLoader;

@Riverpod(keepAlive: true, dependencies: [puzzleStorage, puzzleJsonLoader])
PuzzleProgressService puzzleProgressService(Ref ref) {
  final storage = ref.watch(puzzleStorageProvider);
  final loader = ref.watch(puzzleJsonLoaderProvider);
  return PuzzleProgressService(storage: storage, assetLoader: loader);
}
