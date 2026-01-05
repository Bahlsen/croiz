import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/data/db/database_provider.dart';
import 'package:croiz/services/persistence/drift_puzzle_storage.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';

final puzzleStorageProvider = Provider<PuzzleStorageInterface>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftPuzzleStorage(db);
});
