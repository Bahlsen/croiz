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

  /// Returns true when the given cell is disabled: either out of bounds or a black cell.
  bool isDisabled(int row, int col) {
    if (row < 0 || row >= length) return true;
    if (col < 0 || col >= this[row].length) return true;
    return this[row][col];
  }
}

extension WordSelectionHelpers on List<List<bool>> {
  /// Returns the start and end indices of the contiguous word (non-black cells)
  /// in the given direction, starting from (row, col).
  /// Returns (start, end) inclusive indices.
  List<int> wordBounds(int row, int col, {required bool horizontal}) {
    final size = length;
    var start = horizontal ? col : row;
    var end = horizontal ? col : row;
    // Expand left/up
    while (start > 0 && !this[horizontal ? row : start - 1][horizontal ? start - 1 : col]) {
      start--;
    }
    // Expand right/down
    while (end < size - 1 && !this[horizontal ? row : end + 1][horizontal ? end + 1 : col]) {
      end++;
    }
    return [start, end];
  }
}
