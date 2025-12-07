import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/data/models/puzzle_cell.dart';
import 'package:croiz/data/models/puzzle_entry.dart';
import 'package:croiz/core/puzzle_converter.dart';

void main() {
  test('valid puzzle with all rows and cols has no exception', () {
    final cells = <PuzzleCell>[];
    for (var y = 0; y < 2; y++) {
      for (var x = 0; x < 2; x++) {
        cells.add(PuzzleCell(x: x, y: y, isBlack: false, solution: 'A'));
      }
    }

    final entries = <PuzzleEntry>[
      PuzzleEntry(
        number: 1,
        direction: 'across',
        x: 0,
        y: 0,
        length: 2,
        clue: 'r0',
      ),
      PuzzleEntry(
        number: 2,
        direction: 'across',
        x: 0,
        y: 1,
        length: 2,
        clue: 'r1',
      ),
      PuzzleEntry(
        number: 3,
        direction: 'down',
        x: 0,
        y: 0,
        length: 2,
        clue: 'c0',
      ),
      PuzzleEntry(
        number: 4,
        direction: 'down',
        x: 1,
        y: 0,
        length: 2,
        clue: 'c1',
      ),
    ];
    final puzzle = Puzzle(
      id: 't1',
      rows: 2,
      cols: 2,
      cells: cells,
      entries: entries,
    );

    expect(() => PuzzleConverter.puzzleToGameBoard(puzzle), returnsNormally);
  });

  test('missing across for a row throws FormatException', () {
    final cells = <PuzzleCell>[];
    for (var y = 0; y < 2; y++) {
      for (var x = 0; x < 2; x++) {
        cells.add(PuzzleCell(x: x, y: y, isBlack: false, solution: 'A'));
      }
    }

    final entries = <PuzzleEntry>[
      PuzzleEntry(
        number: 1,
        direction: 'across',
        x: 0,
        y: 0,
        length: 2,
        clue: 'r0',
      ),
      PuzzleEntry(
        number: 3,
        direction: 'down',
        x: 0,
        y: 0,
        length: 2,
        clue: 'c0',
      ),
      PuzzleEntry(
        number: 4,
        direction: 'down',
        x: 1,
        y: 0,
        length: 2,
        clue: 'c1',
      ),
    ];

    final puzzle = Puzzle(
      id: 't2',
      rows: 2,
      cols: 2,
      cells: cells,
      entries: entries,
    );

    expect(
      () => PuzzleConverter.puzzleToGameBoard(puzzle),
      throwsA(isA<FormatException>()),
    );
  });

  test('entry without clue throws FormatException', () {
    final cells = <PuzzleCell>[];
    for (var y = 0; y < 2; y++) {
      for (var x = 0; x < 2; x++) {
        cells.add(PuzzleCell(x: x, y: y, isBlack: false, solution: 'A'));
      }
    }

    final entries = <PuzzleEntry>[
      PuzzleEntry(
        number: 1,
        direction: 'across',
        x: 0,
        y: 0,
        length: 2,
        clue: 'r0',
      ),
      PuzzleEntry(
        number: 2,
        direction: 'across',
        x: 0,
        y: 1,
        length: 2,
        clue: null,
      ),
      PuzzleEntry(
        number: 3,
        direction: 'down',
        x: 0,
        y: 0,
        length: 2,
        clue: 'c0',
      ),
      PuzzleEntry(
        number: 4,
        direction: 'down',
        x: 1,
        y: 0,
        length: 2,
        clue: 'c1',
      ),
    ];

    final puzzle = Puzzle(
      id: 't3',
      rows: 2,
      cols: 2,
      cells: cells,
      entries: entries,
    );

    expect(
      () => PuzzleConverter.puzzleToGameBoard(puzzle),
      throwsA(isA<FormatException>()),
    );
  });
}
