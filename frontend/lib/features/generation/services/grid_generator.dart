import 'package:croiz/features/generation/models/generated_word.dart';

/// Represents a word placed on the grid.
class PlacedWord {
  PlacedWord({
    required this.word,
    required this.startX,
    required this.startY,
    required this.isHorizontal,
  });

  final GeneratedWord word;
  final int startX;
  final int startY;
  final bool isHorizontal;
}

class GridGenerator {
  GridGenerator({required this.width, required this.height})
    : _grid = List.generate(height, (_) => List.filled(width, null));

  final int width;
  final int height;
  final List<List<String?>> _grid; // null = empty, char = filled

  String? _currentLanguage;

  /// Main entry point: attempts to place as many words as possible.
  /// Uses a random restart strategy to find the best layout.
  /// Increased attempts from 100 to 150 for better optimization with 40 words.
  List<PlacedWord> generate(
    List<GeneratedWord> words, {
    int attempts = 150, // Increased from 100
    String? language,
  }) {
    if (words.isEmpty) {
      return [];
    }

    _currentLanguage = language;
    var bestGrid = <PlacedWord>[];
    var bestScore = -1.0;

    // Filter out duplicate answers case-insensitively
    final uniqueWords = <String, GeneratedWord>{};
    for (final w in words) {
      if (!uniqueWords.containsKey(w.answer)) {
        uniqueWords[w.answer] = w;
      }
    }
    final cleanWords = uniqueWords.values.toList();

    for (var i = 0; i < attempts; i++) {
      // Shuffle for random restart
      final shuffled =
          List<GeneratedWord>.from(cleanWords)
            ..shuffle()
            // Always try to start with a reasonably long word to anchor the puzzle
            // Sorting ALL by length is rigid, but picking one of the longest
            // as the seed is good practice.
            // Let's sort by length, then take the top 5, pick one random,
            // and put it first.
            ..sort((a, b) => b.answer.length.compareTo(a.answer.length));

      // Pick one of the top 5 longest words as start (increased from 3)
      // Then shuffle the rest
      if (shuffled.length > 5) {
        final top = shuffled.sublist(0, 5)..shuffle();
        final rest = shuffled.sublist(5)..shuffle();
        shuffled
          ..clear()
          ..addAll(top)
          ..addAll(rest);
      }

      final result = _generateSinglePass(shuffled);
      final score = _calculateScore(result);

      if (score > bestScore) {
        bestScore = score;
        bestGrid = result;
      }
    }

    // Clear grid and re-place the best result to ensure the _grid state matches return
    _resetGrid();
    bestGrid.forEach(_placeWordOnGrid);

    return bestGrid;
  }

