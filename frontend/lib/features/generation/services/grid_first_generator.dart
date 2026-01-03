import 'dart:math';

import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/models/grid_quality_metrics.dart';
import 'package:croiz/features/generation/models/slot.dart';
import 'package:croiz/features/generation/services/csp_solver.dart';
import 'package:croiz/features/generation/services/gaddag.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';
import 'package:croiz/features/generation/services/grid_quality_calculator.dart';
import 'package:croiz/features/generation/services/grid_template.dart';

/// Result of grid-first generation
class GridFirstResult {
  const GridFirstResult({
    required this.placedWords,
    required this.grid,
    required this.template,
    required this.metrics,
    required this.success,
    this.failureReason,
  });

  /// Successfully placed words
  final List<PlacedWord> placedWords;

  /// The final grid (2D array of letters, null for empty)
  final List<List<String?>> grid;

  /// The template used (black square pattern)
  final List<List<bool>> template;

  /// Quality metrics for this generation
  final GridQualityMetrics metrics;

  /// Whether generation was fully successful
  final bool success;

  /// Reason for failure if not successful
  final String? failureReason;
}

/// Grid-First Crossword Generator
///
/// This generator uses a fundamentally different approach from the traditional
/// word-first method. Instead of placing words one by one, it:
///
/// 1. Generates a grid template with black squares
/// 2. Extracts word slots from the template
/// 3. Uses CSP (Constraint Satisfaction Problem) solving to fill slots
///
/// This approach ensures full grid coverage and dense intersections.
class GridFirstGenerator {
  GridFirstGenerator({
    required this.width,
    required this.height,
    Gaddag? gaddag,
    this.targetBlackRatio = 0.18,
    this.minWordLength = 3,
    this.maxAttempts = 5,
    Random? random,
  }) : _gaddag = gaddag ?? Gaddag(),
       _random = random ?? Random();

  final int width;
  final int height;
  final double targetBlackRatio;
  final int minWordLength;
  final int maxAttempts;

  final Gaddag _gaddag;
  final Random _random;

  bool _gaddagBuilt = false;

  /// Build the GADDAG dictionary from theme words and fill words.
  void buildDictionary(List<String> words) {
    _gaddag.build(words);
    _gaddagBuilt = true;
  }

  /// Add words to the existing dictionary.
  void addWords(List<String> words) {
    words.forEach(_gaddag.addWord);
    _gaddagBuilt = _gaddag.wordCount > 0;
  }

  /// Generate a crossword using grid-first approach.
  ///
  /// [themeWords] - Words from LLM related to the puzzle theme
  /// [fillWords] - Additional words for filling gaps (optional)
  GridFirstResult generate({
    required List<GeneratedWord> themeWords,
    List<String>? fillWords,
  }) {
    // Ensure dictionary is built
    if (!_gaddagBuilt) {
      final allWords = themeWords.map((w) => w.answer).toList();
      if (fillWords != null) {
        allWords.addAll(fillWords);
      }
      buildDictionary(allWords);
    }

    GridFirstResult? bestResult;
    var bestScore = -1.0;

    // Try multiple templates to find the best result
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final result = _generateSingleAttempt(themeWords);

      if (result.success) {
        final score = _calculateScore(result.metrics);
        if (score > bestScore) {
          bestScore = score;
          bestResult = result;
        }
      } else if (bestResult == null ||
          result.placedWords.length > bestResult.placedWords.length) {
        bestResult = result;
      }
    }

