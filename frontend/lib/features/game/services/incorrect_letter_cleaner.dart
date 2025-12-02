import 'package:croiz/domain/entities/game_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Résultat du nettoyage : le plateau modifié et la liste des cellules nettoyées
class IncorrectLetterCleanResult {
  IncorrectLetterCleanResult(this.board, this.clearedCells);
  final GameBoard board;
  final List<String> clearedCells; // format: "row,col"
}

/// Service responsable du nettoyage des lettres incorrectes.
/// Renvoie les cellules nettoyées pour permettre un feedback visuel.
class IncorrectLetterCleaner {
  const IncorrectLetterCleaner();

  IncorrectLetterCleanResult cleanWithResult(GameBoard board) {
    final entries = board.entries;
    if (entries == null || entries.isEmpty) {
      return IncorrectLetterCleanResult(board, []);
    }

    final expected = List.generate(
      board.gridSize,
      (_) => List<String?>.filled(board.gridSize, null),
    );

    for (final entry in entries) {
      if (entry.answer == null || entry.answer!.isEmpty) {
        continue;
      }

      final answer = entry.answer!.toUpperCase();
      final isHorizontal = entry.direction == 'across';
      for (var i = 0; i < entry.length; i++) {
        final row = isHorizontal ? entry.y : entry.y + i;
        final col = isHorizontal ? entry.x + i : entry.x;
        if (row < 0 || row >= board.gridSize || col < 0 || col >= board.gridSize) {
          continue;
        }

        if (i < answer.length) {
          expected[row][col] = answer[i];
        }
      }
    }

    final newGrid = List<List<String?>>.generate(
      board.gridSize,
      (r) => List<String?>.from(board.grid[r]),
    );

    final cleared = <String>[];

    for (var r = 0; r < board.gridSize; r++) {
      for (var c = 0; c < board.gridSize; c++) {
        final expectedChar = expected[r][c];
        final current = newGrid[r][c];
        if (expectedChar != null && current != null) {
          if (current.toUpperCase() != expectedChar) {
            newGrid[r][c] = null;
            cleared.add('$r,$c');
          }
        }
      }
    }

    return IncorrectLetterCleanResult(board.copyWith(grid: newGrid), cleared);
  }
}

/// Riverpod provider pour l'injecter facilement si nécessaire.

final incorrectLetterCleanerProvider = Provider<IncorrectLetterCleaner>(
  (ref) => const IncorrectLetterCleaner(),
);
