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

/// A rudimentary crossword grid generator.
class GridGenerator {
  GridGenerator({required this.width, required this.height})
    : _grid = List.generate(height, (_) => List.filled(width, null));

  final int width;
  final int height;
  final List<List<String?>> _grid; // null = empty, char = filled

  /// Main entry point: attempts to place as many words as possible.
  /// Uses a random restart strategy to find the best layout.
  List<PlacedWord> generate(List<GeneratedWord> words, {int attempts = 50}) {
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

  /// Single pass generation logic
  List<PlacedWord> _generateSinglePass(List<GeneratedWord> words) {
    // We work on a temp grid by clearing the current one first
    // Since we run this sequentially in loop, we reuse the class _grid
    _resetGrid();

    if (words.isEmpty) {
      return [];
    }

    final placed = <PlacedWord>[];
    final remaining = List<GeneratedWord>.from(words);

    // Place the first word in the center
    final first = remaining.removeAt(0);
    final startX = (width - first.answer.length) ~/ 2;
    final startY = height ~/ 2;

    // Check if it fits
    // Note: _evaluatePlacement checks invalid placements and returns -1.0.
    // It also checks for intersections > 0 usually, but for the first word,
    // we must allow 0 intersections (since grid is empty).
    // So we need a special check or modify _evaluatePlacement.
    // _evaluatePlacement returns -1.0 if invalid.
    // BUT it explicitly returns -1.0 if intersections == 0.
    // So for the first word, we can't use it directly if it enforces intersections.

    // Let's modify _evaluatePlacement to have an optional flag `allowNoIntersections`.
    // Or just manually check bounds here.

    if (startX < 0 || startX + first.answer.length > width) {
      return [];
    }
    // Only Horizontal check needed as we place horizontally.

    _place(first, startX, startY, true, placed);

    var addedSomething = true;
    while (addedSomething && remaining.isNotEmpty) {
      addedSomething = false;

      // In this pass, we try to place the NEXT word in the shuffled list
      // Instead of iterating all remaining words for the best slot (Generic Greedy),
      // let's iterate all remaining words and find the GLOBAL best move among them.
      // This is slightly more expensive O(N_remaining * GridSize) but better results.

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
        addedSomething = true;
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
  double _evaluatePlacement(String word, int x, int y, bool isHorizontal) {
    var intersections = 0;

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

    // 2. Score Calculation
    // Base score: Intersections (High is good)
    // Penalty: Distance from center (Keep it compact) ?
    // Actually, simpler is check how many Neighbors it effectively has.

    // Use a simple metric: Intersections squared (reward high connectivity heavily)
    final connectivityScore = (intersections * intersections).toDouble();

    return connectivityScore;
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
