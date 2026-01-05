import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';
import 'package:croiz/services/persistence/storage_provider.dart';

final puzzleProgressServiceProvider = Provider<PuzzleProgressService>((ref) {
  final storage = ref.watch(puzzleStorageProvider);
  return PuzzleProgressService(
    storage: storage,
    assetLoader: defaultPuzzleJsonLoader,
  );
});
