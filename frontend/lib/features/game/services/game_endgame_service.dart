import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/services/game_persistence_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_endgame_service.g.dart';

/// Service responsible for end-game logic and presentation.
///
/// Extracted from GameBoardNotifier to follow Single Responsibility Principle.
/// Handles checking if the board is fully and correctly solved.
class GameEndgameService {
  /// Checks if the puzzle is completed and correct.
  ///
  /// A puzzle is completed if the grid matches the solution grid.
  bool isPuzzleCorrect(GameBoard board, List<List<String?>> currentGrid) {
    final solutionGrid = board.solutionGrid;
    if (solutionGrid == null) return false;

    if (board.gridSize != currentGrid.length) return false;

    for (var r = 0; r < board.gridSize; r++) {
      for (var c = 0; c < board.gridSize; c++) {
        // Skip black cells if they exist (though typically solutionGrid has nulls there)
        if (board.blackCells[r][c]) continue;

        final solution = solutionGrid[r][c];
        final current = currentGrid[r][c];

        if (solution != current) {
          return false;
        }
      }
    }

    return true;
  }

  /// Check if the board is completely filled (regardless of correctness).
  bool isBoardFilled(GameBoard board, List<List<String?>> grid) {
    for (var r = 0; r < board.gridSize; r++) {
      for (var c = 0; c < board.gridSize; c++) {
        if (board.blackCells[r][c]) continue;
        if (grid[r][c] == null || grid[r][c]!.isEmpty) return false;
      }
    }
    return true;
  }

  /// Centralized trigger for end-game transition.
  bool checkAndTriggerEndGame({
    required GameBoard board,
    required Set<String> foundWords,
    required String? lastLoadedPuzzleId,
    required dynamic timer, // For flexibility in testing
    required GamePersistenceService persistenceService,
    required Set<CellKey> lockedCells,
    required bool isMuted,
    required dynamic audioService,
    required bool playVictorySound,
  }) {
    if (board.entries == null || board.entries!.isEmpty) return false;
    if (foundWords.length < board.entries!.length) return false;

    // Puzzle solved!
    timer.stop();

    // Final persist
    persistenceService.persistNow(
      puzzleId: board.id,
      grid: board.grid,
      foundWords: foundWords,
      lockedCells: lockedCells,
      elapsedSeconds: timer.elapsedSeconds,
      isCompleted: true,
    );

    if (playVictorySound && !isMuted) {
      audioService.playVictory();
    }

    return true;
  }
}

@Riverpod(keepAlive: true, dependencies: [])
GameEndgameService gameEndgameService(Ref ref) {
  return GameEndgameService();
}
