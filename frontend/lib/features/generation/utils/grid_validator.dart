import 'package:croiz/features/generation/models/placed_word.dart';

class GridValidationResult {
  GridValidationResult({required this.isValid, this.errors = const []});

  final bool isValid;
  final List<String> errors;

  @override
  String toString() =>
      'GridValidationResult(isValid: $isValid, errors: $errors)';
}

class GridValidator {
  static GridValidationResult validate(
    List<PlacedWord> placed,
    int width,
    int height,
  ) {
    final errors = <String>[];

    if (placed.isEmpty) {
      return GridValidationResult(isValid: true);
    }

    // 1. Bounds Check
    for (final pw in placed) {
      if (pw.startX < 0 || pw.startY < 0) {
        errors.add(
          'Word "${pw.word.answer}" is out of bounds (negative start)',
        );
        continue;
      }
      final endX =
          pw.isHorizontal ? pw.startX + pw.word.answer.length : pw.startX + 1;
      final endY =
          pw.isHorizontal ? pw.startY + 1 : pw.startY + pw.word.answer.length;

      if (endX > width || endY > height) {
        errors.add(
          'Word "${pw.word.answer}" exceeds grid dimensions ($width x $height)',
        );
      }
    }

    // 2. Build Grid & Collision Check
    final grid = List.generate(
      height,
      (_) => List<String?>.filled(width, null),
    );
    for (final pw in placed) {
      for (var i = 0; i < pw.word.answer.length; i++) {
        final x = pw.isHorizontal ? pw.startX + i : pw.startX;
        final y = pw.isHorizontal ? pw.startY : pw.startY + i;

        if (x < 0 || x >= width || y < 0 || y >= height) {
          continue;
        }

        final char = pw.word.answer[i];
        if (grid[y][x] != null && grid[y][x] != char) {
          errors.add('Collision at ($x, $y): "${grid[y][x]}" vs "$char"');
        }
        grid[y][x] = char;
      }
    }

    // 3. Strict Adjacency Check (No accidental words)
    // For every filled cell, check all 4 neighbors.
    // Neighbors must be part of a word that includes the current cell in that direction.
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (grid[y][x] == null) {
          continue;
        }

        // Check horizontal adjacency
        if (x + 1 < width && grid[y][x + 1] != null) {
          // Are (x,y) and (x+1,y) part of the same horizontal word?
          final inSameWord = placed.any(
            (pw) =>
                pw.isHorizontal &&
                pw.startY == y &&
                x >= pw.startX &&
                (x + 1) < (pw.startX + pw.word.answer.length),
          );
          if (!inSameWord) {
            errors.add(
              'Illegal horizontal adjacency at ($x, $y) and (${x + 1}, $y)',
            );
          }
        }

        // Check vertical adjacency
        if (y + 1 < height && grid[y + 1][x] != null) {
          // Are (x,y) and (x,y+1) part of the same vertical word?
          final inSameWord = placed.any(
            (pw) =>
                !pw.isHorizontal &&
                pw.startX == x &&
                y >= pw.startY &&
                (y + 1) < (pw.startY + pw.word.answer.length),
          );
          if (!inSameWord) {
            errors.add(
              'Illegal vertical adjacency at ($x, $y) and ($x, ${y + 1})',
            );
          }
        }
      }
    }

    // 4. Connectivity Check (All words must be connected)
    final connected = _checkConnectivity(grid, width, height);
    if (!connected && placed.length > 1) {
      errors.add('The puzzle is not fully connected (islands detected)');
    }

    return GridValidationResult(
      isValid: errors.isEmpty,
      errors: errors.toSet().toList(), // Remove duplicates
    );
  }

  static bool _checkConnectivity(
    List<List<String?>> grid,
    int width,
    int height,
  ) {
    // Find first filled cell
    int? startX, startY;
    var totalFilled = 0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (grid[y][x] != null) {
          totalFilled++;
          if (startX == null) {
            startX = x;
            startY = y;
          }
        }
      }
    }

    if (totalFilled == 0) {
      return true;
    }

    // BFS to count reachable filled cells
    final visited = <String>{};
    final queue = [
      [startX!, startY!],
    ];
    visited.add('$startX,$startY');

    var reachableCount = 0;
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      reachableCount++;

      final cx = current[0];
      final cy = current[1];

      // Neighbors
      final neighbors = [
        [cx + 1, cy],
        [cx - 1, cy],
        [cx, cy + 1],
        [cx, cy - 1],
      ];

      for (final n in neighbors) {
        final nx = n[0];
        final ny = n[1];
        if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
          if (grid[ny][nx] != null && !visited.contains('$nx,$ny')) {
            visited.add('$nx,$ny');
            queue.add([nx, ny]);
          }
        }
      }
    }

    return reachableCount == totalFilled;
  }
}
