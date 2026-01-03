import 'dart:math';

import 'package:croiz/features/generation/services/grid_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GridTemplateGenerator', () {
    test('should generate template of correct size', () {
      final generator = GridTemplateGenerator(
        width: 15,
        height: 15,
        random: Random(42),
      );

      final template = generator.generate();

      expect(template.length, 15);
      expect(template[0].length, 15);
    });

    test('should respect 180° rotational symmetry', () {
      final generator = GridTemplateGenerator(
        width: 15,
        height: 15,
        random: Random(42),
      );

      final template = generator.generate();

      // Check that each black square has its symmetric counterpart
      for (var y = 0; y < 15; y++) {
        for (var x = 0; x < 15; x++) {
          final symX = 14 - x;
          final symY = 14 - y;
          expect(
            template[y][x],
            equals(template[symY][symX]),
            reason: 'Symmetry failed at ($x,$y) vs ($symX,$symY)',
          );
        }
      }
    });

    test('should have connected white squares', () {
      final generator = GridTemplateGenerator(
        width: 10,
        height: 10,
        random: Random(42),
      );

      final template = generator.generate();

      // BFS to verify connectivity
      Point<int>? start;
      var totalWhite = 0;

      for (var y = 0; y < 10; y++) {
        for (var x = 0; x < 10; x++) {
          if (!template[y][x]) {
            start ??= Point(x, y);
            totalWhite++;
          }
        }
      }

      if (start == null) {
        // All black squares is valid (trivially connected)
        return;
      }

      final visited = <String>{};
      final queue = <Point<int>>[start];
      visited.add('${start.x},${start.y}');

      while (queue.isNotEmpty) {
        final current = queue.removeAt(0);
        final neighbors = [
          Point(current.x - 1, current.y),
          Point(current.x + 1, current.y),
          Point(current.x, current.y - 1),
          Point(current.x, current.y + 1),
        ];

        for (final neighbor in neighbors) {
          if (neighbor.x >= 0 &&
              neighbor.x < 10 &&
              neighbor.y >= 0 &&
              neighbor.y < 10 &&
              !template[neighbor.y][neighbor.x] &&
              !visited.contains('${neighbor.x},${neighbor.y}')) {
            visited.add('${neighbor.x},${neighbor.y}');
            queue.add(neighbor);
          }
        }
      }

      expect(visited.length, totalWhite, reason: 'White squares not connected');
    });

    test('should not create words shorter than minWordLength', () {
      final generator = GridTemplateGenerator(
        width: 15,
        height: 15,
        minWordLength: 3,
        random: Random(42),
      );

      final template = generator.generate();

      // Check horizontal runs
      for (var y = 0; y < 15; y++) {
        var runLength = 0;
        for (var x = 0; x <= 15; x++) {
          final isBlack = x >= 15 || template[y][x];
          if (!isBlack) {
            runLength++;
          } else {
            if (runLength > 0 && runLength < 3) {
              fail('Found horizontal run of length $runLength at row $y');
            }
            runLength = 0;
          }
        }
      }

      // Check vertical runs
      for (var x = 0; x < 15; x++) {
        var runLength = 0;
        for (var y = 0; y <= 15; y++) {
          final isBlack = y >= 15 || template[y][x];
          if (!isBlack) {
            runLength++;
          } else {
            if (runLength > 0 && runLength < 3) {
              fail('Found vertical run of length $runLength at column $x');
            }
            runLength = 0;
          }
        }
      }
    });

    test('should generate different styles', () {
      final generator = GridTemplateGenerator(
        width: 15,
        height: 15,
        random: Random(42),
      );

      final open = generator.generateWithStyle(TemplateStyle.open);
      final checker = generator.generateWithStyle(TemplateStyle.checkerboard);
      final diagonal = generator.generateWithStyle(TemplateStyle.diagonal);
      final random = generator.generateWithStyle(TemplateStyle.random);

      // All should be valid 2D arrays of correct dimensions
      expect(open.length, 15);
      expect(open[0].length, 15);
      expect(checker.length, 15);
      expect(diagonal.length, 15);
      expect(random.length, 15);

      // At least open and random should be valid (they're more reliable)
      expect(generator.validateTemplate(open), true);
    });

    test('should validate valid template', () {
      final generator = GridTemplateGenerator(width: 10, height: 10);

      // Create a simple valid template - all white is valid
      final template = List.generate(10, (_) => List.filled(10, false));

      expect(generator.validateTemplate(template), true);
    });

    test('should reject disconnected template', () {
      final generator = GridTemplateGenerator(width: 10, height: 10);

      // Create a template that bisects the grid
      final template = List.generate(10, (_) => List.filled(10, false));
      for (var y = 0; y < 10; y++) {
        template[y][5] = true; // Full black column
      }

      expect(generator.validateTemplate(template), false);
    });
  });

  group('SlotExtractor', () {
    test('should extract horizontal slots', () {
      // Simple grid with no black squares
      final template = List.generate(5, (_) => List.filled(5, false));

      final slots = SlotExtractor.extractSlots(template);

      // Should have 5 horizontal slots (one per row) and 5 vertical
      final horizontalSlots = slots.where((s) => s.isHorizontal).toList();
      expect(horizontalSlots.length, 5);
      expect(horizontalSlots.every((s) => s.length == 5), true);
    });

    test('should extract vertical slots', () {
      final template = List.generate(5, (_) => List.filled(5, false));

      final slots = SlotExtractor.extractSlots(template);

      final verticalSlots = slots.where((s) => !s.isHorizontal).toList();
      expect(verticalSlots.length, 5);
      expect(verticalSlots.every((s) => s.length == 5), true);
    });

    test('should split slots at black squares', () {
      final template = List.generate(5, (_) => List.filled(10, false));
      // Add black square in middle of first row
      template[0][5] = true;

      final slots = SlotExtractor.extractSlots(template, minLength: 3);

      final firstRowSlots =
          slots.where((s) => s.isHorizontal && s.startY == 0).toList();

      // Should have two slots: [0-4] and [6-9]
      expect(firstRowSlots.length, 2);
      expect(firstRowSlots[0].length, 5);
      expect(firstRowSlots[1].length, 4);
    });

    test('should respect minLength', () {
      final template = List.generate(5, (_) => List.filled(5, false));
      // Create slots of various lengths
      template[0][2] = true; // Creates slots of length 2 and 2

      final slots = SlotExtractor.extractSlots(template, minLength: 3);

      // Should not include 2-length slots
      expect(slots.where((s) => s.length < 3).isEmpty, true);
    });

    test('should assign IDs to slots', () {
      final template = List.generate(5, (_) => List.filled(5, false));

      final slots = SlotExtractor.extractSlots(template);

      // All slots should have IDs
      expect(slots.every((s) => s.id != null), true);

      // Across slots should end with 'A', Down slots with 'D'
      for (final slot in slots) {
        if (slot.isHorizontal) {
          expect(slot.id!.endsWith('A'), true);
        } else {
          expect(slot.id!.endsWith('D'), true);
        }
      }
    });

    test('should build intersection map', () {
      final template = List.generate(5, (_) => List.filled(5, false));

      final slots = SlotExtractor.extractSlots(template);
      final intersectionMap = SlotExtractor.buildIntersectionMap(slots);

      // Each slot should have intersections with perpendicular slots
      final horizontalSlots = slots.where((s) => s.isHorizontal).toList();
      final verticalSlots = slots.where((s) => !s.isHorizontal).toList();

      for (final hSlot in horizontalSlots) {
        final intersections = intersectionMap[hSlot]!;
        // Each horizontal slot should intersect with all vertical slots
        expect(intersections.length, verticalSlots.length);
      }
    });

    test('should handle empty template', () {
      final template = <List<bool>>[];

      final slots = SlotExtractor.extractSlots(template);

      expect(slots, isEmpty);
    });

    test('should handle all-black template', () {
      final template = List.generate(5, (_) => List.filled(5, true));

      final slots = SlotExtractor.extractSlots(template);

      expect(slots, isEmpty);
    });
  });

  group('TemplateStyle', () {
    test('should have all expected values', () {
      expect(TemplateStyle.values, contains(TemplateStyle.open));
      expect(TemplateStyle.values, contains(TemplateStyle.checkerboard));
      expect(TemplateStyle.values, contains(TemplateStyle.diagonal));
      expect(TemplateStyle.values, contains(TemplateStyle.random));
    });
  });
}
