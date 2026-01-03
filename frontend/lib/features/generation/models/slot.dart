import 'dart:math';

/// Represents a word slot in a crossword grid.
///
/// A slot is a contiguous sequence of cells where a word can be placed.
/// Slots are extracted from a grid template after black squares are defined.
class Slot {
  const Slot({
    required this.startX,
    required this.startY,
    required this.isHorizontal,
    required this.length,
    this.id,
  });

  /// Unique identifier for this slot (optional, used for display/debugging)
  final String? id;

  /// X coordinate of the first cell
  final int startX;

  /// Y coordinate of the first cell
  final int startY;

  /// Direction: true = horizontal (across), false = vertical (down)
  final bool isHorizontal;

  /// Number of cells in this slot
  final int length;

  /// End X coordinate (exclusive)
  int get endX => isHorizontal ? startX + length : startX + 1;

  /// End Y coordinate (exclusive)
  int get endY => isHorizontal ? startY + 1 : startY + length;

  /// Get the cell coordinates at a specific position in the slot
  Point<int> getCell(int index) {
    if (index < 0 || index >= length) {
      throw RangeError('Index $index out of bounds for slot of length $length');
    }
    return Point(
      isHorizontal ? startX + index : startX,
      isHorizontal ? startY : startY + index,
    );
  }

  /// Get all cell coordinates in this slot
  List<Point<int>> get cells => List.generate(length, getCell);

  /// Check if this slot intersects with another slot
  bool intersectsWith(Slot other) {
    // Same direction slots don't intersect in crossword terms
    if (isHorizontal == other.isHorizontal) {
      return false;
    }

    // Check if the perpendicular slots cross
    final Slot horizontal;
    final Slot vertical;
    if (isHorizontal) {
      horizontal = this;
      vertical = other;
    } else {
      horizontal = other;
      vertical = this;
    }

    // Horizontal slot spans [startX, startX + length) at row startY
    // Vertical slot spans [startY, startY + length) at column startX
    final intersectX = vertical.startX;
    final intersectY = horizontal.startY;

    return intersectX >= horizontal.startX &&
        intersectX < horizontal.startX + horizontal.length &&
        intersectY >= vertical.startY &&
        intersectY < vertical.startY + vertical.length;
  }

  /// Get the intersection point with another slot, if any
  IntersectionPoint? getIntersection(Slot other) {
    if (!intersectsWith(other)) {
      return null;
    }

    final Slot horizontal;
    final Slot vertical;
    if (isHorizontal) {
      horizontal = this;
      vertical = other;
    } else {
      horizontal = other;
      vertical = this;
    }

    final intersectX = vertical.startX;
    final intersectY = horizontal.startY;

    final posInHorizontal = intersectX - horizontal.startX;
    final posInVertical = intersectY - vertical.startY;

    return IntersectionPoint(
      x: intersectX,
      y: intersectY,
      horizontalSlot: horizontal,
      verticalSlot: vertical,
      positionInHorizontal: posInHorizontal,
      positionInVertical: posInVertical,
    );
  }

  /// Distance from center of grid (used for prioritization)
  double distanceFromCenter(int gridWidth, int gridHeight) {
    final centerX = gridWidth / 2;
    final centerY = gridHeight / 2;
    final slotCenterX = startX + (isHorizontal ? length / 2 : 0.5);
    final slotCenterY = startY + (isHorizontal ? 0.5 : length / 2);

    return sqrt(pow(slotCenterX - centerX, 2) + pow(slotCenterY - centerY, 2));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Slot &&
          runtimeType == other.runtimeType &&
          startX == other.startX &&
          startY == other.startY &&
          isHorizontal == other.isHorizontal &&
          length == other.length;

  @override
  int get hashCode =>
      startX.hashCode ^
      startY.hashCode ^
      isHorizontal.hashCode ^
      length.hashCode;

  @override
  String toString() {
    final dir = isHorizontal ? 'Across' : 'Down';
    final label = id ?? '$startX,$startY';
    return 'Slot[$label $dir len=$length]';
  }
}

/// Represents an intersection point between two slots.
class IntersectionPoint {
  const IntersectionPoint({
    required this.x,
    required this.y,
    required this.horizontalSlot,
    required this.verticalSlot,
    required this.positionInHorizontal,
    required this.positionInVertical,
  });

  /// X coordinate of the intersection cell
  final int x;

  /// Y coordinate of the intersection cell
  final int y;

  /// The horizontal slot
  final Slot horizontalSlot;

  /// The vertical slot
  final Slot verticalSlot;

  /// Index of this cell within the horizontal slot (0-based)
  final int positionInHorizontal;

  /// Index of this cell within the vertical slot (0-based)
  final int positionInVertical;

  @override
  String toString() =>
      'Intersection($x,$y: H[$positionInHorizontal] x V[$positionInVertical])';
}
