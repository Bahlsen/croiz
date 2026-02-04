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

/// Typed direction used internally to avoid stringly-typed comparisons.
enum EntryDirection { across, down }

extension PuzzleEntryDirectionX on PuzzleEntryData {
  EntryDirection get directionEnum {
    switch (direction) {
      case 'across':
        return EntryDirection.across;
      case 'down':
        return EntryDirection.down;
      default:
        // Fallback to across to avoid crashes if unexpected data appears.
        // Prefer validating inputs in converters to keep this path unreachable.
        return EntryDirection.across;
    }
  }
}

/// Typed cell identifier (row, col) replacing fragile string keys like "row,col".
class CellKey {
  const CellKey(this.row, this.col);
  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellKey && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '$row,$col';
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
    this.solutionGrid,
    this.language = 'en',
    this.hintsUsed = 0,
    this.wordsRevealed = 0,
    this.lettersUntilAd = 10,
    this.wordsUntilAd = 3,
  });
  final List<List<String?>> grid;
  final Map<String, String> clues;

  /// true = black/blocked cell
  final List<List<bool>> blackCells;
  final int difficulty;
  final String language;

  /// Number of hints used (letters or words revealed).
  final int hintsUsed;

  /// Number of full words revealed by the user.
  final int wordsRevealed;

  /// Number of free letter reveals remaining before an ad is required.
  final int lettersUntilAd;

  /// Number of free word reveals remaining before an ad is required.
  final int wordsUntilAd;

  /// Optional: pre-computed entries (from Puzzle model) with number/position/clue.
  /// If present, UI can use these directly instead of recalculating numbering.
  final List<PuzzleEntryData>? entries;

  /// Optional solution grid (from puzzle cells). When available, this is the
  /// authoritative answer for each cell and should be preferred over
  /// `PuzzleEntryData.answer` when validating completed words.
  final List<List<String?>>? solutionGrid;

  /// Performance-optimized copyWith: does NOT deep-copy lists when not provided.
  /// Caller is responsible for providing new list instances if mutation is needed.
  GameBoard copyWith({
    String? id,
    List<List<String?>>? grid,
    Map<String, String>? clues,
    List<List<bool>>? blackCells,
    int? difficulty,
    List<PuzzleEntryData>? entries,
    List<List<String?>>? solutionGrid,
    String? language,
    int? hintsUsed,
    int? wordsRevealed,
    int? lettersUntilAd,
    int? wordsUntilAd,
  }) => GameBoard(
    id: id ?? this.id,
    title: title,
    gridSize: gridSize,
    createdAt: createdAt,
    grid: grid ?? this.grid,
    clues: clues ?? this.clues,
    blackCells: blackCells ?? this.blackCells,
    difficulty: difficulty ?? this.difficulty,
    entries: entries ?? this.entries,
    solutionGrid: solutionGrid ?? this.solutionGrid,
    language: language ?? this.language,
    hintsUsed: hintsUsed ?? this.hintsUsed,
    wordsRevealed: wordsRevealed ?? this.wordsRevealed,
    lettersUntilAd: lettersUntilAd ?? this.lettersUntilAd,
    wordsUntilAd: wordsUntilAd ?? this.wordsUntilAd,
  );

  /// Helper to create a new GameBoard with a single cell updated.
  GameBoard updateCell(int row, int col, String? value) {
    if (row < 0 || row >= grid.length || col < 0 || col >= grid[row].length) {
      return this;
    }
    final newGrid = grid.map(List<String?>.from).toList();
    newGrid[row][col] = value;
    return copyWith(grid: newGrid);
  }
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
