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
    if (row < 0 || row >= length) {
      return true;
    }
    if (col < 0 || col >= this[row].length) {
      return true;
    }
    return this[row][col];
  }

  /// Retourne la prochaine case sélectionnable `[row, col]` en partant **après**
  /// la position `(row, col)` et en avançant par pas `(dr, dc)`.
  ///
  /// - Si une case non-disabled est trouvée lors de l'avance linéaire, elle est
  ///   retournée immédiatement.
  /// - Si l'on rencontre un out-of-bounds et `wrap == false`, on retourne `null`.
  /// - Si `wrap == true`, alors :
  ///   * En mouvement horizontal (`dr == 0`) on passe à la ligne suivante
  ///     (ou à la première ligne si on dépasse la dernière) et on cherche la
  ///     première case sélectionnable dans cette ligne (vers la droite si `dc>0`,
  ///     vers la gauche si `dc<0`). On itère les lignes jusqu'à revenir au
  ///     point de départ.
  ///   * En mouvement vertical (`dc == 0`) on passe à la colonne suivante
  ///     (ou à la première colonne si on dépasse la dernière) et on cherche
  ///     la première case sélectionnable dans cette colonne (du haut vers le bas
  ///     si `dr>0`, du bas vers le haut si `dr<0`). On itère les colonnes jusqu'à
  ///     revenir au point de départ.
  ///
  /// Retourne `null` si aucune case trouvée après un tour complet.
  List<int>? nextSelectableFrom(
    int row,
    int col,
    int dr,
    int dc, {
    bool wrap = false,
  }) {
    if (dr == 0 && dc == 0) {
      return null;
    }

    // Linear advance first
    var r = row;
    var c = col;
    while (true) {
      r += dr;
      c += dc;
      if (r < 0 || r >= length) {
        break;
      }
      if (c < 0 || c >= this[r].length) {
        break;
      }
      if (!isDisabled(r, c)) {
        return [r, c];
      }
    }

    if (!wrap) {
      return null;
    }

    // Horizontal wrapping (move across rows)
    if (dr == 0) {
      final rows = length;
      final startRow = row;
      var nextRow = (row + 1) % rows;
      while (true) {
        final rowLen = this[nextRow].length;
        if (rowLen > 0) {
          final startCol = dc >= 0 ? 0 : rowLen - 1;
          final step = dc >= 0 ? 1 : -1;
          var cc = startCol;
          while (cc >= 0 && cc < rowLen) {
            if (!isDisabled(nextRow, cc)) {
              return [nextRow, cc];
            }
            cc += step;
          }
        }
        if (nextRow == startRow) {
          break;
        }
        nextRow = (nextRow + 1) % rows;
      }
      return null;
    }

    // Vertical wrapping (move across columns)
    // Determine maximum number of columns across all rows
    var maxCols = 0;
    for (final rowList in this) {
      if (rowList.length > maxCols) {
        maxCols = rowList.length;
      }
    }
    if (maxCols == 0) {
      return null;
    }

    final startCol = col;
    var nextCol = (col + 1) % maxCols;
    while (true) {
      // iterate rows in direction of dr
      final rStart = dr > 0 ? 0 : length - 1;
      final rStep = dr > 0 ? 1 : -1;
      var rr = rStart;
      while (rr >= 0 && rr < length) {
        if (nextCol >= 0 && nextCol < this[rr].length) {
          if (!isDisabled(rr, nextCol)) {
            return [rr, nextCol];
          }
        }
        rr += rStep;
      }
      if (nextCol == startCol) {
        break;
      }
      nextCol = (nextCol + 1) % maxCols;
    }
    return null;
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
