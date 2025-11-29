// Helpers for manipulating the grid and black-cells in a safer place.

extension GridHelpers on List<List<String?>> {
  /// Safely set a word in the grid. Will only write within bounds.
  void setWordSafe(int row, int col, String word, {bool horizontal = true}) {
    for (var i = 0; i < word.length; i++) {
      final rr = horizontal ? row : row + i;
      final cc = horizontal ? col + i : col;
      if (rr >= 0 && rr < length && cc >= 0 && cc < this[rr].length) {
        this[rr][cc] = word[i].toUpperCase();
      }
    }
  }
}

extension BoolGridHelpers on List<List<bool>> {
  void setBlackCells(List<List<int>> coords) {
    for (final c in coords) {
      final r = c[0];
      final col = c[1];
      if (r >= 0 && r < length && col >= 0 && col < this[r].length) {
        this[r][col] = true;
      }
    }
  }
}
