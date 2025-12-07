import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('WordCheckService', () {
    late WordCheckService service;

    setUp(() {
      service = WordCheckService();
    });

    test('isWordComplete returns true for correct horizontal word', () {
      final board = GameBoard(
        id: 'test',
        title: 'Test',
        gridSize: 5,
        createdAt: DateTime.now(),
        grid: [
          ['C', 'A', 'T', null, null],
          [null, null, null, null, null],
          [null, null, null, null, null],
          [null, null, null, null, null],
          [null, null, null, null, null],
        ],
        clues: {},
        blackCells: List.generate(5, (_) => List.filled(5, false)),
        difficulty: 1,
        entries: [
          const PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            answer: 'CAT',
          ),
        ],
      );

      final entry = board.entries![0];
      expect(service.isWordComplete(board, entry), true);
    });

    test('isWordComplete returns false for incomplete word', () {
      final board = GameBoard(
        id: 'test',
        title: 'Test',
        gridSize: 5,
        createdAt: DateTime.now(),
        grid: [
          ['C', 'A', null, null, null],
          [null, null, null, null, null],
          [null, null, null, null, null],
          [null, null, null, null, null],
          [null, null, null, null, null],
        ],
        clues: {},
        blackCells: List.generate(5, (_) => List.filled(5, false)),
        difficulty: 1,
        entries: [
          const PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            answer: 'CAT',
          ),
        ],
      );

      final entry = board.entries![0];
      expect(service.isWordComplete(board, entry), false);
    });

    test('isWordComplete returns false for incorrect word', () {
      final board = GameBoard(
        id: 'test',
        title: 'Test',
        gridSize: 5,
        createdAt: DateTime.now(),
        grid: [
          ['C', 'A', 'R', null, null],
          [null, null, null, null, null],
          [null, null, null, null, null],
          [null, null, null, null, null],
          [null, null, null, null, null],
        ],
        clues: {},
        blackCells: List.generate(5, (_) => List.filled(5, false)),
        difficulty: 1,
        entries: [
          const PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            answer: 'CAT',
          ),
        ],
      );

      final entry = board.entries![0];
      expect(service.isWordComplete(board, entry), false);
    });

    test('isWordComplete returns true for correct vertical word', () {
      final board = GameBoard(
        id: 'test',
        title: 'Test',
        gridSize: 5,
        createdAt: DateTime.now(),
        grid: [
          ['D', null, null, null, null],
          ['O', null, null, null, null],
          ['G', null, null, null, null],
          [null, null, null, null, null],
          [null, null, null, null, null],
        ],
        clues: {},
        blackCells: List.generate(5, (_) => List.filled(5, false)),
        difficulty: 1,
        entries: [
          const PuzzleEntryData(
            number: 1,
            direction: 'down',
            x: 0,
            y: 0,
            length: 3,
            answer: 'DOG',
          ),
        ],
      );

      final entry = board.entries![0];
      expect(service.isWordComplete(board, entry), true);
    });

    test('getWordKey returns correct format', () {
      const entry = PuzzleEntryData(
        number: 1,
        direction: 'across',
        x: 2,
        y: 3,
        length: 5,
      );

      expect(service.getWordKey(entry), '3,2,across');
    });

    test('getCellKeys returns correct cell keys', () {
      const entry = PuzzleEntryData(
        number: 1,
        direction: 'across',
        x: 1,
        y: 2,
        length: 3,
      );

      final keys = service.getCellKeys(entry);
      expect(keys, ['2,1', '2,2', '2,3']);
    });

    test('getCellKeys returns correct cell keys for vertical', () {
      const entry = PuzzleEntryData(
        number: 1,
        direction: 'down',
        x: 1,
        y: 2,
        length: 3,
      );

      final keys = service.getCellKeys(entry);
      expect(keys, ['2,1', '3,1', '4,1']);
    });
  });
}
