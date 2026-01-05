import 'dart:convert';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/data/db/app_database.dart';
import 'package:croiz/data/db/database_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repository for managing locally generated puzzles backed by Drift (SQLite).
class GeneratedPuzzlesRepository {
  GeneratedPuzzlesRepository(this.db);

  final AppDatabase db;

  /// Saves a generated puzzle (full JSON) to local storage.
  Future<void> savePuzzle(Map<String, dynamic> puzzleJson) async {
    final id = puzzleJson['id'] as String;
    // Add source tag
    puzzleJson['source'] = 'local';

    final metadata = puzzleJson['metadata'] as Map<String, dynamic>? ?? {};
    final difficulty = (metadata['difficulty'] as int?) ?? 2;
    final language = metadata['language']?.toString() ?? 'fr';
    final title = metadata['title']?.toString() ?? 'Untitled Puzzle';

    await db
        .into(db.generatedPuzzles)
        .insert(
          GeneratedPuzzlesCompanion(
            puzzleId: Value(id),
            jsonPayload: Value(jsonEncode(puzzleJson)),
            createdAt: Value(DateTime.now()),
            difficulty: Value(difficulty),
            language: Value(language),
            title: Value(title),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Retrieves a specific puzzle by ID.
  Future<Map<String, dynamic>?> getPuzzle(String id) async {
    final record =
        await (db.select(db.generatedPuzzles)
          ..where((t) => t.puzzleId.equals(id))).getSingleOrNull();

    if (record != null) {
      return jsonDecode(record.jsonPayload) as Map<String, dynamic>;
    }
    return null;
  }

  /// Deletes a puzzle by ID.
  Future<void> deletePuzzle(String id) async {
    await (db.delete(db.generatedPuzzles)
      ..where((t) => t.puzzleId.equals(id))).go();
  }

  /// Returns descriptors for all stored puzzles.
  Future<List<PuzzleDescriptor>> getAllDescriptors() async {
    final query = db.select(db.generatedPuzzles)..orderBy([
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);

    final records = await query.get();

    return records
        .map(
          (record) => PuzzleDescriptor(
            id: record.puzzleId,
            title: record.title,
            path: record.puzzleId,
            subtitle: 'Custom Puzzle',
            origin: 'generated',
            year: record.createdAt.year.toString(),
            difficulty: record.difficulty,
            difficultyLabel: _getDifficultyLabel(record.difficulty),
            language: record.language,
            source: PuzzleSource.local,
          ),
        )
        .toList();
  }

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      case 4:
        return 'Expert';
      default:
        return 'Medium';
    }
  }
}

final generatedPuzzlesRepositoryProvider = Provider<GeneratedPuzzlesRepository>(
  (ref) {
    final db = ref.watch(appDatabaseProvider);
    return GeneratedPuzzlesRepository(db);
  },
);
