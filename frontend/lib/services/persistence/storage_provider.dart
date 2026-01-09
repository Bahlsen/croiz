import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/data/db/database_provider.dart';
import 'package:croiz/services/persistence/drift_puzzle_storage.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';

part 'storage_provider.g.dart';

@Riverpod(keepAlive: true)
PuzzleStorageInterface puzzleStorage(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftPuzzleStorage(db);
}
