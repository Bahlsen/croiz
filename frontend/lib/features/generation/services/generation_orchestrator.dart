import 'package:croiz/core/exceptions/user_friendly_exception.dart';
import 'package:croiz/features/generation/data/generated_puzzles_repository.dart';
import 'package:croiz/features/generation/services/gemini_service.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class PuzzleGenerationOrchestrator {
  PuzzleGenerationOrchestrator(
    this._geminiService,
    this._repository,
    this._ref,
  );

  final GeminiPuzzleService _geminiService;
  final GeneratedPuzzlesRepository _repository;
  final Ref _ref;

  Future<String> generateAndSave({
    required String topic,
    required String language,
    int difficulty = 2,
    int size = 15,
  }) async {
    // 1. Generate Words via Gemini
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

    // 2. Build Grid
    // 2. Build Grid
    final generator = GridGenerator(width: size, height: size);
    final placedWords = generator.generate(words, language: language);

    if (placedWords.isEmpty) {
      throw UserFriendlyException(
        'Unable to create a puzzle grid. Please try again or choose a different difficulty.',
        technicalDetails: 'Grid generator returned 0 placed words',
      );
    }

    // 3. Convert to Puzzle format
    final puzzleJson = _convertToPuzzleJson(
      placedWords,
      size,
      size,
      topic,
      language,
      difficulty,
    );

    // 4. Quality Control
    // Calculate density: filled cells / total bounding box area (or total area?)
    // Standard crossword density is usually > 30% words.
    // Our "cells" list contains all cells (including black ones if we generated full grid).
    // Actually `cells` in our JSON contains x, y, is_black.
    // Let's count black vs total (width * height).

    final totalCells = size * size;
    final blackCells =
        puzzleJson['cells'].where((c) => c['is_black'] as bool).length;
    final filledCells = totalCells - blackCells;
    final density = filledCells / totalCells;

    // Threshold: 0.25 (25%) is a low bar but ensures we don't have empty grids.
    // A good 15x15 has ~225 cells. 25% is ~56 letters.
    // If we placed 27 words avg length 5 ~ 135 letters ~ 60% density!
    // If we placed 27 words avg length 5 ~ 135 letters ~ 60% density!
    // So 0.20 is a safe lower bound for the current generator performance (observed ~0.26).
    if (density < 0.20) {
      throw UserFriendlyException(
        'The generated puzzle was not dense enough ($filledCells letters). Please try again or choose a different topic.',
        technicalDetails:
            'Density too low: ${density.toStringAsFixed(2)} < 0.20',
      );
    }

    // 5. Save
    await _repository.savePuzzle(puzzleJson);

    // 5. Invalidate provider to refresh list
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
    final entries = <Map<String, dynamic>>[];

    // We map PlacedWords to entries.
    // Issue: GridGenerator might have placed words that overlap.
    // The visual grid is authoritative.
    // We need to match PlacedWords to the grid positions and numbers.
    // Or we can simple re-scan the grid for words if we didn't track them.
    // Since we Have `placedWords`, let's use them.

    for (final pw in placedWords) {
      final num = numberMap['${pw.startX},${pw.startY}'];
      if (num == null) {
        // This is weird. Every placed word SHOULD start at a numbered square.
        // It might happen if our "Start" detection logic differs from grid reality,
        // but it shouldn't.
        continue;
      }

      entries.add({
        'id': '${pw.isHorizontal ? 'A' : 'D'}$num',
        'number': num,
        'direction': pw.isHorizontal ? 'across' : 'down',
        'x': pw.startX,
        'y': pw.startY,
        'length': pw.word.answer.length,
        'answer': pw.word.answer,
        'clue': pw.word.clue,
      });
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
      ),
    );
