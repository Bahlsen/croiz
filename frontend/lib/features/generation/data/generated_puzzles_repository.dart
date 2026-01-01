import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Repository for managing locally generated puzzles backed by Hive.
class GeneratedPuzzlesRepository {
  static const String boxName = 'generated_puzzles';

  /// Saves a generated puzzle (full JSON) to local storage.
  Future<void> savePuzzle(Map<String, dynamic> puzzleJson) async {
    final box = await Hive.openBox(boxName);
    final id = puzzleJson['id'] as String;
    // Add source tag to ensure it's loaded correctly later
    puzzleJson['source'] = 'local';
    await box.put(id, puzzleJson);
  }

  /// Retrieves a specific puzzle by ID.
  Future<Map<String, dynamic>?> getPuzzle(String id) async {
    final box = await Hive.openBox(boxName);
    final data = box.get(id);
    if (data != null) {
      // Hive might return it as LinkedMap, casting safely
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  /// Deletes a puzzle by ID.
  Future<void> deletePuzzle(String id) async {
    final box = await Hive.openBox(boxName);
    await box.delete(id);
  }

  /// Returns descriptors for all stored puzzles.
  Future<List<PuzzleDescriptor>> getAllDescriptors() async {
    final box = await Hive.openBox(boxName);
    final descriptors = <PuzzleDescriptor>[];

    for (final key in box.keys) {
      final data = box.get(key);
      if (data is Map) {
        final json = Map<String, dynamic>.from(data);

        // Extract metadata
        final metadata = json['metadata'] as Map? ?? {};

        descriptors.add(
          PuzzleDescriptor(
            id: json['id']?.toString() ?? key.toString(),
            title: metadata['title']?.toString() ?? 'Untitled Puzzle',
            path: key.toString(), // For local puzzles, path is the ID/Key
            subtitle: 'Custom Puzzle',
            origin: 'generated',
            year: DateTime.now().year.toString(), // Could be stored in metadata
            difficulty: (metadata['difficulty'] as int?) ?? 2,
            difficultyLabel:
                metadata['difficulty_label']?.toString() ?? 'Medium',
            language: metadata['language']?.toString() ?? 'fr',
            source: PuzzleSource.local,
          ),
        );
      }
    }

    // Sort by creation time (if we had it) or title
    descriptors.sort(
      (a, b) => b.id.compareTo(a.id),
    ); // Newest first (assuming ID has timestamp or random)
    return descriptors;
  }
}

final generatedPuzzlesRepositoryProvider = Provider<GeneratedPuzzlesRepository>(
  (ref) => GeneratedPuzzlesRepository(),
);
