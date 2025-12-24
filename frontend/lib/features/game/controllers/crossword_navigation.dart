import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/helpers/board_helpers.dart';

/// Returns the next editable cell in the given direction, skipping locked cells.
List<int>? nextEditableCell(
  GameBoard board, {
  required int fromRow,
  required int fromCol,
  required int dr,
  required int dc,
  required bool wrap,
  required Set<CellKey> lockedCells,
}) {
  var r = fromRow;
  var c = fromCol;
  final maxSteps = board.gridSize * board.gridSize;
  for (var i = 0; i < maxSteps; i++) {
    final next = board.blackCells.nextSelectableFrom(r, c, dr, dc, wrap: wrap);
    if (next == null) {
      return null;
    }
    final nr = next[0];
    final nc = next[1];
    if (!lockedCells.contains(CellKey(nr, nc))) {
      return [nr, nc];
    }
    r = nr;
    c = nc;
  }
  return null;
}

/// Returns the first selectable (non-disabled) cell coordinates from black mask.
List<int>? firstSelectable(List<List<bool>> black) {
  for (var r = 0; r < black.length; r++) {
    for (var c = 0; c < black[r].length; c++) {
      if (!black.isDisabled(r, c)) {
        return [r, c];
      }
    }
  }
  return null;
}

/// Determines whether a cell belongs to any word entry (across/down) in entries.
bool cellBelongsToWord(int row, int col, List<PuzzleEntryData>? entries) {
  if (entries == null || entries.isEmpty) {
    return true;
  }

  for (final entry in entries) {
    final isAcross = entry.direction == 'across';
    if (isAcross) {
      if (row == entry.y && col >= entry.x && col < entry.x + entry.length) {
        return true;
      }
    } else {
      if (col == entry.x && row >= entry.y && row < entry.y + entry.length) {
        return true;
      }
    }
  }
  return false;
}
