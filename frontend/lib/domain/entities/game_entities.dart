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
  });
  final List<List<String?>> grid;
  final Map<String, String> clues;

  /// true = black/blocked cell
  final List<List<bool>> blackCells;
  final int difficulty;

  /// Optional: pre-computed entries (from Puzzle model) with number/position/clue.
  /// If present, UI can use these directly instead of recalculating numbering.
  final List<PuzzleEntryData>? entries;

  /// Optional solution grid (from puzzle cells). When available, this is the
  /// authoritative answer for each cell and should be preferred over
  /// `PuzzleEntryData.answer` when validating completed words.
  final List<List<String?>>? solutionGrid;

  GameBoard copyWith({
    List<List<String?>>? grid,
    Map<String, String>? clues,
    List<List<bool>>? blackCells,
    int? difficulty,
    List<PuzzleEntryData>? entries,
    List<List<String?>>? solutionGrid,
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
    solutionGrid: solutionGrid ?? this.solutionGrid,
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
