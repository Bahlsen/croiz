import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/data/models/puzzle_cell.dart';
import 'package:croiz/data/models/puzzle_entry.dart';

class PuzzleGenerator {
  /// Build a 2D grid (rows x cols) from the puzzle.cells list (assumes row-major order may not be present)
  static List<List<PuzzleCell>> buildGrid(Puzzle puzzle) {
    final grid = List.generate(
      puzzle.rows,
      (y) => List.generate(
        puzzle.cols,
        (x) => PuzzleCell(x: x, y: y),
        growable: false,
      ),
      growable: false,
    );
    for (final cell in puzzle.cells) {
      if (cell.y < 0 ||
          cell.y >= puzzle.rows ||
          cell.x < 0 ||
          cell.x >= puzzle.cols) {
        continue;
      }
      grid[cell.y][cell.x] = cell;
    }
    return grid;
  }

  /// Compute numbering and extract entries (basic across/down detection).
  /// This does not import clue text; it constructs entries based on cell layout.
  static List<PuzzleEntry> computeEntriesFromCells(Puzzle puzzle) {
    final grid = buildGrid(puzzle);
    final rows = puzzle.rows;
    final cols = puzzle.cols;
    var nextNumber = 1;
    final numberMap = <String, int>{}; // key 'x,y' -> number
    final out = <PuzzleEntry>[];

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final cell = grid[y][x];
        if (cell.isBlack) {
          continue;
        }

        final isStartAcross =
            (x == 0 || grid[y][x - 1].isBlack) &&
            (x + 1 < cols && !grid[y][x + 1].isBlack);
        final isStartDown =
            (y == 0 || grid[y - 1][x].isBlack) &&
            (y + 1 < rows && !grid[y + 1][x].isBlack);

        if (isStartAcross || isStartDown) {
          final assignedNumber = nextNumber;
          numberMap['$x,$y'] = assignedNumber;
          nextNumber++;

          if (isStartAcross) {
            var len = 0;
            var xx = x;
            while (xx < cols && !grid[y][xx].isBlack) {
              len++;
              xx++;
            }
            out.add(
              PuzzleEntry(
                number: assignedNumber,
                direction: 'across',
                x: x,
                y: y,
                length: len,
              ),
            );
          }

          if (isStartDown) {
            var len = 0;
            var yy = y;
            while (yy < rows && !grid[yy][x].isBlack) {
              len++;
              yy++;
            }
            out.add(
              PuzzleEntry(
                number: assignedNumber,
                direction: 'down',
                x: x,
                y: y,
                length: len,
              ),
            );
          }
        }
      }
    }

    return out;
  }
}
