import 'dart:convert';

import 'package:croiz/features/generation/utils/puzzle_converter.dart';
import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/features/game/services/incorrect_letter_cleaner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Performance tests focused on threading and compute-intensive operations.
/// These tests measure operations that could benefit from isolates.
void main() {
  group('Threading Performance Tests', () {
    // Create a larger puzzle for realistic performance testing
    late String largeJsonString;
    late Map<String, dynamic> largeJsonData;
    late Puzzle largePuzzle;

    setUpAll(() {
      // Generate a 15x15 puzzle (standard crossword size)
      largeJsonString = _generateLargePuzzleJson(15);
      largeJsonData = jsonDecode(largeJsonString) as Map<String, dynamic>;
      largePuzzle = Puzzle.fromJson(largeJsonData);
    });

    test('JSON parsing time on main thread', () {
      const iterations = 50;

      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        jsonDecode(largeJsonString);
      }
      stopwatch.stop();

      final avgMicros = stopwatch.elapsedMicroseconds / iterations;
      debugPrint('JSON parse (15x15): ${avgMicros.toStringAsFixed(2)}µs avg');

      // JSON parsing should be under 1ms per puzzle
      expect(avgMicros, lessThan(1000));
    });

    test('Puzzle.fromJson time on main thread', () {
      const iterations = 50;

      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        Puzzle.fromJson(largeJsonData);
      }
      stopwatch.stop();

      final avgMicros = stopwatch.elapsedMicroseconds / iterations;
      debugPrint(
        'Puzzle.fromJson (15x15): ${avgMicros.toStringAsFixed(2)}µs avg',
      );

      // Model deserialization should be under 1ms
      expect(avgMicros, lessThan(1000));
    });

    test('PuzzleConverter.puzzleToGameBoard time', () {
      const iterations = 50;

      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        PuzzleConverter.puzzleToGameBoard(largePuzzle);
      }
      stopwatch.stop();

      final avgMicros = stopwatch.elapsedMicroseconds / iterations;
      debugPrint(
        'PuzzleConverter (15x15): ${avgMicros.toStringAsFixed(2)}µs avg',
      );

      // Conversion should be under 2ms (main bottleneck)
      expect(avgMicros, lessThan(2000));
    });

    test('Full puzzle loading pipeline time', () {
      const iterations = 20;

      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        final json = jsonDecode(largeJsonString) as Map<String, dynamic>;
        final puzzle = Puzzle.fromJson(json);
        PuzzleConverter.puzzleToGameBoard(puzzle);
      }
      stopwatch.stop();

      final avgMicros = stopwatch.elapsedMicroseconds / iterations;
      final avgMs = avgMicros / 1000;
      debugPrint('Full pipeline (15x15): ${avgMs.toStringAsFixed(2)}ms avg');

      // Full pipeline should complete in under 5ms (one frame = 16ms)
      expect(avgMicros, lessThan(5000));
    });

    test('IncorrectLetterCleaner performance on large grid', () {
      final board = PuzzleConverter.puzzleToGameBoard(largePuzzle);

      // Fill grid with some letters (simulating in-progress game)
      final filledGrid = List.generate(
        board.gridSize,
        (r) => List.generate(
          board.gridSize,
          (c) => board.blackCells[r][c] ? null : 'X',
        ),
      );
      final filledBoard = board.copyWith(grid: filledGrid);

      const iterations = 100;
      const cleaner = IncorrectLetterCleaner();

      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        cleaner.cleanWithResult(filledBoard);
      }
      stopwatch.stop();

      final avgMicros = stopwatch.elapsedMicroseconds / iterations;
      debugPrint(
        'IncorrectLetterCleaner (15x15): ${avgMicros.toStringAsFixed(2)}µs avg',
      );

      // Cleaning should be under 1ms
      expect(avgMicros, lessThan(1000));
    });

    test('compute() overhead measurement', () async {
      // Measure compute() overhead for small operations
      const iterations = 10;

      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        await compute(_simpleComputation, largeJsonString);
      }
      stopwatch.stop();

      final avgMicros = stopwatch.elapsedMicroseconds / iterations;
      debugPrint('compute() overhead: ${avgMicros.toStringAsFixed(2)}µs avg');

      // Compute has overhead; small ops shouldn't use it
      // Just documenting the overhead here
    });

    test('Large grid operations batch timing', () {
      // Test rapid grid operations (like during gameplay)
      final board = PuzzleConverter.puzzleToGameBoard(largePuzzle);

      const operations = 100;
      final stopwatch = Stopwatch()..start();

      var current = board;
      for (var i = 0; i < operations; i++) {
        final row = i % board.gridSize;
        final col = (i * 7) % board.gridSize; // Spread across grid
        if (!current.blackCells[row][col]) {
          final newGrid = List<List<String?>>.generate(
            current.gridSize,
            (r) => List<String?>.from(current.grid[r]),
          );
          newGrid[row][col] = 'A';
          current = current.copyWith(grid: newGrid);
        }
      }
      stopwatch.stop();

      final avgMicros = stopwatch.elapsedMicroseconds / operations;
      debugPrint(
        'Grid copy+update (15x15): ${avgMicros.toStringAsFixed(2)}µs avg',
      );

      // Each grid update should be well under 1ms
      expect(avgMicros, lessThan(500));
    });
  });
}

/// Simple computation for measuring compute() overhead.
int _simpleComputation(String input) => input.length;

/// Generate a synthetic puzzle JSON for performance testing.
String _generateLargePuzzleJson(int size) {
  final cells = <Map<String, dynamic>>[];
  final entries = <Map<String, dynamic>>[];

  // Create grid cells with checkerboard black pattern
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final isBlack = (x + y) % 7 == 0; // Sparse black cells
      cells.add({
        'x': x,
        'y': y,
        'isBlack': isBlack,
        'solution': isBlack ? null : 'A',
      });
    }
  }

  // Create entries (words)
  var number = 1;
  for (var y = 0; y < size; y++) {
    var acrossStart = -1;
    for (var x = 0; x <= size; x++) {
      final isBlack = x == size || (x + y) % 7 == 0;
      if (!isBlack && acrossStart == -1) {
        acrossStart = x;
      } else if (isBlack && acrossStart != -1) {
        final length = x - acrossStart;
        if (length >= 2) {
          entries.add({
            'number': number++,
            'direction': 'across',
            'x': acrossStart,
            'y': y,
            'length': length,
            'clue': 'Clue for word $number across',
            'answer': 'A' * length,
          });
        }
        acrossStart = -1;
      }
    }
  }

  for (var x = 0; x < size; x++) {
    var downStart = -1;
    for (var y = 0; y <= size; y++) {
      final isBlack = y == size || (x + y) % 7 == 0;
      if (!isBlack && downStart == -1) {
        downStart = y;
      } else if (isBlack && downStart != -1) {
        final length = y - downStart;
        if (length >= 2) {
          entries.add({
            'number': number++,
            'direction': 'down',
            'x': x,
            'y': downStart,
            'length': length,
            'clue': 'Clue for word $number down',
            'answer': 'A' * length,
          });
        }
        downStart = -1;
      }
    }
  }

  return jsonEncode({
    'id': 'perf_test_puzzle',
    'rows': size,
    'cols': size,
    'cells': cells,
    'entries': entries,
  });
}
