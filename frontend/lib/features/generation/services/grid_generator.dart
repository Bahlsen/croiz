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

  /// Main entry point: attempts to place as many words as possible.
  /// Uses a random restart strategy to find the best layout.
  List<PlacedWord> generate(List<GeneratedWord> words, {int attempts = 100}) {
    if (words.isEmpty) {
      return [];
    }

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

      // Pick one of the top 3 as start (or fewer if list small)
      // Then shuffle the rest
      if (shuffled.length > 3) {
        final top = shuffled.sublist(0, 3)..shuffle();
        final rest = shuffled.sublist(3)..shuffle();
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
    // Word Count is King.
    // Density is Queen.
    return (wordCount * 1000.0) + (density * 100.0);
  }

  /// Single pass generation logic with multi-pass retry for rejected words
  List<PlacedWord> _generateSinglePass(List<GeneratedWord> words) {
    // We work on a temp grid by clearing the current one first
    // Since we run this sequentially in loop, we reuse the class _grid
    _resetGrid();

    if (words.isEmpty) {
      return [];
    }

    final placed = <PlacedWord>[];
    var remaining = List<GeneratedWord>.from(words);
    final rejected = <GeneratedWord>[]; // Words we couldn't place this round

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

    // Multi-pass placement: keep trying until no progress is made
    var madeProgress = true;
    var passCount = 0;
    const maxPasses = 5; // Limit total passes to avoid infinite loops

    while (madeProgress && passCount < maxPasses) {
      madeProgress = false;
      passCount++;
      rejected.clear();

      while (remaining.isNotEmpty) {
        _Move? globalBestMove;
        GeneratedWord? bestWord;
        var bestWordIndex = -1;

        for (var i = 0; i < remaining.length; i++) {
          final candidate = remaining[i];
          final move = _findBestMoveForWord(candidate.answer);

          if (move != null) {
            if (globalBestMove == null || move.score > globalBestMove.score) {
              globalBestMove = move;
              bestWord = candidate;
              bestWordIndex = i;
            }
          }
        }

        if (globalBestMove != null && bestWord != null) {
          _place(
            bestWord,
            globalBestMove.x,
            globalBestMove.y,
            globalBestMove.isHorizontal,
            placed,
          );
          remaining.removeAt(bestWordIndex);
          madeProgress = true;
        } else {
          // No word from remaining could be placed; move all to rejected
          rejected.addAll(remaining);
          remaining.clear();
        }
      }

      // Retry rejected words in the next pass (new intersections may exist now)
      if (rejected.isNotEmpty && madeProgress) {
        remaining = List<GeneratedWord>.from(rejected);
      }
    }

    return placed;
  }

  /// Finds the best position for a specific word on the current grid.
  _Move? _findBestMoveForWord(String word) {
    _Move? bestMove;
    var maxScore = -1.0;

    // Iterate over every cell
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        // Try horizontal
        if (x + word.length <= width) {
          final score = _evaluatePlacement(word, x, y, true);
          if (score > maxScore) {
            maxScore = score;
            bestMove = _Move(x, y, isHorizontal: true, score: score);
          }
        }

        // Try vertical
        if (y + word.length <= height) {
          final score = _evaluatePlacement(word, x, y, false);
          if (score > maxScore) {
            maxScore = score;
            bestMove = _Move(x, y, isHorizontal: false, score: score);
          }
        }
      }
    }

    return bestMove;
  }

  /// Returns a score > 0 if valid.
  /// Score = Intersections + CompactnessBonus
  // Scrabble-like weights for letters (English/French mix approximation)
  static const Map<String, int> _letterWeights = {
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
    'M': 3,
    'B': 3,
    'C': 3,
    'P': 3,
    'F': 4,
    'H': 4,
    'V': 4,
    'J': 8,
    'Q': 10,
    'K': 5,
    'W': 4,
    'X': 8,
    'Y': 4,
    'Z': 10,
  };

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
        final weight = _letterWeights[char.toUpperCase()] ?? 1;
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
    final multiIntersectionBonus =
        intersections > 1 ? intersections * intersections * 50.0 : 0.0;

    // Final Score: Rewards hard intersections, long words, and multi-connections
    // We boost the base value of an intersection to ensure it's always worth it
    return weightedIntersectionScore +
        (intersections * 200.0) +
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
