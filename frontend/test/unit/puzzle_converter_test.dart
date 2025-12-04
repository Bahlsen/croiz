import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/data/models/puzzle_cell.dart';
import 'package:croiz/data/models/puzzle_entry.dart';
import 'package:croiz/core/puzzle_converter.dart';

void main() {
  group('PuzzleConverter', () {
    test('converts Puzzle to GameBoard correctly', () {
      // Create a minimal 3x3 puzzle
      final puzzle = Puzzle(
        id: 'test-3x3',
        version: '1.0',
        metadata: {'title': 'Test 3x3'},
        rows: 3,
        cols: 3,
        cells: [
          PuzzleCell(x: 0, y: 0, isBlack: false, solution: 'A'),
          PuzzleCell(x: 1, y: 0, isBlack: false, solution: 'B'),
          PuzzleCell(x: 2, y: 0, isBlack: true),
          PuzzleCell(x: 0, y: 1, isBlack: false, solution: 'C'),
          PuzzleCell(x: 1, y: 1, isBlack: true),
          PuzzleCell(x: 2, y: 1, isBlack: false, solution: 'D'),
          PuzzleCell(x: 0, y: 2, isBlack: false, solution: 'E'),
          PuzzleCell(x: 1, y: 2, isBlack: false, solution: 'F'),
          PuzzleCell(x: 2, y: 2, isBlack: false, solution: 'G'),
        ],
        entries: [
          // Row 0 across
          PuzzleEntry(
            id: 'a1',
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 2,
            answer: 'AB',
            clue: 'First two letters',
          ),
          // Col 0 down
          PuzzleEntry(
            id: 'd1',
            number: 1,
            direction: 'down',
            x: 0,
            y: 0,
            length: 3,
            answer: 'ACE',
            clue: 'Vertical word',
          ),
          // Row 1 across (single-letter across allowed)
          PuzzleEntry(
            id: 'a2',
            number: 2,
            direction: 'across',
            x: 0,
            y: 1,
            length: 1,
            answer: 'C',
            clue: 'Row 1 across',
          ),
          // Row 2 across
          PuzzleEntry(
            id: 'a3',
            number: 3,
            direction: 'across',
            x: 0,
            y: 2,
            length: 3,
            answer: 'EFG',
            clue: 'Row 2 across',
          ),
          // Col 1 down (single-letter)
          PuzzleEntry(
            id: 'd2',
            number: 2,
            direction: 'down',
            x: 1,
            y: 0,
            length: 1,
            answer: 'B',
            clue: 'Col 1 down',
          ),
          // Col 2 down (starts at y=1)
          PuzzleEntry(
            id: 'd3',
            number: 3,
            direction: 'down',
            x: 2,
            y: 1,
            length: 2,
            answer: 'DG',
            clue: 'Col 2 down',
          ),
        ],
      );

      final gameBoard = PuzzleConverter.puzzleToGameBoard(puzzle);

      // Verify basic fields
      expect(gameBoard.id, 'test-3x3');
      expect(gameBoard.title, 'Test 3x3');
      expect(gameBoard.gridSize, 3);

      // Verify grid structure (should be empty by default)
      expect(gameBoard.grid.length, 3);
      expect(gameBoard.grid[0].length, 3);
      expect(gameBoard.grid[0][0], isNull); // not pre-filled

      // Verify blackCells
      expect(gameBoard.blackCells[0][2], isTrue); // black cell at (2, 0)
      expect(gameBoard.blackCells[0][0], isFalse);
      expect(gameBoard.blackCells[1][1], isTrue); // black cell at (1, 1)

      // Verify clues
      expect(gameBoard.clues['1-across'], 'First two letters');
      expect(gameBoard.clues['1-down'], 'Vertical word');

      // Verify entries (should include across and down entries)
      expect(gameBoard.entries, isNotNull);
      expect(gameBoard.entries!.isNotEmpty, isTrue);
      expect(gameBoard.entries!.any((e) => e.direction == 'across'), isTrue);
      expect(gameBoard.entries!.any((e) => e.direction == 'down'), isTrue);
    });

    test('pre-fills solutions when flag is true', () {
      final puzzle = Puzzle(
        id: 'test-prefill',
        rows: 2,
        cols: 2,
        cells: [
          PuzzleCell(x: 0, y: 0, isBlack: false, solution: 'X'),
          PuzzleCell(x: 1, y: 0, isBlack: false, solution: 'Y'),
          PuzzleCell(x: 0, y: 1, isBlack: true),
          PuzzleCell(x: 1, y: 1, isBlack: false, solution: 'Z'),
        ],
        entries: [],
      );

      final gameBoard = PuzzleConverter.puzzleToGameBoard(
        puzzle,
        preFillSolutions: true,
      );

      // Verify solutions are pre-filled
      expect(gameBoard.grid[0][0], 'X');
      expect(gameBoard.grid[0][1], 'Y');
      expect(gameBoard.grid[1][0], isNull); // black cell
      expect(gameBoard.grid[1][1], 'Z');
    });
  });
}
