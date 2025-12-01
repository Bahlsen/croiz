import 'package:croiz/domain/entities/game_entities.dart';

/// Utility to compute numbering overlays from board entries.
class ClueNumbering {
  /// Returns a map of 'row,col' -> smallest entry number starting at that cell.
  static Map<String, int> numbersFromBoard(GameBoard board) {
    final size = board.gridSize;
    final entries = board.entries;
    final numbers = <String, int>{};
    if (entries == null || entries.isEmpty) {
      return numbers;
    }
    for (final e in entries) {
      final r = e.y;
      final c = e.x;
      if (r < 0 || r >= size || c < 0 || c >= size) {
        continue;
      }
      final key = '$r,$c';
      final current = numbers[key];
      if (current == null || e.number < current) {
        numbers[key] = e.number;
      }
    }
    return numbers;
  }
}