    return bestResult ??
        GridFirstResult(
          placedWords: [],
          grid: List.generate(height, (_) => List.filled(width, null)),
          template: List.generate(height, (_) => List.filled(width, false)),
          metrics: GridQualityCalculator.calculate(
            placedWords: [],
            gridWidth: width,
            gridHeight: height,
            totalWordsAttempted: themeWords.length,
          ),
          success: false,
          failureReason: 'All attempts failed',
        );
  }

  /// Single generation attempt with a specific template.
  GridFirstResult _generateSingleAttempt(List<GeneratedWord> themeWords) {
    // Step 1: Generate template
    final templateGenerator = GridTemplateGenerator(
      width: width,
      height: height,
      targetBlackRatio: targetBlackRatio,
      minWordLength: minWordLength,
      random: _random,
    )..generate();

    // Try different template styles
    final styles = [
      TemplateStyle.open,
      TemplateStyle.diagonal,
      TemplateStyle.checkerboard,
      TemplateStyle.random,
    ];
    final style = styles[_random.nextInt(styles.length)];
    final template = templateGenerator.generateWithStyle(style);

    // Step 2: Extract slots
    final slots = SlotExtractor.extractSlots(
      template,
      minLength: minWordLength,
    );

    if (slots.isEmpty) {
      return _createFailureResult(
        template,
        themeWords,
        'No valid slots in template',
      );
    }

    // Step 3: Two-pass strategy
    // Pass 1: Place theme words first (skeleton)
    final themeAssignment = _fillSkeleton(slots, themeWords);

    // Apply theme word constraints to known letters
    final knownLetters = _extractKnownLetters(themeAssignment, slots);

    // Pass 2: Fill remaining slots with CSP solver
    final remainingSlots =
        slots.where((s) => !themeAssignment.containsKey(s)).toList();

    Map<Slot, String> fullAssignment;
    if (remainingSlots.isNotEmpty) {
      final solver = CrosswordCSPSolver(
        gaddag: _gaddag,
        slots: remainingSlots,
        maxBacktracks: 5000,
      )..applyKnownLetters(knownLetters);

      final result = solver.solve();
      fullAssignment = {...themeAssignment, ...result.assignments};
    } else {
      fullAssignment = themeAssignment;
    }

    // Step 4: Convert to PlacedWords
    final placedWords = _convertToPlacedWords(fullAssignment, themeWords);

    // Step 5: Build grid
    final grid = _buildGrid(placedWords, template);

    // Step 6: Calculate metrics
    final metrics = GridQualityCalculator.calculate(
      placedWords: placedWords,
      gridWidth: width,
      gridHeight: height,
      totalWordsAttempted: themeWords.length,
    );

    final success = fullAssignment.length == slots.length;

    return GridFirstResult(
      placedWords: placedWords,
      grid: grid,
      template: template,
      metrics: metrics,
      success: success,
      failureReason: success ? null : 'Could not fill all slots',
    );
  }

  /// Fill skeleton with theme words.
  Map<Slot, String> _fillSkeleton(
    List<Slot> slots,
    List<GeneratedWord> themeWords,
  ) {
    final assignment = <Slot, String>{};

    // Sort theme words by length (longest first for better anchoring)
    final sortedTheme = [...themeWords]
      ..sort((a, b) => b.answer.length.compareTo(a.answer.length));

    // Track used slots
    final usedSlots = <Slot>{};

    for (final word in sortedTheme) {
      // Find slots that match word length
      final candidates =
          slots
              .where(
                (s) => s.length == word.answer.length && !usedSlots.contains(s),
              )
              .toList();

      if (candidates.isEmpty) {
        continue;
      }

      // Prioritize central slots
      candidates.sort((a, b) {
        final distA = a.distanceFromCenter(width, height);
        final distB = b.distanceFromCenter(width, height);
        return distA.compareTo(distB);
      });

      // Check for conflicts with existing assignments
      Slot? selectedSlot;
      for (final slot in candidates) {
        if (_canPlaceWord(slot, word.answer.toUpperCase(), assignment)) {
          selectedSlot = slot;
          break;
        }
      }

      if (selectedSlot != null) {
        assignment[selectedSlot] = word.answer.toUpperCase();
        usedSlots.add(selectedSlot);
      }
    }

    return assignment;
  }

  /// Check if a word can be placed in a slot without conflicts.
  bool _canPlaceWord(Slot slot, String word, Map<Slot, String> assignment) {
    for (final entry in assignment.entries) {
      final existingSlot = entry.key;
      final existingWord = entry.value;

      final intersection = slot.getIntersection(existingSlot);
      if (intersection != null) {
        final posInNew =
            slot.isHorizontal
                ? intersection.positionInHorizontal
                : intersection.positionInVertical;
        final posInExisting =
            existingSlot.isHorizontal
                ? intersection.positionInHorizontal
                : intersection.positionInVertical;

        if (posInNew >= word.length || posInExisting >= existingWord.length) {
          return false;
        }

        if (word[posInNew] != existingWord[posInExisting]) {
          return false;
        }
      }
    }
    return true;
  }

  /// Extract known letters from theme assignments.
  Map<Point<int>, String> _extractKnownLetters(
    Map<Slot, String> assignment,
    List<Slot> allSlots,
  ) {
    final known = <Point<int>, String>{};

    for (final entry in assignment.entries) {
      final slot = entry.key;
      final word = entry.value;

      for (var i = 0; i < word.length; i++) {
        final cell = slot.getCell(i);
        known[cell] = word[i];
      }
    }

    return known;
  }

  /// Convert slot assignments to PlacedWord objects.
  List<PlacedWord> _convertToPlacedWords(
    Map<Slot, String> assignment,
    List<GeneratedWord> themeWords,
  ) {
    final placedWords = <PlacedWord>[];
    final themeWordMap = {
      for (final w in themeWords) w.answer.toUpperCase(): w,
    };

    for (final entry in assignment.entries) {
      final slot = entry.key;
      final wordStr = entry.value;

      // Find the GeneratedWord or create a fill word
      var generatedWord = themeWordMap[wordStr];
      generatedWord ??= GeneratedWord(
        answer: wordStr,
        clue: 'Fill word: $wordStr',
      );

      placedWords.add(
        PlacedWord(
          word: generatedWord,
          startX: slot.startX,
          startY: slot.startY,
          isHorizontal: slot.isHorizontal,
        ),
      );
    }

    return placedWords;
  }

  /// Build the final grid from placed words.
  List<List<String?>> _buildGrid(
    List<PlacedWord> placedWords,
    List<List<bool>> template,
  ) {
    final grid = List.generate(
      height,
      (y) => List.generate(width, (x) => template[y][x] ? '#' : null),
    );

    for (final pw in placedWords) {
      for (var i = 0; i < pw.word.answer.length; i++) {
        final x = pw.isHorizontal ? pw.startX + i : pw.startX;
        final y = pw.isHorizontal ? pw.startY : pw.startY + i;

        if (x >= 0 && x < width && y >= 0 && y < height) {
          grid[y][x] = pw.word.answer[i].toUpperCase();
        }
      }
    }

    return grid;
  }

  /// Create a failure result with empty grid.
  GridFirstResult _createFailureResult(
    List<List<bool>> template,
    List<GeneratedWord> themeWords,
    String reason,
  ) => GridFirstResult(
    placedWords: [],
    grid: List.generate(height, (_) => List.filled(width, null)),
    template: template,
    metrics: GridQualityCalculator.calculate(
      placedWords: [],
      gridWidth: width,
      gridHeight: height,
      totalWordsAttempted: themeWords.length,
    ),
    success: false,
    failureReason: reason,
  );

  /// Calculate a score for ranking results.
  double _calculateScore(GridQualityMetrics metrics) =>
      metrics.wordsPlaced * 100.0 +
      metrics.rowCoverage * 50.0 +
      metrics.columnCoverage * 50.0 +
      metrics.avgIntersectionsPerWord * 30.0 +
      metrics.letterDensity * 20.0 -
      metrics.blackSquareRatio * 10.0;
}
