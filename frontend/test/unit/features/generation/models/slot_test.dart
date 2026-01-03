import 'dart:math';

import 'package:croiz/features/generation/models/slot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Slot', () {
    test('should create horizontal slot correctly', () {
      const slot = Slot(startX: 2, startY: 5, isHorizontal: true, length: 6);

      expect(slot.startX, 2);
      expect(slot.startY, 5);
      expect(slot.isHorizontal, true);
      expect(slot.length, 6);
      expect(slot.endX, 8);
      expect(slot.endY, 6);
    });

    test('should create vertical slot correctly', () {
      const slot = Slot(startX: 3, startY: 1, isHorizontal: false, length: 5);

      expect(slot.startX, 3);
      expect(slot.startY, 1);
      expect(slot.isHorizontal, false);
      expect(slot.length, 5);
      expect(slot.endX, 4);
      expect(slot.endY, 6);
    });

    test('should get cell coordinates correctly for horizontal slot', () {
      const slot = Slot(startX: 2, startY: 3, isHorizontal: true, length: 4);

      expect(slot.getCell(0), const Point(2, 3));
      expect(slot.getCell(1), const Point(3, 3));
      expect(slot.getCell(2), const Point(4, 3));
      expect(slot.getCell(3), const Point(5, 3));
    });

    test('should get cell coordinates correctly for vertical slot', () {
      const slot = Slot(startX: 5, startY: 2, isHorizontal: false, length: 3);

      expect(slot.getCell(0), const Point(5, 2));
      expect(slot.getCell(1), const Point(5, 3));
      expect(slot.getCell(2), const Point(5, 4));
    });

    test('should throw RangeError for invalid cell index', () {
      const slot = Slot(startX: 0, startY: 0, isHorizontal: true, length: 3);

      expect(() => slot.getCell(-1), throwsRangeError);
      expect(() => slot.getCell(3), throwsRangeError);
    });

    test('should return all cells', () {
      const slot = Slot(startX: 1, startY: 1, isHorizontal: true, length: 3);

      final cells = slot.cells;
      expect(cells.length, 3);
      expect(cells[0], const Point(1, 1));
      expect(cells[1], const Point(2, 1));
      expect(cells[2], const Point(3, 1));
    });

    group('intersection detection', () {
      test('should detect intersection between perpendicular slots', () {
        const horizontal = Slot(
          startX: 0,
          startY: 2,
          isHorizontal: true,
          length: 5,
        );
        const vertical = Slot(
          startX: 2,
          startY: 0,
          isHorizontal: false,
          length: 5,
        );

        expect(horizontal.intersectsWith(vertical), true);
        expect(vertical.intersectsWith(horizontal), true);
      });

      test('should not detect intersection for parallel slots', () {
        const slot1 = Slot(startX: 0, startY: 0, isHorizontal: true, length: 5);
        const slot2 = Slot(startX: 0, startY: 2, isHorizontal: true, length: 5);

        expect(slot1.intersectsWith(slot2), false);
      });

      test('should not detect intersection for non-overlapping slots', () {
        const horizontal = Slot(
          startX: 0,
          startY: 0,
          isHorizontal: true,
          length: 3,
        );
        const vertical = Slot(
          startX: 5,
          startY: 0,
          isHorizontal: false,
          length: 3,
        );

        expect(horizontal.intersectsWith(vertical), false);
      });

      test('should return intersection point details', () {
        const horizontal = Slot(
          id: 'H',
          startX: 0,
          startY: 3,
          isHorizontal: true,
          length: 6,
        );
        const vertical = Slot(
          id: 'V',
          startX: 2,
          startY: 1,
          isHorizontal: false,
          length: 5,
        );

        final intersection = horizontal.getIntersection(vertical);

        expect(intersection, isNotNull);
        expect(intersection!.x, 2);
        expect(intersection.y, 3);
        expect(intersection.positionInHorizontal, 2);
        expect(intersection.positionInVertical, 2);
      });

      test('should return null for non-intersecting slots', () {
        const slot1 = Slot(startX: 0, startY: 0, isHorizontal: true, length: 3);
        const slot2 = Slot(
          startX: 10,
          startY: 10,
          isHorizontal: false,
          length: 3,
        );

        expect(slot1.getIntersection(slot2), isNull);
      });
    });

    test('should calculate distance from center', () {
      const slot = Slot(startX: 0, startY: 0, isHorizontal: true, length: 4);

      // Slot center is at (2, 0.5), grid center is (7.5, 7.5) for 15x15
      final distance = slot.distanceFromCenter(15, 15);
      expect(distance, greaterThan(0));
    });

    test('should support equality', () {
      const slot1 = Slot(startX: 2, startY: 3, isHorizontal: true, length: 5);
      const slot2 = Slot(startX: 2, startY: 3, isHorizontal: true, length: 5);
      const slot3 = Slot(startX: 2, startY: 3, isHorizontal: false, length: 5);

      expect(slot1, equals(slot2));
      expect(slot1, isNot(equals(slot3)));
    });

    test('should have consistent hashCode', () {
      const slot1 = Slot(startX: 2, startY: 3, isHorizontal: true, length: 5);
      const slot2 = Slot(startX: 2, startY: 3, isHorizontal: true, length: 5);

      expect(slot1.hashCode, equals(slot2.hashCode));
    });

    test('toString should be readable', () {
      const slot = Slot(
        id: '1A',
        startX: 2,
        startY: 3,
        isHorizontal: true,
        length: 5,
      );

      expect(slot.toString(), contains('1A'));
      expect(slot.toString(), contains('Across'));
      expect(slot.toString(), contains('5'));
    });
  });

  group('IntersectionPoint', () {
    test('should store intersection details correctly', () {
      const horizontal = Slot(
        startX: 0,
        startY: 2,
        isHorizontal: true,
        length: 5,
      );
      const vertical = Slot(
        startX: 3,
        startY: 0,
        isHorizontal: false,
        length: 5,
      );

      const intersection = IntersectionPoint(
        x: 3,
        y: 2,
        horizontalSlot: horizontal,
        verticalSlot: vertical,
        positionInHorizontal: 3,
        positionInVertical: 2,
      );

      expect(intersection.x, 3);
      expect(intersection.y, 2);
      expect(intersection.horizontalSlot, horizontal);
      expect(intersection.verticalSlot, vertical);
      expect(intersection.positionInHorizontal, 3);
      expect(intersection.positionInVertical, 2);
    });
  });
}
