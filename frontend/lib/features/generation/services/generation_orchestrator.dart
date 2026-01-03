import 'dart:developer' as developer;
import 'package:croiz/core/exceptions/user_friendly_exception.dart';
import 'package:croiz/features/generation/data/generated_puzzles_repository.dart';
import 'package:croiz/features/generation/services/gemini_service.dart';
import 'package:croiz/features/generation/models/placed_word.dart';
import 'package:croiz/features/generation/services/fill_dictionary_service.dart';
import 'package:croiz/features/generation/services/grid_first_generator.dart';
import 'package:croiz/features/generation/utils/grid_validator.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class PuzzleGenerationOrchestrator {
  PuzzleGenerationOrchestrator(
    this._geminiService,
    this._repository,
    this._ref,
    this._fillService,
  );

  final GeminiPuzzleService _geminiService;
  final GeneratedPuzzlesRepository _repository;
  final Ref _ref;
  final FillDictionaryService _fillService;

  Future<String> generateAndSave({
    required String topic,
    required String language,
    int difficulty = 2,
    int size = 15,
  }) async {
    // 1. Generate Words via Gemini (we do this once as it's the most expensive/slow part)
    final words = await _geminiService.generateWords(
      topic: topic,
      language: language,
      difficultyLevel: difficulty,
      count:
          size *
          4, // Request proportional word count (need strict surplus for density)
    );

    if (words.length < 5) {
      throw UserFriendlyException(
        'Unable to generate enough words for this topic. Please try a different topic.',
        technicalDetails:
            'Only ${words.length} words generated, minimum 5 required',
      );
    }

    const maxRetries = 3;
    Map<String, dynamic>? lastValidPuzzleJson;

    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // 2. Load Fill Dictionary (v3 Requirement)
        final fillWords = await _fillService.loadDictionary(language);

        // 3. Build Grid (Grid-First v3)
        final generator = GridFirstGenerator(width: size, height: size);
        final result = generator.generate(
          themeWords: words,
          fillWords: fillWords,
        );
        // RELAXED CHECK: If we have a good number of words, we accept it.
        // The generator now returns the best attempt even if 'success' is false.
        if (result.placedWords.length < 5) {
          throw UserFriendlyException(
            'Unable to create a complete puzzle grid.',
            technicalDetails:
                'GridFirstGenerator failed to fill enough slots (Success: ${result.success}, Words: ${result.placedWords.length})',
          );
        }

        final placedWords = result.placedWords;

        if (placedWords.isEmpty) {
          throw UserFriendlyException(
            'Unable to create a puzzle grid.',
            technicalDetails:
                'GridFirstGenerator returned 0 placed words (Reason: ${result.failureReason})',
          );
        }

        // 2b. Validation
        final validation = GridValidator.validate(placedWords, size, size);
        if (!validation.isValid) {
          // Filter for critical errors that make the puzzle unplayable
          final criticalErrors =
              validation.errors.where((e) {
                final lower = e.toLowerCase();
                return lower.contains('collision') ||
                    lower.contains('bounds') ||
                    lower.contains('exceeds');
              }).toList();

          if (criticalErrors.isNotEmpty) {
            throw UserFriendlyException(
              'The generated puzzle contains structural errors.',
              technicalDetails:
                  'Grid validation failed: ${criticalErrors.join("; ")}',
            );
          }

          // Log non-critical errors (adjacency, connectivity) but proceed
          // ignore: avoid_print
          print('Non-critical validation warnings: ${validation.errors}');
        }

        // 3. Convert to Puzzle format
        final puzzleJson = _convertToPuzzleJson(
          placedWords,
          size,
          size,
          topic,
          language,
          difficulty,
          fillWords.toSet(),
        );

        // 4. Quality Control
        final totalCells = size * size;
        final blackCells =
            puzzleJson['cells'].where((c) => c['is_black'] as bool).length;
        final filledCells = totalCells - blackCells;
        final density = filledCells / totalCells;

        // Threshold: 0.15 is our safe lower bound
        if (density < 0.15) {
          throw UserFriendlyException(
            'The generated puzzle was not dense enough ($filledCells letters).',
            technicalDetails:
                'Density too low: ${density.toStringAsFixed(2)} < 0.15',
          );
        }

        // If we reached here, the puzzle is valid and dense enough!
        lastValidPuzzleJson = puzzleJson;

        // POST-PROCESS: Fetch missing clues for fill words (Hybrid Generation)
        final entries = lastValidPuzzleJson['entries'] as List<dynamic>;
        final entriesNeedingClues =
            entries.where((e) {
              final clue = e['clue'] as String;
              return clue == '...' || clue == 'Common word';
            }).toList();

        if (entriesNeedingClues.isNotEmpty) {
          developer.log(
            'Fetching clues for ${entriesNeedingClues.length} fill words...',
          );
          try {
            final wordsToFetch =
                entriesNeedingClues
                    .map((e) => e['answer'] as String)
                    .toSet()
                    .toList();
            // Batched fetch (max 50)
            final batch = wordsToFetch.take(50).toList();

            final generatedClues = await _geminiService.generateClues(
              words: batch,
              language: language,
              difficulty: difficulty,
            );

            // Update entries map
            final clueMap = {
              for (final w in generatedClues) w.answer.toUpperCase(): w.clue,
            };
            if (clueMap.isNotEmpty) {
              for (final entry in entries) {
                final word = (entry['answer'] as String).toUpperCase();
                if (clueMap.containsKey(word)) {
                  entry['clue'] = clueMap[word];
                }
              }
            }
          } on Exception catch (e) {
            // Log error but continue with what we have
            developer.log('Failed to fetch clues for fill words: $e');
          }
        }

        break;
      } catch (e) {
        // Log the failure for this attempt
        developer.log('Generation attempt $attempt fail: $e');

        if (attempt == maxRetries) {
          rethrow;
        }
        // Otherwise, continue to next attempt
      }
    }

    // 5. Save
    final puzzleJson = lastValidPuzzleJson!;
    await _repository.savePuzzle(puzzleJson);

    // 6. Invalidate provider to refresh list
    _ref.invalidate(puzzlesProvider);

    return puzzleJson['id'] as String;
  }

  Map<String, dynamic> _convertToPuzzleJson(
    List<PlacedWord> placedWords,
    int cols,
    int rows,
    String topic,
    String language,
    int difficulty,
    Set<String> fillDictionary,
  ) {
    final id = const Uuid().v4();

    // 1. Build Cells
    // Init with Black cells
    final cells = <Map<String, dynamic>>[];
    final gridState = List.generate(
      rows,
      (_) => List<String?>.filled(cols, null, growable: false),
    );

    // Fill grid state locally first to check bounds
    for (final pw in placedWords) {
      for (var i = 0; i < pw.word.answer.length; i++) {
        final cx = pw.isHorizontal ? pw.startX + i : pw.startX;
        final cy = pw.isHorizontal ? pw.startY : pw.startY + i;
        gridState[cy][cx] = pw.word.answer[i];
      }
    }

    // Create Cell Objects
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final char = gridState[y][x];
        cells.add({'x': x, 'y': y, 'is_black': char == null, 'solution': char});
      }
    }

    // 2. Compute Numbering (Standard Crossword Numbering)
    var currentNumber = 1;
    final numberMap = <String, int>{}; // "x,y" -> number

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        if (gridState[y][x] == null) {
          continue; // black cell
        }

        // Check if start of Across
        // Left is edge OR black
        final startAcross =
            (x == 0 || gridState[y][x - 1] == null) &&
            (x + 1 < cols && gridState[y][x + 1] != null);

        // Check if start of Down
        // Top is edge OR black
        final startDown =
            (y == 0 || gridState[y - 1][x] == null) &&
            (y + 1 < rows && gridState[y + 1][x] != null);

        if (startAcross || startDown) {
          numberMap['$x,$y'] = currentNumber;
          currentNumber++;
        }
      }
    }

    // 3. Build Entries
    // REVISED STRATEGY: Scan the gridState to find ALL words (horizontal and vertical).
    // This detects "accidental" words formed by intersecting placement, which is common
    // in dense grids (and crucial for legal crossword navigation).
    // It also fixes the UI bug where selecting an "intersecting" cell with no defined word
    // would result in empty selection.
    //
    // We map found words to:
    // 1. PlacedWord (if exact match) -> use its Clue
    // 2. Dictionary (if valid) -> "Found word"
    // 3. Unknown (if invalid) -> "..."

    final entries = <Map<String, dynamic>>[];

    // Create lookup for existing PlacedWords
    final placedMap = <String, PlacedWord>{};
    for (final pw in placedWords) {
      final key =
          '${pw.word.answer}_${pw.startX}_${pw.startY}_${pw.isHorizontal}';
      placedMap[key] = pw;
    }

    // Helper to generate entry
    void addEntry({
      required int startX,
      required int startY,
      required String word,
      required bool isHorizontal,
    }) {
      if (word.length < 2) {
        return; // Ignore single letters
      }

      final num = numberMap['$startX,$startY'];
      if (num == null) {
        return;
      }

      // Try to find matching PlacedWord
      final key = '${word}_${startX}_${startY}_$isHorizontal';
      final match = placedMap[key];

      var clue = match?.word.clue;
      if (clue == null) {
        // Accidental word. Check if valid.
        if (fillDictionary.contains(word)) {
          clue = 'Common word';
        } else if (placedWords.any((pw) => pw.word.answer == word)) {
          // Maybe it was placed elsewhere or is a theme word?
          clue = 'Theme word';
        } else {
          // Invalid or unknown word
          clue = '...';
        }
      }

      entries.add({
        'id': '${isHorizontal ? 'A' : 'D'}$num',
        'number': num,
        'direction': isHorizontal ? 'across' : 'down',
        'x': startX,
        'y': startY,
        'length': word.length,
        'answer': word,
        'clue': clue,
      });
    }

    // Scan Horizontal
    for (var y = 0; y < rows; y++) {
      var currentWord = '';
      var startX = -1;
      for (var x = 0; x <= cols; x++) {
        final char = (x < cols) ? gridState[y][x] : null;
        if (char != null) {
          if (startX == -1) {
            startX = x;
          }
          currentWord += char;
        } else {
          if (currentWord.length >= 2) {
            addEntry(
              startX: startX,
              startY: y,
              word: currentWord,
              isHorizontal: true,
            );
          }
          currentWord = '';
          startX = -1;
        }
      }
    }

    // Scan Vertical
    for (var x = 0; x < cols; x++) {
      var currentWord = '';
      var startY = -1;
      for (var y = 0; y <= rows; y++) {
        final char = (y < rows) ? gridState[y][x] : null;
        if (char != null) {
          if (startY == -1) {
            startY = y;
          }
          currentWord += char;
        } else {
          if (currentWord.length >= 2) {
            addEntry(
              startX: x,
              startY: startY,
              word: currentWord,
              isHorizontal: false,
            );
          }
          currentWord = '';
          startY = -1;
        }
      }
    }

    // Sort entries
    entries.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));

    return {
      'id': id,
      'metadata': {
        'title': _capitalize(topic),
        'author': 'AI',
        'language': language,
        'difficulty': difficulty,
        'difficulty_label': 'Generated',
        'width': cols,
        'height': rows,
      },
      'rows': rows,
      'cols': cols,
      'cells': cells,
      'entries': entries,
      'source': 'local', // IMPORTANT TAG
    };
  }

  String _capitalize(String s) {
    if (s.isEmpty) {
      return s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }
}

final puzzleGenerationOrchestratorProvider =
    Provider<PuzzleGenerationOrchestrator>(
      (ref) => PuzzleGenerationOrchestrator(
        ref.watch(geminiPuzzleServiceProvider),
        ref.watch(generatedPuzzlesRepositoryProvider),
        ref,
        ref.watch(fillDictionaryServiceProvider),
      ),
    );
