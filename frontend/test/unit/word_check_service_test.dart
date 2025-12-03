import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('WordCheckService', () {
    final svc = WordCheckService();

    test('returns true when entry has answer and grid matches', () {
      final board = GameBoard(
        id: 'b',
        title: 't',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['A', 'B', 'C'],
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: [
          [false, false, false],
          [false, false, false],
          [false, false, false],
        ],
        difficulty: 1,
        entries: const [
          PuzzleEntryData(number:1, direction: 'across', x: 0, y: 0, length: 3, answer: 'ABC'),
        ],
      );

      final entry = board.entries!.first;
      expect(svc.isWordComplete(board, entry), isTrue);
    });

    test('returns false when entry has answer and grid does not match', () {
      final board = GameBoard(
        id: 'b',
        title: 't',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['A', '', 'C'],
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: [
          [false, false, false],
          [false, false, false],
          [false, false, false],
        ],
        difficulty: 1,
        entries: const [
          PuzzleEntryData(number:1, direction: 'across', x: 0, y: 0, length: 3, answer: 'ABC'),
        ],
      );

      final entry = board.entries!.first;
      expect(svc.isWordComplete(board, entry), isFalse);
    });

    test('returns true when entry has no answer and all cells filled', () {
      final board = GameBoard(
        id: 'b',
        title: 't',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['X', 'Y', 'Z'],
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: [
          [false, false, false],
          [false, false, false],
          [false, false, false],
        ],
        difficulty: 1,
        entries: const [
          PuzzleEntryData(number:1, direction: 'across', x: 0, y: 0, length: 3),
        ],
      );

      final entry = board.entries!.first;
      expect(svc.isWordComplete(board, entry), isTrue);
    });

    test('returns false when entry has no answer and some cells empty', () {
      final board = GameBoard(
        id: 'b',
        title: 't',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['X', null, 'Z'],
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: [
          [false, false, false],
          [false, false, false],
          [false, false, false],
        ],
        difficulty: 1,
        entries: const [
          PuzzleEntryData(number:1, direction: 'across', x: 0, y: 0, length: 3),
        ],
      );

      final entry = board.entries!.first;
      expect(svc.isWordComplete(board, entry), isFalse);
    });
  });
}
