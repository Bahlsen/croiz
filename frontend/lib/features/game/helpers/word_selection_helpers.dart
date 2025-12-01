extension WordSelectionHelpers on List<List<bool>> {
  /// Returns the start and end indices of the contiguous word (non-black cells)
  /// in the given direction, starting from (row, col).
  /// Returns (start, end) inclusive indices.
  List<int> wordBounds(int row, int col, {required bool horizontal}) {
    final size = length;
    var start = horizontal ? col : row;
    var end = horizontal ? col : row;
    // Expand left/up
    while (start > 0 &&
        !this[horizontal ? row : start - 1][horizontal ? start - 1 : col]) {
      start--;
    }
    // Expand right/down
    while (end < size - 1 &&
        !this[horizontal ? row : end + 1][horizontal ? end + 1 : col]) {
      end++;
    }
    return [start, end];
  }
}
