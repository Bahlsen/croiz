import 'package:croiz/domain/entities/game_entities.dart';

/// Service pour vérifier si un mot est complété correctement.
class WordCheckService {
  /// Vérifie si le mot à la position donnée est complet et correct.
  /// Retourne true si toutes les lettres du mot correspondent à l'entrée du puzzle.
  bool isWordComplete(GameBoard board, PuzzleEntryData entry) {
    final isHorizontal = entry.directionEnum == EntryDirection.across;

    // Prefer authoritative cell solutions when available.
    final solutions = board.solutionGrid;
    if (solutions != null) {
      for (var i = 0; i < entry.length; i++) {
        final row = isHorizontal ? entry.y : entry.y + i;
        final col = isHorizontal ? entry.x + i : entry.x;
        if (row >= board.gridSize || col >= board.gridSize) {
          return false;
        }
        final sol = solutions[row][col];
        final cellValue = board.grid[row][col];
        if (sol == null) {
          // No authoritative solution for this cell: fall back to requiring
          // that the cell is filled (can't verify correctness without solution).
          if (cellValue == null || cellValue.isEmpty) {
            return false;
          }
        } else {
          // Compare filled value to solution
          if (cellValue == null || cellValue.isEmpty) {
            return false;
          }
          if (cellValue.toUpperCase() != sol.toUpperCase()) {
            return false;
          }
        }
      }
      return true;
    }
    // No solutionGrid available: fall back to entry.answer if present.
    if (entry.answer != null && entry.answer!.isNotEmpty) {
      final answer = entry.answer!.toUpperCase();
      for (var i = 0; i < entry.length; i++) {
        final row = isHorizontal ? entry.y : entry.y + i;
        final col = isHorizontal ? entry.x + i : entry.x;
        if (row >= board.gridSize || col >= board.gridSize) {
          return false;
        }
        final cellValue = board.grid[row][col];
        if (cellValue == null || cellValue.isEmpty) {
          return false;
        }
        if (cellValue.toUpperCase() != answer[i]) {
          return false;
        }
      }
      return true;
    }

    // No solutionGrid and no declared answer: consider the word complete when
    // all constituent cells are non-empty (best-effort behavior).
    for (var i = 0; i < entry.length; i++) {
      final row = isHorizontal ? entry.y : entry.y + i;
      final col = isHorizontal ? entry.x + i : entry.x;
      if (row >= board.gridSize || col >= board.gridSize) {
        return false;
      }
      final cellValue = board.grid[row][col];
      if (cellValue == null || cellValue.isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Génère une clé unique pour un mot (utilisée pour le tracking).
  String getWordKey(PuzzleEntryData entry) =>
      '${entry.y},${entry.x},${entry.directionEnum.name}';

  /// Génère les clés de cellules pour un mot (typed `CellKey`).
  List<CellKey> getCellKeys(PuzzleEntryData entry) {
    final keys = <CellKey>[];
    final isHorizontal = entry.directionEnum == EntryDirection.across;

    for (var i = 0; i < entry.length; i++) {
      final row = isHorizontal ? entry.y : entry.y + i;
      final col = isHorizontal ? entry.x + i : entry.x;
      keys.add(CellKey(row, col));
    }

    return keys;
  }

  /// Scans the entire board for correctly completed words.
  Set<String> scanForCompletedWords(GameBoard board, List<List<String?>> grid) {
    if (board.entries == null) {
      return <String>{};
    }

    final boardWithGrid = board.copyWith(grid: grid);
    final found = <String>{};
    for (final entry in board.entries!) {
      if (isWordComplete(boardWithGrid, entry)) {
        found.add(getWordKey(entry));
      }
    }
    return found;
  }
}
