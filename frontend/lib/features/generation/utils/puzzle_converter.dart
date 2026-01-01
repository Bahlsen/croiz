import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:flutter/foundation.dart';

/// Converts a Puzzle model (from JSON) to a GameBoard entity (used by the UI).
class PuzzleConverter {
  /// Convert Puzzle to GameBoard.
  /// - Builds the grid and blackCells matrices from puzzle.cells.
  /// - Extracts clues from puzzle.entries.
  static GameBoard puzzleToGameBoard(
    Puzzle puzzle, {
    bool preFillSolutions = false,
  }) {
    final rows = puzzle.rows;
    final cols = puzzle.cols;

    // Initialize empty grid, blackCells and solutionGrid
    final grid = List.generate(rows, (_) => List<String?>.filled(cols, null));
    final blackCells = List.generate(
      rows,
      (_) => List<bool>.filled(cols, false),
    );
    final solutionGrid = List.generate(
      rows,
      (_) => List<String?>.filled(cols, null),
    );

    // Fill grid and blackCells from puzzle.cells
    for (final cell in puzzle.cells) {
      if (cell.y < 0 || cell.y >= rows || cell.x < 0 || cell.x >= cols) {
        continue; // skip out-of-bounds cells
      }
      blackCells[cell.y][cell.x] = cell.isBlack;
      // Optionally pre-fill solutions for testing
      if (cell.solution != null) {
        solutionGrid[cell.y][cell.x] = cell.solution!.toUpperCase();
      }
      if (preFillSolutions && !cell.isBlack && cell.solution != null) {
        grid[cell.y][cell.x] = cell.solution!.toUpperCase();
      }
    }

    // Build clues map from entries (key: "number-direction" -> clue text)
    // Note: `entry.answer` may be null for some puzzles (partial imports
    // or datasets without solutions). Downstream code (word checking,
    // scoring, saving) should tolerate missing `answer` values and
    // fallback to behavior based on filled cells when appropriate.
    // Also: some puzzle files contain entries whose declared `length`
    // crosses black cells or goes out of bounds. To avoid inconsistent
    // entries (which prevent completion detection), sanitize each entry
    // by trimming its length at the first black cell or grid boundary.
    final clues = <String, String>{};
    final entries = <PuzzleEntryData>[];
    for (final entry in puzzle.entries) {
      final key = '${entry.number}-${entry.direction}';
      clues[key] = entry.clue ?? '';

      // Compute effective length by scanning until a black cell or edge.
      var effectiveLength = 0;
      for (var i = 0; i < entry.length; i++) {
        final row = entry.direction == 'across' ? entry.y : entry.y + i;
        final col = entry.direction == 'across' ? entry.x + i : entry.x;
        if (row < 0 || row >= rows || col < 0 || col >= cols) {
          break;
        }
        if (blackCells[row][col]) {
          break;
        }
        effectiveLength++;
      }

      if (effectiveLength == 0) {
        // Skip entries that have no usable cells (entirely blocked/out of bounds)
        continue;
      }

      // Crop provided answer if present to match effectiveLength
      final croppedAnswer =
          entry.answer != null && entry.answer!.length >= effectiveLength
          ? entry.answer!.substring(0, effectiveLength)
          : entry.answer;

      entries.add(
        PuzzleEntryData(
          number: entry.number,
          direction: entry.direction,
          x: entry.x,
          y: entry.y,
          length: effectiveLength,
          clue: entry.clue,
          answer: croppedAnswer,
        ),
      );
    }
    // Validation: require that every row has at least one across word
    // and every column has at least one down word, and that those
    // entries include a non-empty clue (indice).
    final rowsWithAcross = <int>{};
    final colsWithDown = <int>{};
    for (final e in entries) {
      if (e.length <= 0) {
        continue;
      }
      if (e.direction == 'across') {
        if (e.clue == null || e.clue!.trim().isEmpty) {
          throw FormatException(
            'Across entry ${e.number} at (${e.y},${e.x}) is missing a clue',
          );
        }
        rowsWithAcross.add(e.y);
      } else if (e.direction == 'down') {
        if (e.clue == null || e.clue!.trim().isEmpty) {
          throw FormatException(
            'Down entry ${e.number} at (${e.y},${e.x}) is missing a clue',
          );
        }
        colsWithDown.add(e.x);
      }
    }

    // If the source puzzle provided no explicit entries at all (tests or
    // programmatic puzzles), skip the "every row/column must have an
    // entry" validation. Real imports should include entries and will be
    // validated strictly below.
    if (puzzle.entries.isNotEmpty) {
      final missingRows = <int>[];
      for (var r = 0; r < rows; r++) {
        // If entire row is black, it's valid to have no across entries
        var rowAllBlack = true;
        for (var c = 0; c < cols; c++) {
          if (!blackCells[r][c]) {
            rowAllBlack = false;
            break;
          }
        }
        if (rowAllBlack) {
          continue;
        }
        if (!rowsWithAcross.contains(r)) {
          missingRows.add(r);
        }
      }

      final missingCols = <int>[];
      for (var c = 0; c < cols; c++) {
        // If entire column is black, it's valid to have no down entries
        var colAllBlack = true;
        for (var r = 0; r < rows; r++) {
          if (!blackCells[r][c]) {
            colAllBlack = false;
            break;
          }
        }
        if (colAllBlack) {
          continue;
        }
        if (!colsWithDown.contains(c)) {
          missingCols.add(c);
        }
      }

      if (missingRows.isNotEmpty || missingCols.isNotEmpty) {
        final parts = <String>[];
        if (missingRows.isNotEmpty) {
          parts.add('missing across words for rows: ${missingRows.join(', ')}');
        }
        if (missingCols.isNotEmpty) {
          parts.add('missing down words for cols: ${missingCols.join(', ')}');
        }
        // Relaxed validation: Just log a warning for generated puzzles or sparse grids
        // instead of preventing the game from loading.
        // throw FormatException('Invalid puzzle: ${parts.join('; ')}');
        debugPrint('Warning: Sparse puzzle detected: ${parts.join('; ')}');
      }
    }

    final metadata = puzzle.metadata ?? {};
    final title = metadata['title']?.toString() ?? 'Puzzle ${puzzle.id}';

    return GameBoard(
      id: puzzle.id,
      title: title,
      gridSize: rows, // Assuming square grid; if non-square, adjust logic
      createdAt: DateTime.now(),
      grid: grid,
      clues: clues,
      blackCells: blackCells,
      difficulty: 1, // Can be extracted from metadata if present
      entries: entries,
      solutionGrid: solutionGrid,
    );
  }
}
