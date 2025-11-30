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

    // Initialize empty grid and blackCells
    final grid = List.generate(rows, (_) => List<String?>.filled(cols, null));
    final blackCells = List.generate(
      rows,
      (_) => List<bool>.filled(cols, false),
    );

    // Fill grid and blackCells from puzzle.cells
    for (final cell in puzzle.cells) {
      if (cell.y < 0 || cell.y >= rows || cell.x < 0 || cell.x >= cols) {
        continue; // skip out-of-bounds cells
      }
      blackCells[cell.y][cell.x] = cell.isBlack;
      // Optionally pre-fill solutions for testing
      if (preFillSolutions && !cell.isBlack && cell.solution != null) {
        grid[cell.y][cell.x] = cell.solution;
      }
    }

    // Build clues map from entries (key: "number-direction" -> clue text)
    final clues = <String, String>{};
    final entries = <PuzzleEntryData>[];
    for (final entry in puzzle.entries) {
      final key = '${entry.number}-${entry.direction}';
      clues[key] = entry.clue ?? '';
      entries.add(
        PuzzleEntryData(
          number: entry.number,
          direction: entry.direction,
          x: entry.x,
          y: entry.y,
          length: entry.length,
          clue: entry.clue,
        ),
      );
    }

    final metadata = puzzle.metadata ?? {};
    final title = metadata['title']?.toString() ?? 'Puzzle ${puzzle.id}';

    return GameBoard(
      id: puzzle.id,
      title: title,
      gridSize:
          rows, // Assuming square grid; if non-square, adjust logic //TODO handle non-square grids
      createdAt: DateTime.now(),
      grid: grid,
      clues: clues,
      blackCells: blackCells,
      difficulty: 1, // Can be extracted from metadata if present
      entries: entries,
    );
  }
}
