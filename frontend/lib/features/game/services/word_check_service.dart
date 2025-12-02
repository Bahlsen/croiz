import 'package:croiz/domain/entities/game_entities.dart';

/// Service pour vérifier si un mot est complété correctement.
class WordCheckService {
  /// Vérifie si le mot à la position donnée est complet et correct.
  /// Retourne true si toutes les lettres du mot correspondent à l'entrée du puzzle.
  bool isWordComplete(
    GameBoard board,
    PuzzleEntryData entry,
  ) {
    // Si pas de réponse définie, on ne peut pas vérifier
    if (entry.answer == null || entry.answer!.isEmpty) {
      return false;
    }
    
    final isHorizontal = entry.direction == 'across';
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

  /// Génère une clé unique pour un mot (utilisée pour le tracking).
  String getWordKey(PuzzleEntryData entry) => '${entry.y},${entry.x},${entry.direction}';

  /// Génère les clés de cellules pour un mot (format: "row,col").
  List<String> getCellKeys(PuzzleEntryData entry) {
    final keys = <String>[];
    final isHorizontal = entry.direction == 'across';
    
    for (var i = 0; i < entry.length; i++) {
      final row = isHorizontal ? entry.y : entry.y + i;
      final col = isHorizontal ? entry.x + i : entry.x;
      keys.add('$row,$col');
    }
    
    return keys;
  }
}
