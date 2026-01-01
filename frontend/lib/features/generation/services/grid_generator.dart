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
  List<PlacedWord> generate(List<GeneratedWord> words) {
    // Sort words by length descending (longest first)
    final sortedWords = List<GeneratedWord>.from(words)
      ..sort((a, b) => b.answer.length.compareTo(a.answer.length));

    // If only one word, place it in the center horizontally
    if (sortedWords.isEmpty) {
      return [];
    }

    // Place the first (longest) word in the center
    final first = sortedWords.first;
    final startX = (width - first.answer.length) ~/ 2;
    final startY = height ~/ 2;

    final placed = <PlacedWord>[];

    // Attempt to place first word horizontally
    if (_checkPlacement(first.answer, startX, startY, true) != -1) {
      _place(first, startX, startY, true, placed);
      sortedWords.removeAt(0);
    } else {
      // Should not happen for first word unless it's too big
      return [];
    }

    // Re-check valid first placement (should always be true if grid big enough)
    // Actually the logic above for _place is correct.
    // But original code had logic to check placement.
    // Let's revert to original logic but with sortedWords defined FIRST.

    // Try to place remaining words
    // We iterate multiple passes or until no words can be added
    var addedSomething = true;
    while (addedSomething && sortedWords.isNotEmpty) {
      addedSomething = false;

      // Try to place each remaining word
      for (var i = 0; i < sortedWords.length; i++) {
        final candidate = sortedWords[i];

        final bestMove = _findBestMove(candidate.answer);
        if (bestMove != null) {
          _place(
            candidate,
            bestMove.x,
            bestMove.y,
            bestMove.isHorizontal,
            placed,
          );
          sortedWords.removeAt(i);
          addedSomething = true;
          break; // Restart loop to prioritize best fits again with new grid state
        }
      }
    }

    return placed;
  }

  /// Finds the best position for a word.
  /// "Best" is defined as:
  /// 1. Valid placement.
  /// 2. Maximizes intersections.
  _Move? _findBestMove(String word) {
    _Move? bestMove;
    var maxIntersections = -1;

    // Iterate over every cell
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        // Try horizontal
        if (x + word.length <= width) {
          final intersections = _checkPlacement(word, x, y, true);
          // We need at least 1 intersection to attach to the puzzle (unless it's the 1st word, handled separately)
          // But strict strict: > 0
          if (intersections > maxIntersections && intersections > 0) {
            maxIntersections = intersections;
            bestMove = _Move(x, y, isHorizontal: true);
          }
        }

        // Try vertical
        if (y + word.length <= height) {
          final intersections = _checkPlacement(word, x, y, false);
          if (intersections > maxIntersections && intersections > 0) {
            maxIntersections = intersections;
            bestMove = _Move(x, y, isHorizontal: false);
          }
        }
      }
    }

    return bestMove;
  }

  /// Returns number of intersections if valid, or -1 if invalid.
  int _checkPlacement(String word, int x, int y, bool isHorizontal) {
    if (isHorizontal) {
      if (x + word.length > width) {
        return -1;
      }
    } else {
      if (y + word.length > height) {
        return -1;
      }
    }

    var intersections = 0;

    // Check cells
    for (var i = 0; i < word.length; i++) {
      final cx = isHorizontal ? x + i : x;
      final cy = isHorizontal ? y : y + i;
      final char = _grid[cy][cx];

      if (char == null) {
        // Empty cell.
        // Must ensure NO adjacency issues.
        // If we place char here, we must make sure we don't accidentally touch another word
        // perpendicular to us (unless we are intersecting it, which is handled by char != null)
        if (!_isIsolated(cx, cy, isHorizontal)) {
          return -1;
        }
      } else {
        // Occupied cell.
        // Must match.
        if (char != word[i]) {
          return -1; // mismatch
        }
        intersections++;
      }
    }

    // Check Before and After the word (must be empty/bound)
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

    return intersections;
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
  _Move(this.x, this.y, {required this.isHorizontal});

  final int x;
  final int y;
  final bool isHorizontal;
}
