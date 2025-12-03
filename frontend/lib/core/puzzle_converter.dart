import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/domain/entities/game_entities.dart';

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
    final solutionGrid = List.generate(rows, (_) => List<String?>.filled(cols, null));

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
      final croppedAnswer = entry.answer != null && entry.answer!.length >= effectiveLength
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
