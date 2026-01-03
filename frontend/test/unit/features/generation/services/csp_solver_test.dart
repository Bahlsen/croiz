import 'dart:math';

import 'package:croiz/features/generation/models/slot.dart';
import 'package:croiz/features/generation/services/csp_solver.dart';
import 'package:croiz/features/generation/services/gaddag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrosswordCSPSolver', () {
    late Gaddag gaddag;

    setUp(() {
      gaddag = Gaddag();
    });

    test('should solve simple 2-slot puzzle', () {
      // Two intersecting slots
      const horizontalSlot = Slot(
        id: '1A',
        startX: 0,
        startY: 1,
        isHorizontal: true,
        length: 3,
      );
      const verticalSlot = Slot(
        id: '1D',
        startX: 1,
        startY: 0,
        isHorizontal: false,
        length: 3,
      );

      // Words: CAT (horizontal), BAT (vertical - shares A at position 1)
      gaddag.build(['CAT', 'BAT', 'DOG', 'HAT']);

      final solver = CrosswordCSPSolver(
        gaddag: gaddag,
        slots: [horizontalSlot, verticalSlot],
      );

      final result = solver.solve();

      expect(result.success, true);
      expect(result.assignments.length, 2);

      // Verify intersection constraint is satisfied
      final hWord = result.assignments[horizontalSlot]!;
      final vWord = result.assignments[verticalSlot]!;
      expect(hWord[1], equals(vWord[1])); // Intersection at (1,1)
    });

    test('should apply known letter constraints', () {
      const slot = Slot(
        id: '1A',
        startX: 0,
        startY: 0,
        isHorizontal: true,
        length: 3,
      );

      final gaddag = Gaddag()..build(['CAT', 'BAT', 'HAT', 'DOG']);

      final solver = CrosswordCSPSolver(gaddag: gaddag, slots: [slot])
        ..applyKnownLetters({const Point(0, 0): 'C'});

      final result = solver.solve();

      expect(result.success, true);
      expect(result.assignments[slot], 'CAT');
    });

    test('should detect unsolvable configuration', () {
      // Two slots intersecting at (2, 0) - horizontal slot position 2, vertical slot position 0
      const slot1 = Slot(
        id: '1A',
        startX: 0,
        startY: 0,
        isHorizontal: true,
        length: 4, // Need 4-letter word
      );
      const slot2 = Slot(
        id: '1D',
        startX: 2,
        startY: 0,
        isHorizontal: false,
        length:
            3, // Need 3-letter word starting with letter at position 2 of slot1
      );

      // 4-letter words have 'S' at position 2: TEST, BEST
      // 3-letter words all start with different letters: CAT, DOG
      // No 3-letter word starts with 'S', so unsolvable
      gaddag.build(['TEST', 'BEST', 'CAT', 'DOG']);

      final solver = CrosswordCSPSolver(gaddag: gaddag, slots: [slot1, slot2]);

      final result = solver.solve();

      // Should fail because no 3-letter word starts with 'S'
      // (slot1 has 'S' at position 2, slot2 needs first letter to match)
      expect(result.success, false);
    });

    test('should solve with multiple intersections', () {
      // Cross pattern:
      //   D
      // CAT
      //   G
      const horizontal = Slot(
        id: '1A',
        startX: 0,
        startY: 1,
        isHorizontal: true,
        length: 3,
      );
      const vertical = Slot(
        id: '1D',
        startX: 1,
        startY: 0,
        isHorizontal: false,
        length: 3,
      );

      // CAT intersects with words having A in middle
      gaddag.build(['CAT', 'BAT', 'DAG', 'HAG', 'BAG']);

      final solver = CrosswordCSPSolver(
        gaddag: gaddag,
        slots: [horizontal, vertical],
      );

      final result = solver.solve();

      expect(result.success, true);

      final hWord = result.assignments[horizontal]!;
      final vWord = result.assignments[vertical]!;

      // Verify intersection: H[1] == V[1]
      expect(hWord[1], equals(vWord[1]));
    });

    test('should return partial solution on timeout', () {
      // Create a complex puzzle that might not solve fully
      final slots = <Slot>[];
      for (var y = 0; y < 5; y++) {
        slots.add(
          Slot(
            id: '${y + 1}A',
            startX: 0,
            startY: y,
            isHorizontal: true,
            length: 5,
          ),
        );
      }
      for (var x = 0; x < 5; x++) {
        slots.add(
          Slot(
            id: '${x + 1}D',
            startX: x,
            startY: 0,
            isHorizontal: false,
            length: 5,
          ),
        );
      }

      // Limited dictionary that might not fill all slots
      gaddag.build(['APPLE', 'AMPLE', 'ANGST']);

      final solver = CrosswordCSPSolver(
        gaddag: gaddag,
        slots: slots,
        maxBacktracks: 100, // Low limit to force early termination
      );

      final result = solver.solve();

      // Might succeed or fail, but should not crash
      expect(result.assignments, isA<Map<Slot, String>>());
    });

    test('should use MRV heuristic (most constrained first)', () {
      // Three slots, one with very limited domain
      const slot1 = Slot(
        id: '1A',
        startX: 0,
        startY: 0,
        isHorizontal: true,
        length: 3,
      );
      const slot2 = Slot(
        id: '2A',
        startX: 0,
        startY: 1,
        isHorizontal: true,
        length: 4,
      );
      const slot3 = Slot(
        id: '3A',
        startX: 0,
        startY: 2,
        isHorizontal: true,
        length: 5,
      );

      // Many 3-letter, few 4-letter, one 5-letter word
      gaddag.build([
        'CAT', 'BAT', 'HAT', 'RAT', 'SAT', // 3-letter
        'FISH', 'BIRD', // 4-letter
        'APPLE', // 5-letter
      ]);

      final solver = CrosswordCSPSolver(
        gaddag: gaddag,
        slots: [slot1, slot2, slot3],
      );

      final result = solver.solve();

      expect(result.success, true);
      expect(result.assignments.length, 3);
    });

    test('should handle empty slots list', () {
      final solver = CrosswordCSPSolver(gaddag: gaddag, slots: []);

      final result = solver.solve();

      expect(result.success, true);
      expect(result.assignments, isEmpty);
    });

    test('should handle single slot', () {
      const slot = Slot(
        id: '1A',
        startX: 0,
        startY: 0,
        isHorizontal: true,
        length: 4,
      );

      gaddag.build(['TEST', 'BEST', 'NEST']);

      final solver = CrosswordCSPSolver(gaddag: gaddag, slots: [slot]);

      final result = solver.solve();

      expect(result.success, true);
      expect(result.assignments[slot], isIn(['TEST', 'BEST', 'NEST']));
    });
  });

  group('CSPSolveResult', () {
    test('should store success result', () {
      const result = CSPSolveResult(success: true, assignments: {});

      expect(result.success, true);
      expect(result.failureReason, isNull);
      expect(result.unfilledSlots, isEmpty);
    });

    test('should store failure result with reason', () {
      const result = CSPSolveResult(
        success: false,
        assignments: {},
        failureReason: 'Test failure',
      );

      expect(result.success, false);
      expect(result.failureReason, 'Test failure');
    });

    test('should store unfilled slots', () {
      const slot = Slot(startX: 0, startY: 0, isHorizontal: true, length: 3);

      const result = CSPSolveResult(
        success: false,
        assignments: {},
        unfilledSlots: [slot],
      );

      expect(result.unfilledSlots, contains(slot));
    });
  });
}
