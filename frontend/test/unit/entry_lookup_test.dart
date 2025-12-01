import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/helpers/entry_lookup.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeCurrentEntry', () {
    test('returns null when no entries', () {
      final board = GameBoard(
        id: 'b1',
        title: 'Empty',
        gridSize: 3,
        createdAt: DateTime(2025, 1, 1),
        grid: List.generate(3, (_) => List.generate(3, (_) => null)),
        clues: const {},
        blackCells: List.generate(3, (_) => List.generate(3, (_) => false)),
        difficulty: 1,
        entries: const [],
      );
      final res = computeCurrentEntry(board, const SelectedCell(0, 0), WordDirection.horizontal);
      expect(res, isNull);
    });

    test('finds across entry at selection start', () {
      final board = GameBoard(
        id: 'b2',
        title: 'With entries',
        gridSize: 3,
        createdAt: DateTime(2025, 1, 1),
        grid: List.generate(3, (_) => List.generate(3, (_) => null)),
        clues: const {'1-across': 'A'},
        blackCells: List.generate(3, (_) => List.generate(3, (_) => false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 3, clue: 'A'),
        ],
      );
      final res = computeCurrentEntry(board, const SelectedCell(0, 0), WordDirection.horizontal);
      expect(res, isNotNull);
      expect(res!.horizontal, isTrue);
      expect(res.entry.number, 1);
      expect(res.entry.direction, 'across');
    });

    test('finds down entry when vertical mode', () {
      final board = GameBoard(
        id: 'b3',
        title: 'With entries',
        gridSize: 3,
        createdAt: DateTime(2025, 1, 1),
        grid: List.generate(3, (_) => List.generate(3, (_) => null)),
        clues: const {'1-down': 'D'},
        blackCells: List.generate(3, (_) => List.generate(3, (_) => false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(number: 1, direction: 'down', x: 0, y: 0, length: 3, clue: 'D'),
        ],
      );
      final res = computeCurrentEntry(board, const SelectedCell(0, 0), WordDirection.vertical);
      expect(res, isNotNull);
      expect(res!.horizontal, isFalse);
      expect(res.entry.number, 1);
      expect(res.entry.direction, 'down');
    });
  });
}
