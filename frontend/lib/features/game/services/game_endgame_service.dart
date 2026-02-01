import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/services/game_persistence_service.dart';
import 'package:croiz/features/statistics/providers/statistics_providers.dart';
import 'package:croiz/features/statistics/services/statistics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_endgame_service.g.dart';

/// Service responsible for end-game logic and presentation.
class GameEndgameService {
  GameEndgameService(this._statsService);

  final StatisticsService _statsService;

  /// Checks if the puzzle is completed and correct.
  bool isPuzzleCorrect(GameBoard board, List<List<String?>> currentGrid) {
    final solutionGrid = board.solutionGrid;
    if (solutionGrid == null) {
      return false;
    }

    if (board.gridSize != currentGrid.length) {
      return false;
    }

    for (var r = 0; r < board.gridSize; r++) {
      for (var c = 0; c < board.gridSize; c++) {
        if (board.blackCells[r][c]) {
          continue;
        }
        if (solutionGrid[r][c] != currentGrid[r][c]) {
          return false;
        }
      }
    }
    return true;
  }

  /// Check if the board is completely filled.
  bool isBoardFilled(GameBoard board, List<List<String?>> grid) {
    for (var r = 0; r < board.gridSize; r++) {
      for (var c = 0; c < board.gridSize; c++) {
        if (board.blackCells[r][c]) {
          continue;
        }
        if (grid[r][c] == null || grid[r][c]!.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  /// Centralized trigger for end-game transition.
  bool checkAndTriggerEndGame({
    required GameBoard board,
    required Set<String> foundWords,
    required String? lastLoadedPuzzleId,
    required dynamic timer,
    required GamePersistenceService persistenceService,
    required Set<CellKey> lockedCells,
    required bool isMuted,
    required dynamic audioService,
    required bool playVictorySound,
  }) {
    if (board.entries == null || board.entries!.isEmpty) {
      return false;
    }
    if (foundWords.length < board.entries!.length) {
      return false;
    }

    // Puzzle solved!
    timer.pause();
    final timeSeconds = (timer.elapsedSeconds as int?) ?? 0;

    // Record statistics (Phase 4)
    if (playVictorySound) {
      // We only record if it's a fresh completion (not a restore on load)
      _statsService.recordPuzzleCompletion(
        puzzleId: board.id,
        timeSeconds: timeSeconds,
        totalWords: board.entries!.length,
        wordsFound: foundWords.length,
        hintsUsed: board.hintsUsed,
        accuracy: 1, // Simplification: we assume 100% if they finished
        wordsRevealed: board.wordsRevealed,
      );
    }

    // Final persist
    persistenceService.persistNow(
      puzzleId: board.id,
      grid: board.grid,
      foundWords: foundWords,
      lockedCells: lockedCells,
      elapsedSeconds: timeSeconds,
      hintsUsed: board.hintsUsed,
      wordsRevealed: board.wordsRevealed,
      isCompleted: true,
    );

    if (playVictorySound && !isMuted) {
      audioService.playVictory();
    }

    return true;
  }
}

@Riverpod(keepAlive: true, dependencies: [statisticsService])
GameEndgameService gameEndgameService(Ref ref) {
  final statsService = ref.watch(statisticsServiceProvider);
  return GameEndgameService(statsService);
}
