import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';

/// Integration test to verify the bug fix for word-based completion percentage.
///
/// Bug: The completion percentage displayed for in-progress puzzles was based
/// on the number of filled cells instead of the number of completed words.
///
/// Fix: Implemented calculateCompletionPercentByWords() which calculates
/// completion based on fully correct words rather than filled cells.
void main() {
  group('Bug Fix: Word-based completion percentage', () {
    late PuzzleProgressService service;

    setUp(() {
      service = PuzzleProgressService(
        storage: _MockStorage(),
        assetLoader: (_) async => {},
      );
    });

    test('OLD behavior: cell-based calculation (deprecated)', () {
      // Scenario: User filled 50% of cells but only completed 25% of words
      final grid = [
        ['C', 'A', 'T'], // Word 1: CAT (correct)
        ['A', null, 'O'], // Word 2: CAR (incomplete - missing R)
        [null, null, null], // Word 3: TOP (not started)
      ];
      final solution = [
        ['C', 'A', 'T'],
        ['A', null, 'O'],
        ['R', null, 'P'],
      ];

      // OLD method: counts filled cells
      final cellPercent = service.calculateCompletionPercent(grid, solution);

      // 5 cells filled out of 7 total white cells = ~71%
      expect(cellPercent, closeTo(71.4, 0.1));
    });

    test('NEW behavior: word-based calculation (correct)', () {
      // Same scenario as above
      final grid = [
        ['C', 'A', 'T'], // Word 1: CAT (correct)
        ['A', null, 'O'], // Word 2: CAR (incomplete - missing R)
        [null, null, null], // Word 3: TOP (not started)
      ];
      final solution = [
        ['C', 'A', 'T'],
        ['A', null, 'O'],
        ['R', null, 'P'],
      ];
      final clues = [
        {
          'id': 'a1',
          'direction': 'across',
          'x': 0,
          'y': 0,
          'length': 3,
          'answer': 'CAT',
        },
        {
          'id': 'd1',
          'direction': 'down',
          'x': 0,
          'y': 0,
          'length': 3,
          'answer': 'CAR',
        },
        {
          'id': 'd2',
          'direction': 'down',
          'x': 2,
          'y': 0,
          'length': 3,
          'answer': 'TOP',
        },
      ];

      // NEW method: counts completed words
      final wordPercent = service.calculateCompletionPercentByWords(
        grid,
        solution,
        clues,
      );

      // Only 1 word completed out of 3 = 33.33%
      expect(wordPercent, closeTo(33.33, 0.1));
    });

    test('Demonstrates the bug: misleading progress', () {
      // User fills 3 out of 4 letters of a word
      final grid = [
        ['W', 'O', 'R', null],
      ];
      final solution = [
        ['W', 'O', 'R', 'D'],
      ];
      final clues = [
        {
          'id': 'a1',
          'direction': 'across',
          'x': 0,
          'y': 0,
          'length': 4,
          'answer': 'WORD',
        },
      ];

      final cellPercent = service.calculateCompletionPercent(grid, solution);
      final wordPercent = service.calculateCompletionPercentByWords(
        grid,
        solution,
        clues,
      );

      // OLD: Shows 75% (3 out of 4 cells filled)
      expect(cellPercent, 75.0);

      // NEW: Shows 0% (0 out of 1 words completed)
      expect(wordPercent, 0.0);
    });
  });
}

class _MockStorage implements PuzzleStorageInterface {
  @override
  Future<Map<String, dynamic>?> load(String id) async => null;

  @override
  Future<void> save(String id, Map<String, dynamic> payload) async {}

  @override
  Future<List<String>> getAllKeys() async => [];

  @override
  Stream<void> get onDataChanged => const Stream.empty();
}
