import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:croiz/data/db/app_database.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';

/// Drift (SQLite) implementation of puzzle storage.
class DriftPuzzleStorage implements PuzzleStorageInterface {
  DriftPuzzleStorage(this.db);

  final AppDatabase db;

  @override
  Future<Map<String, dynamic>?> load(String id) async {
    final record =
        await (db.select(db.puzzleProgress)
          ..where((t) => t.puzzleId.equals(id))).getSingleOrNull();

    if (record == null) {
      return null;
    }
    return jsonDecode(record.jsonPayload) as Map<String, dynamic>;
  }

  @override
  Future<void> save(String id, Map<String, dynamic> payload) async {
    final now = DateTime.now();
    // Extract metadata for optimized querying if available
    final isCompleted = payload['isCompleted'] == true;
    final completionPercent = payload['completionPercent'] as int? ?? 0;

    await db
        .into(db.puzzleProgress)
        .insert(
          PuzzleProgressCompanion(
            puzzleId: Value(id),
            jsonPayload: Value(jsonEncode(payload)),
            lastPlayed: Value(now),
            isCompleted: Value(isCompleted),
            completionPercent: Value(completionPercent),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> delete(String id) async {
    await (db.delete(db.puzzleProgress)
      ..where((t) => t.puzzleId.equals(id))).go();
  }

  @override
  Future<List<String>> getAllKeys() async {
    final query = db.selectOnly(db.puzzleProgress)
      ..addColumns([db.puzzleProgress.puzzleId]);

    final results = await query.get();
    return results.map((row) => row.read(db.puzzleProgress.puzzleId)!).toList();
  }

  @override
  Stream<void> get onDataChanged =>
      db.select(db.puzzleProgress).watch().map((_) {});
}
