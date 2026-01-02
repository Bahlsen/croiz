import 'dart:convert';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Repository for managing locally generated puzzles backed by Hive.
class GeneratedPuzzlesRepository {
  GeneratedPuzzlesRepository({Box? box}) : _box = box;

  static const String boxName = 'generated_puzzles';
  final Box? _box;

  Future<Box> _openBox() async =>
      _box ?? await Hive.openBox(boxName); // coverage:ignore-line

  /// Saves a generated puzzle (full JSON) to local storage.
  Future<void> savePuzzle(Map<String, dynamic> puzzleJson) async {
    final box = await _openBox();
    final id = puzzleJson['id'] as String;
    // Add source tag to ensure it's loaded correctly later
    puzzleJson['source'] = 'local';
    await box.put(id, puzzleJson);
  }

  /// Retrieves a specific puzzle by ID.
  Future<Map<String, dynamic>?> getPuzzle(String id) async {
    final box = await _openBox();
    final data = box.get(id);
    if (data != null) {
      // Hive returns Map<dynamic, dynamic> which causes issues with json_serializable
      // parsing of nested objects (mostly Metadata and Cell/Entry annotations).
      // The safest way to "normalize" this structure to strictly Map<String, dynamic>
      // throughout the entire depth is to encode and decode it.
      try {
        return jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
      } on Object catch (_) {
        // Fallback or re-throw
        return Map<String, dynamic>.from(data as Map);
      }
    }
    return null;
  }

  /// Deletes a puzzle by ID.
  Future<void> deletePuzzle(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  /// Returns descriptors for all stored puzzles.
  Future<List<PuzzleDescriptor>> getAllDescriptors() async {
    final box = await _openBox();
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
  (ref) => GeneratedPuzzlesRepository(), // coverage:ignore-line
);
