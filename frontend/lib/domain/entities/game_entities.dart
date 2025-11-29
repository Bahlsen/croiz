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

class GameBoard extends GameEntity {

  GameBoard({
    required super.id,
    required super.title,
    required super.gridSize,
    required super.createdAt,
    required this.grid,
    required this.clues,
    required this.difficulty,
  });
  final List<List<String?>> grid;
  final Map<String, String> clues;
  final int difficulty;
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
