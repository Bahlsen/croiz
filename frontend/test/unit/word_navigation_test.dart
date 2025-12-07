import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/helpers/word_navigation.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('computeAdjacentEntry', () {
    final entries = <PuzzleEntryData>[
      const PuzzleEntryData(
        number: 1,
        direction: 'across',
        x: 0,
        y: 0,
        length: 3,
        clue: 'A1',
      ),
      const PuzzleEntryData(
        number: 2,
        direction: 'down',
        x: 1,
        y: 0,
        length: 4,
        clue: 'D2',
      ),
      const PuzzleEntryData(
        number: 3,
        direction: 'across',
        x: 3,
        y: 0,
        length: 4,
        clue: 'A3',
      ),
    ];

    test('directional order: A1 -> A3; wrap to D2', () {
      final n1 = computeAdjacentEntry(entries, entries[0], 1);
      expect(n1.direction, 'across');
      expect(n1.number, 3);
      final n2 = computeAdjacentEntry(entries, n1, 1);
      expect(n2.direction, 'down');
      expect(n2.number, 2);
      final p1 = computeAdjacentEntry(entries, n2, -1);
      expect(p1.direction, 'across');
      expect(p1.number, 3);
    });

    test('overflow right from last across wraps to first down', () {
      final next = computeAdjacentEntry(entries, entries[2], 1);
      expect(next.direction, 'down');
      expect(next.number, 2);
    });

    test('overflow left from first across wraps to last down', () {
      final prev = computeAdjacentEntry(entries, entries[0], -1);
      expect(prev.direction, 'down');
      expect(prev.number, 2);
    });

    test('empty entries returns current', () {
      final current = entries[0];
      final next = computeAdjacentEntry(const [], current, 1);
      expect(next, current);
    });

    test('current not found returns current', () {
      const ghost = PuzzleEntryData(
        number: 99,
        direction: 'across',
        x: 9,
        y: 9,
        length: 1,
        clue: 'X',
      );
      final next = computeAdjacentEntry(entries, ghost, 1);
      expect(next, ghost);
    });

    test('single-direction list wraps within itself', () {
      final acrossOnly = entries.where((e) => e.direction == 'across').toList();
      final next = computeAdjacentEntry(acrossOnly, acrossOnly.last, 1);
      expect(next.direction, 'across');
      expect(next.number, 1);
    });
  });
}
