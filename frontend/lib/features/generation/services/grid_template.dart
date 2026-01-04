import 'dart:math';

import 'package:croiz/features/generation/models/slot.dart';

/// Generator for symmetric crossword grid templates.
///
/// Creates grid templates with black squares placed according to
/// crossword construction standards (180° rotational symmetry,
/// connectivity, minimum word length).
class GridTemplateGenerator {
  GridTemplateGenerator({
    required this.width,
    required this.height,
    this.targetBlackRatio = 0.22, // Compromise: aesthetic vs fillable
    this.minWordLength = 3,
    Random? random,
  }) : _random = random ?? Random();

  final int width;
  final int height;
  final double targetBlackRatio;
  final int minWordLength;
  final Random _random;

  /// Generate a symmetric grid template.
  ///
  /// Returns a 2D list where `true` = black square, `false` = white square.
  List<List<bool>> generate() {
    final grid = List.generate(height, (_) => List.filled(width, false));
    final targetBlacks = (width * height * targetBlackRatio / 2).round();
    var placedBlacks = 0;
    var attempts = 0;
    const maxAttempts = 2000;

    // Use grid zones for better distribution
    final zones = _generateZonePositions();
    var zoneIndex = 0;

    while (placedBlacks < targetBlacks && attempts < maxAttempts) {
      attempts++;

      int x, y;
      if (zoneIndex < zones.length && _random.nextDouble() < 0.7) {
        // 70% chance to use zone-based placement for better distribution
        final zone = zones[zoneIndex % zones.length];
        x = zone.x + _random.nextInt(3).clamp(0, (width ~/ 2) - zone.x);
        y = zone.y + _random.nextInt(3).clamp(0, height - 1 - zone.y);
        zoneIndex++;
      } else {
        // Random placement in first half
        x = _random.nextInt((width + 1) ~/ 2);
        y = _random.nextInt(height);
      }

      // Clamp to valid range
      x = x.clamp(0, (width - 1) ~/ 2);
      y = y.clamp(0, height - 1);

      // Skip if already black
      if (grid[y][x]) {
        continue;
      }

      // Calculate symmetric position (180° rotation)
      final symX = width - 1 - x;
      final symY = height - 1 - y;

      // Check anti-clustering before placing
      if (_wouldCreateCluster(grid, x, y) ||
          (symX != x || symY != y) && _wouldCreateCluster(grid, symX, symY)) {
        continue;
      }

      // Temporarily place blacks
      grid[y][x] = true;
      if (symX != x || symY != y) {
        grid[symY][symX] = true;
      }

      // Validate placement
      if (_isValidPlacement(grid)) {
        placedBlacks++;
      } else {
        // Revert
        grid[y][x] = false;
        if (symX != x || symY != y) {
          grid[symY][symX] = false;
        }
      }
    }

    return grid;
  }

  /// Generate zone positions for better black square distribution.
  List<Point<int>> _generateZonePositions() {
    final zones = <Point<int>>[];
    const zoneSize = 4;

    for (var zy = 1; zy < height - 1; zy += zoneSize) {
      for (var zx = 1; zx < (width ~/ 2); zx += zoneSize) {
        zones.add(Point(zx, zy));
      }
    }

    // Shuffle zones for variety
    zones.shuffle(_random);
    return zones;
  }

  /// Check if placing a black square at (x, y) would create a bad cluster.
  /// Based on real puzzle analysis: professional puzzles allow linear runs
  /// of 3+ blacks but avoid large 2x2 solid blocks.
  bool _wouldCreateCluster(List<List<bool>> grid, int x, int y) {
    // Check for 2x2 block (this is the main thing to avoid)
    // Check all 4 possible 2x2 blocks that would include (x, y)
    for (var dy = -1; dy <= 0; dy++) {
      for (var dx = -1; dx <= 0; dx++) {
        var blockCount = 0;
        for (var by = 0; by <= 1; by++) {
          for (var bx = 0; bx <= 1; bx++) {
            final nx = x + dx + bx;
            final ny = y + dy + by;
            if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
              if ((nx == x && ny == y) || grid[ny][nx]) {
                blockCount++;
              }
            }
          }
        }
        // Reject if this would create a 2x2 solid black block
        if (blockCount >= 4) {
          return true;
        }
      }
    }