  void _resetGrid() {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        _grid[y][x] = null;
      }
    }
  }

  void _placeWordOnGrid(PlacedWord pw) {
    for (var i = 0; i < pw.word.answer.length; i++) {
      final cx = pw.isHorizontal ? pw.startX + i : pw.startX;
      final cy = pw.isHorizontal ? pw.startY : pw.startY + i;
      _grid[cy][cx] = pw.word.answer[i];
    }
  }

  double _calculateScore(List<PlacedWord> placed) {
    if (placed.isEmpty) {
      return 0;
    }

    final wordCount = placed.length;

    // Calculate Bounding Box
    var minX = width;
    var maxX = 0;
    var minY = height;
    var maxY = 0;
    var filledCells = 0;

    // Note: Efficient calculation would track this during generation
    // But for 20-50 words, this loop is negligible.
    final tempSet = <String>{}; // "x,y"

    for (final pw in placed) {
      for (var i = 0; i < pw.word.answer.length; i++) {
        final x = pw.isHorizontal ? pw.startX + i : pw.startX;
        final y = pw.isHorizontal ? pw.startY : pw.startY + i;
        if (x < minX) {
          minX = x;
        }
        if (x > maxX) {
          maxX = x;
        }
        if (y < minY) {
          minY = y;
        }
        if (y > maxY) {
          maxY = y;
        }

        final key = '$x,$y';
        if (!tempSet.contains(key)) {
          tempSet.add(key);
          filledCells++;
        }
      }
    }

    final area = (maxX - minX + 1) * (maxY - minY + 1);
    final density = filledCells / (area > 0 ? area : 1);

    // Weighting:
    // Word Count is King - heavily prioritize placing more words
    // Density is Queen - compact grids are more aesthetic
    // Increased word count weight to strongly favor more placements
    return (wordCount * 2000.0) + (density * 200.0); // Doubled weights
  }

  /// Single pass generation logic with MRV heuristic and forward checking
  List<PlacedWord> _generateSinglePass(List<GeneratedWord> words) {
    // We work on a temp grid by clearing the current one first
    // Since we run this sequentially in loop, we reuse the class _grid
    _resetGrid();

    final placed = <PlacedWord>[];
    final remaining = List<GeneratedWord>.from(words);

    // Place the first word in the center (randomly horizontal or vertical)
    final first = remaining.removeAt(0);
    final isFirstHorizontal = DateTime.now().microsecond.isEven;

    int startX, startY;
    if (isFirstHorizontal) {
      startX = (width - first.answer.length) ~/ 2;
      startY = height ~/ 2;
      if (startX < 0 || startX + first.answer.length > width) {
        return [];
      }
    } else {
      startX = width ~/ 2;
      startY = (height - first.answer.length) ~/ 2;
      if (startY < 0 || startY + first.answer.length > height) {
        return [];
      }
    }

    _place(first, startX, startY, isFirstHorizontal, placed);

    // Build domains: for each remaining word, find all valid positions
    final domains = <GeneratedWord, List<_Move>>{};
    for (final word in remaining) {
      domains[word] = _findAllValidMoves(word.answer);
    }

    // Greedy placement with MRV heuristic and forward checking
    var madeProgress = true;
    var passCount = 0;
    const maxPasses =
        7; // Increased from 5 to allow more refinement with 40 words

    while (madeProgress && passCount < maxPasses && remaining.isNotEmpty) {
      madeProgress = false;
      passCount++;

      // MRV: Select word with fewest valid positions (most constrained)
      GeneratedWord? bestWord;
      var minMoves = double.infinity;

      for (final word in remaining) {
        final moveCount = domains[word]?.length ?? 0;
        if (moveCount > 0 && moveCount < minMoves) {
          minMoves = moveCount.toDouble();
          bestWord = word;
        }
      }

      if (bestWord == null) {
        // No word can be placed
        break;
      }

      // Get best move for this word
      final moves = domains[bestWord]!;
      if (moves.isEmpty) {
        remaining.remove(bestWord);
        domains.remove(bestWord);
        continue;
      }

      // Pick highest scoring move
      moves.sort((a, b) => b.score.compareTo(a.score));
      final bestMove = moves.first;

      // Place the word
      _place(bestWord, bestMove.x, bestMove.y, bestMove.isHorizontal, placed);
      remaining.remove(bestWord);
      domains.remove(bestWord);
      madeProgress = true;

      // Forward Checking: Update domains of remaining words
      // Remove moves that are now invalid due to the new placement
      for (final word in remaining) {
        final validMoves = domains[word];
        if (validMoves == null) {
          continue;
        }

        validMoves.removeWhere((move) {
          final score = _evaluatePlacement(
            word.answer,
            move.x,
            move.y,
            move.isHorizontal,
          );
          return score < 0; // Invalid after new placement
        });

        // If domain becomes empty, this word can't be placed anymore
        // But we continue trying others
      }
    }

    return placed;
  }

  /// Find all valid positions for a word (for MRV heuristic)
  List<_Move> _findAllValidMoves(String word) {
    final moves = <_Move>[];

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        // Try horizontal
        if (x + word.length <= width) {
          final score = _evaluatePlacement(word, x, y, true);
          if (score > 0) {
            moves.add(_Move(x, y, isHorizontal: true, score: score));
          }
        }

        // Try vertical
        if (y + word.length <= height) {
          final score = _evaluatePlacement(word, x, y, false);
          if (score > 0) {
            moves.add(_Move(x, y, isHorizontal: false, score: score));
          }
        }
      }
    }

    return moves;
  }

  /// Returns a score > 0 if valid.
  /// Score = Intersections + CompactnessBonus
  static const Map<String, Map<String, int>> _languageWeights = {
    'en': {
      'E': 1,
      'A': 1,
      'I': 1,
      'O': 1,
      'N': 1,
      'R': 1,
      'T': 1,
      'L': 1,
      'S': 1,
      'U': 1,
      'D': 2,
      'G': 2,
      'B': 3,
      'C': 3,
      'M': 3,
      'P': 3,
      'F': 4,
      'H': 4,
      'V': 4,
      'W': 4,
      'Y': 4,
      'K': 5,
      'J': 8,
      'X': 8,
      'Q': 10,
      'Z': 10,
    },
    'fr': {
      'E': 1,
      'A': 1,
      'I': 1,
      'N': 1,
      'R': 1,
      'T': 1,
      'S': 1,
      'U': 1,
      'L': 1,
      'O': 1,
      'D': 2,
      'G': 2,
      'M': 2,
      'B': 3,
      'C': 3,
      'P': 3,
      'F': 4,
      'H': 4,
      'V': 4,
      'J': 8,
      'Q': 8,
      'K': 10,
      'W': 10,
      'X': 10,
      'Y': 10,
      'Z': 10,
    },
    'es': {
      'A': 1,
      'E': 1,
      'O': 1,
      'S': 1,
      'I': 1,
      'R': 1,
      'N': 1,
      'L': 1,
      'T': 1,
      'D': 2,
      'G': 2,
      'C': 3,
      'B': 3,
      'M': 3,
      'P': 3,
      'F': 4,
      'H': 4,
      'V': 4,
      'Y': 4,
      'J': 8,
      'Ñ': 8,
      'Z': 10,
      'X': 10,
      'K': 10,
      'W': 10,
    },
    'de': {
      'E': 1,
      'N': 1,
      'R': 1,
      'I': 1,
      'S': 1,
      'T': 1,
      'A': 1,
      'H': 1,
      'D': 2,
      'U': 2,
      'L': 2,
      'C': 2,
      'M': 3,
      'G': 3,
      'W': 3,
      'O': 3,
      'Z': 3,
      'B': 4,
      'F': 4,
      'K': 4,
      'P': 4,
      'V': 4,
      'J': 6,
      'Y': 6,
      'X': 8,
      'Q': 10,
    },
    'it': {
      'A': 1,
      'E': 1,
      'I': 1,
      'O': 1,
      'C': 1,
      'R': 1,
      'S': 1,
      'T': 1,
      'L': 2,
      'M': 2,
      'N': 2,
      'U': 2,
      'P': 3,
      'B': 5,
      'D': 5,
      'F': 5,
      'G': 5,
      'V': 5,
      'H': 8,
      'Q': 10,
      'Z': 10,
    },
    'pt': {
      'A': 1,
      'E': 1,
      'I': 1,
      'O': 1,
      'S': 1,
      'U': 1,
      'M': 1,
      'R': 1,
      'T': 1,
      'D': 2,
      'L': 2,
      'C': 2,
      'P': 2,
      'N': 3,
      'B': 3,
      'G': 4,
      'V': 4,
      'F': 5,
      'H': 8,
      'J': 8,
      'X': 10,
      'Z': 10,
    },
    'uk': {
      'О': 1,
      'А': 1,
      'И': 1,
      'Е': 1,
      'Н': 1,
      'В': 1,
      'Р': 1,
      'Т': 1,
      'С': 1,
      'І': 1,
      'К': 2,
      'Л': 2,
      'Д': 2,
      'М': 2,
      'П': 2,
      'У': 3,
      'Я': 3,
      'Г': 3,
      'З': 3,
      'Ж': 4,
      'Б': 4,
      'Ь': 4,
      'Х': 4,
      'Ц': 4,
      'Й': 5,
      'Ч': 5,
      'Ю': 8,
      'Є': 8,
      'Щ': 8,
      'Ф': 10,
      'Ш': 10,
      'Ї': 10,
      'Ґ': 10,
    },
  };

  Map<String, int> _getWeights(String? lang) {
    final effectiveLang =
        lang?.toLowerCase() == 'ru' ? 'uk' : lang?.toLowerCase();
    return _languageWeights[effectiveLang] ?? _languageWeights['en']!;
  }

  /// Returns a score > 0 if valid.
  /// Score = WeightedIntersections - CenterDistancePenalty
  double _evaluatePlacement(String word, int x, int y, bool isHorizontal) {
    var intersections = 0;
    var weightedIntersectionScore = 0.0;

    // 1. Validity Check & Intersection Count
    for (var i = 0; i < word.length; i++) {
      final cx = isHorizontal ? x + i : x;
      final cy = isHorizontal ? y : y + i;
      final char = _grid[cy][cx];

      if (char == null) {
        if (!_isIsolated(cx, cy, isHorizontal)) {
          return -1; // Invalid
        }
      } else {
        if (char != word[i]) {
          return -1; // Mismatch
        }
        intersections++;
        // Boost score for difficult letters
        final weights = _getWeights(_currentLanguage);
        final weight = weights[char.toUpperCase()] ?? 1;
        weightedIntersectionScore +=
            weight * 15; // Multiplier to make it significant
      }
    }

    // Check Ends
    final beforeX = isHorizontal ? x - 1 : x;
    final beforeY = isHorizontal ? y : y - 1;
    if (isValid(beforeX, beforeY) && _grid[beforeY][beforeX] != null) {
      return -1;
    }

    final afterX = isHorizontal ? x + word.length : x;
    final afterY = isHorizontal ? y : y + word.length;
    if (isValid(afterX, afterY) && _grid[afterY][afterX] != null) {
      return -1;
    }

    // Constraint: Must intersect at least once (unless it's the very first word, but this func is for subsequent words)
    // Actually, in `_generateSinglePass`, we already placed the first word.
    // So all subsequent words MUST attach.
    if (intersections == 0) {
      return -1;
    }

    // 2. Score Calculation:
    // Removed Gravity Penalty to encourage using the full grid size provided by the user.
    // We want the puzzle to expand to the edges if possible.

    // Bonus for longer words (more letters = higher density contribution)
    final lengthBonus = word.length * 10.0;

    // Multi-intersection bonus: exponentially reward words that connect at multiple points
    // This creates a more "woven" structure that's harder to place words into gaps
    // Increased bonus to strongly favor multi-intersections
    final multiIntersectionBonus =
        intersections > 1
            ? intersections * intersections * 100.0
            : 0.0; // Doubled from 50

    // Final Score: Rewards hard intersections, long words, and multi-connections
    // We boost the base value of an intersection to ensure it's always worth it
    // Increased intersection base score from 200 to 300 to favor more crossings
    return weightedIntersectionScore +
        (intersections * 300.0) + // Increased from 200
        lengthBonus +
        multiIntersectionBonus;
  }

  /// Checks if placing a character at x,y (as part of a word flowing isHorizontal)
  /// violates adjacency rules with neighbors PERPENDICULAR to flow.
  ///
  /// If I am placing Horizontal at x,y.
  /// Neighbors at (x, y-1) and (x, y+1) must be empty.
  bool _isIsolated(int x, int y, bool isHorizontal) {
    if (isHorizontal) {
      // Check Top and Bottom
      if (isValid(x, y - 1) && _grid[y - 1][x] != null) {
        return false;
      }
      if (isValid(x, y + 1) && _grid[y + 1][x] != null) {
        return false;
      }
    } else {
      // Check Left and Right
      if (isValid(x - 1, y) && _grid[y][x - 1] != null) {
        return false;
      }
      if (isValid(x + 1, y) && _grid[y][x + 1] != null) {
        return false;
      }
    }
    return true;
  }

  bool isValid(int x, int y) => x >= 0 && x < width && y >= 0 && y < height;

  void _place(
    GeneratedWord word,
    int x,
    int y,
    bool isHorizontal,
    List<PlacedWord> placed,
  ) {
    for (var i = 0; i < word.answer.length; i++) {
      final cx = isHorizontal ? x + i : x;
      final cy = isHorizontal ? y : y + i;
      _grid[cy][cx] = word.answer[i];
    }
    placed.add(
      PlacedWord(word: word, startX: x, startY: y, isHorizontal: isHorizontal),
    );
  }
}

class _Move {
  _Move(this.x, this.y, {required this.isHorizontal, required this.score});

  final int x;
  final int y;
  final bool isHorizontal;
  final double score;
}
