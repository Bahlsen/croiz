import 'package:croiz/domain/entities/game_entities.dart';

/// Utility to compute numbering overlays from board entries.
class ClueNumbering {
  /// Returns a map of CellKey -> smallest entry number starting at that cell
  /// computed from minimal dependencies (grid size and entries only).
  static Map<CellKey, int> numbersFrom(
    int gridSize,
    List<PuzzleEntryData>? entries,
  ) {
    final numbers = <CellKey, int>{};
    if (entries == null || entries.isEmpty) {
      return numbers;
    }
    for (final e in entries) {
      final r = e.y;
      final c = e.x;
      if (r < 0 || r >= gridSize || c < 0 || c >= gridSize) {
        continue;
      }
      final key = CellKey(r, c);
      final current = numbers[key];
      if (current == null || e.number < current) {
        numbers[key] = e.number;
      }
    }
    return numbers;
  }

  /// Returns a map of CellKey -> smallest entry number starting at that cell.
  static Map<CellKey, int> numbersFromBoard(GameBoard board) =>
      numbersFrom(board.gridSize, board.entries);
}