    return false;
  }

  /// Generate a template with predefined pattern style.
  List<List<bool>> generateWithStyle(TemplateStyle style) {
    switch (style) {
      case TemplateStyle.open:
        return _generateOpenStyle();
      case TemplateStyle.checkerboard:
        return _generateCheckerboardStyle();
      case TemplateStyle.diagonal:
        return _generateDiagonalStyle();
      case TemplateStyle.random:
        return generate();
    }
  }

  /// Open style - minimal blacks, mostly open grid
  List<List<bool>> _generateOpenStyle() {
    final grid = List.generate(height, (_) => List.filled(width, false));

    // Place blacks only at specific intervals
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        // Place blacks at 5-cell intervals, symmetric
        if (x > 0 && x < width - 1 && y > 0 && y < height - 1) {
          if (x % 5 == 0 && y % 5 == 0) {
            final symX = width - 1 - x;
            final symY = height - 1 - y;
            grid[y][x] = true;
            grid[symY][symX] = true;
          }
        }
      }
    }

    return grid;
  }

  /// Checkerboard-influenced pattern
  List<List<bool>> _generateCheckerboardStyle() {
    final grid = List.generate(height, (_) => List.filled(width, false));

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        // Sparse checkerboard at 6-cell intervals
        if ((x + y) % 6 == 0 &&
            x > 0 &&
            x < width - 1 &&
            y > 0 &&
            y < height - 1) {
          final symX = width - 1 - x;
          final symY = height - 1 - y;
          grid[y][x] = true;
          if (symX != x || symY != y) {
            grid[symY][symX] = true;
          }
        }
      }
    }

    return grid;
  }

  /// Diagonal stripe pattern
  List<List<bool>> _generateDiagonalStyle() {
    final grid = List.generate(height, (_) => List.filled(width, false));

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        // Diagonal stripes at intervals
        if ((x - y).abs() % 7 == 0 &&
            x > 0 &&
            x < width - 1 &&
            y > 0 &&
            y < height - 1) {
          final symX = width - 1 - x;
          final symY = height - 1 - y;

          // Only place if it doesn't create short words
          final candidate = List.generate(
            height,
            (cy) => List.generate(width, (cx) => grid[cy][cx]),
          );
          candidate[y][x] = true;
          if (symX != x || symY != y) {
            candidate[symY][symX] = true;
          }

          if (_isValidPlacement(candidate)) {
            grid[y][x] = true;
            if (symX != x || symY != y) {
              grid[symY][symX] = true;
            }
          }
        }
      }
    }

    return grid;
  }

  /// Validate that a grid template is valid:
  /// - All white squares connected
  /// - No words shorter than minWordLength
  /// - No full black rows/columns
  bool _isValidPlacement(List<List<bool>> grid) {
    // Check minimum word lengths
    if (!_checkMinWordLengths(grid)) {
      return false;
    }

    // Check connectivity
    if (!_checkConnectivity(grid)) {
      return false;
    }

    // Check quadrant balance to avoid "leaning" grids
    if (!_checkQuadrantBalance(grid)) {
      return false;
    }

    return true;
  }

  /// Check that the grid is roughly balanced between quadrants.
  /// With 180° symmetry, we only need to compare Top-Left vs Top-Right
  /// (since TL=BR and TR=BL).
  bool _checkQuadrantBalance(List<List<bool>> grid) {
    var tlCount = 0;
    var trCount = 0;

    final midX = width ~/ 2;
    final midY = height ~/ 2;

    for (var y = 0; y < midY; y++) {
      for (var x = 0; x < midX; x++) {
        if (grid[y][x]) {
          tlCount++;
        }
      }
      for (var x = width - midX; x < width; x++) {
        if (grid[y][x]) {
          trCount++;
        }
      }
    }

    // Allow a small difference (e.g., 3 black squares)
    // If difference is large, it looks unbalanced.
    return (tlCount - trCount).abs() <= 3;
  }

  /// Check that all word slots are at least minWordLength
  bool _checkMinWordLengths(List<List<bool>> grid) {
    // Check horizontal words
    for (var y = 0; y < height; y++) {
      var runLength = 0;
      for (var x = 0; x <= width; x++) {
        final isBlack = x >= width || grid[y][x];
        if (!isBlack) {
          runLength++;
        } else {
          if (runLength > 0 && runLength < minWordLength) {
            return false;
          }
          runLength = 0;
        }
      }
    }

    // Check vertical words
    for (var x = 0; x < width; x++) {
      var runLength = 0;
      for (var y = 0; y <= height; y++) {
        final isBlack = y >= height || grid[y][x];
        if (!isBlack) {
          runLength++;
        } else {
          if (runLength > 0 && runLength < minWordLength) {
            return false;
          }
          runLength = 0;
        }
      }
    }

    return true;
  }

  /// Check if all white squares are connected using BFS.
  bool _checkConnectivity(List<List<bool>> grid) {
    Point<int>? start;
    var totalWhite = 0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (!grid[y][x]) {
          start ??= Point(x, y);
          totalWhite++;
        }
      }
    }

    if (start == null) {
      return true; // All black squares is trivially connected
    }

    final visited = <Point<int>>{};
    final queue = [start];
    visited.add(start);

    var count = 0;
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      count++;

      // Neighbors
      final neighbors = [
        Point(current.x + 1, current.y),
        Point(current.x - 1, current.y),
        Point(current.x, current.y + 1),
        Point(current.x, current.y - 1),
      ];

      for (final n in neighbors) {
        if (n.x >= 0 && n.x < width && n.y >= 0 && n.y < height) {
          if (!grid[n.y][n.x] && !visited.contains(n)) {
            visited.add(n);
            queue.add(n);
          }
        }
      }
    }

    return count == totalWhite;
  }

  /// Validate an existing grid template
  bool validateTemplate(List<List<bool>> grid) => _isValidPlacement(grid);
}

