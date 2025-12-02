/// Game domain entities
abstract class GameEntity {
  GameEntity({
    required this.id,
    required this.title,
    required this.gridSize,
    required this.createdAt,
  });
  final String id;
  final String title;
  final int gridSize;
  final DateTime createdAt;
}

/// Lightweight representation of a puzzle entry (for numbering/clues).
class PuzzleEntryData {
  const PuzzleEntryData({
    required this.number,
    required this.direction,
    required this.x,
    required this.y,
    required this.length,
    this.clue,
    this.answer,
  });
  final int number;
  final String direction; // 'across' or 'down'
  final int x;
  final int y;
  final int length;
  final String? clue;
  final String? answer;
}

class GameBoard extends GameEntity {
  GameBoard({
    required super.id,
    required super.title,
    required super.gridSize,
    required super.createdAt,
    required this.grid,
    required this.clues,
    required this.blackCells,
    required this.difficulty,
    this.entries,
  });
  final List<List<String?>> grid;
  final Map<String, String> clues;

  /// true = black/blocked cell
  final List<List<bool>> blackCells;
  final int difficulty;

  /// Optional: pre-computed entries (from Puzzle model) with number/position/clue.
  /// If present, UI can use these directly instead of recalculating numbering.
  final List<PuzzleEntryData>? entries;

  GameBoard copyWith({
    List<List<String?>>? grid,
    Map<String, String>? clues,
    List<List<bool>>? blackCells,
    int? difficulty,
    List<PuzzleEntryData>? entries,
  }) => GameBoard(
    id: id,
    title: title,
    gridSize: gridSize,
    createdAt: createdAt,
    grid:
        grid ??
        List.generate(
          this.grid.length,
          (r) => List<String?>.from(this.grid[r]),
        ),
    clues: clues ?? Map<String, String>.from(this.clues),
    blackCells:
        blackCells ??
        List.generate(
          this.blackCells.length,
          (r) => List<bool>.from(this.blackCells[r]),
        ),
    difficulty: difficulty ?? this.difficulty,
    entries: entries ?? this.entries,
  );
}

class GameScore {
  GameScore({
    required this.gameId,
    required this.userId,
    required this.score,
    required this.timeTaken,
    required this.completedAt,
  });
  final String gameId;
  final String userId;
  final int score;
  final int timeTaken;
  final DateTime completedAt;
}

class Player {
  Player({
    required this.id,
    required this.username,
    required this.totalGamesPlayed,
    required this.gamesWon,
    required this.totalScore,
  });
  final String id;
  final String username;
  final int totalGamesPlayed;
  final int gamesWon;
  final int totalScore;
}
