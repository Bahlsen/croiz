import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/features/generation/utils/puzzle_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PuzzleConverter', () {
    test('extracts language from metadata when present', () {
      final puzzle = Puzzle(
        id: 'test-id',
        rows: 5,
        cols: 5,
        cells: [],
        entries: [],
        metadata: {'language': 'ua'},
      );

      final board = PuzzleConverter.puzzleToGameBoard(puzzle);
      expect(board.language, equals('ua'));
    });

    test('defaults to "en" when language is missing from metadata', () {
      final puzzle = Puzzle(
        id: 'test-id',
        rows: 5,
        cols: 5,
        cells: [],
        entries: [],
        metadata: {},
      );

      final board = PuzzleConverter.puzzleToGameBoard(puzzle);
      expect(board.language, equals('en'));
    });

    test('defaults to "en" when metadata is null', () {
      final puzzle = Puzzle(
        id: 'test-id',
        rows: 5,
        cols: 5,
        cells: [],
        entries: [],
      );

      final board = PuzzleConverter.puzzleToGameBoard(puzzle);
      expect(board.language, equals('en'));
    });
  });
}