/// Predefined template styles
enum TemplateStyle {
  /// Minimal black squares, very open
  open,

  /// Checkerboard-influenced pattern
  checkerboard,

  /// Diagonal stripe pattern
  diagonal,

  /// Random placement
  random,
}

/// Extract word slots from a grid template.
class SlotExtractor {
  /// Extract all word slots from a grid template.
  ///
  /// [blackSquares] is a 2D list where `true` = black, `false` = white.
  /// Returns all horizontal and vertical slots with length >= minLength.
  static List<Slot> extractSlots(
    List<List<bool>> blackSquares, {
    int minLength = 3,
  }) {
    final slots = <Slot>[];
    final height = blackSquares.length;
    if (height == 0) {
      return slots;
    }
    final width = blackSquares[0].length;

    var slotNumber = 1;

    // Extract horizontal slots
    for (var y = 0; y < height; y++) {
      var startX = -1;
      for (var x = 0; x <= width; x++) {
        final isBlack = x >= width || blackSquares[y][x];
        if (!isBlack && startX == -1) {
          startX = x; // Start of slot
        } else if (isBlack && startX != -1) {
          final length = x - startX;
          if (length >= minLength) {
            slots.add(
              Slot(
                id: '${slotNumber++}A',
                startX: startX,
                startY: y,
                isHorizontal: true,
                length: length,
              ),
            );
          }
          startX = -1;
        }
      }
    }

    // Extract vertical slots
    for (var x = 0; x < width; x++) {
      var startY = -1;
      for (var y = 0; y <= height; y++) {
        final isBlack = y >= height || blackSquares[y][x];
        if (!isBlack && startY == -1) {
          startY = y; // Start of slot
        } else if (isBlack && startY != -1) {
          final length = y - startY;
          if (length >= minLength) {
            slots.add(
              Slot(
                id: '${slotNumber++}D',
                startX: x,
                startY: startY,
                isHorizontal: false,
                length: length,
              ),
            );
          }
          startY = -1;
        }
      }
    }

    return slots;
  }

  /// Build a map of slot intersections.
  ///
  /// Returns a map where each slot is mapped to its intersecting slots
  /// along with the intersection details.
  static Map<Slot, List<IntersectionPoint>> buildIntersectionMap(
    List<Slot> slots,
  ) {
    final map = <Slot, List<IntersectionPoint>>{};

    for (final slot in slots) {
      map[slot] = [];
    }

    for (var i = 0; i < slots.length; i++) {
      for (var j = i + 1; j < slots.length; j++) {
        final intersection = slots[i].getIntersection(slots[j]);
        if (intersection != null) {
          map[slots[i]]!.add(intersection);
          // Add reverse reference
          final reverseIntersection = slots[j].getIntersection(slots[i]);
          if (reverseIntersection != null) {
            map[slots[j]]!.add(reverseIntersection);
          }
        }
      }
    }

    return map;
  }
}
