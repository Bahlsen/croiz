import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/audio_service.dart';
import 'package:croiz/features/game/providers/game_timer_provider.dart';
import 'package:croiz/features/game/services/game_persistence_service.dart';

/// Service responsible for handling end-game logic and victory coordination.
class GameEndgameService {
  GameEndgameService();

  /// Checks if the puzzle is solved and triggers end-game actions if so.
  /// returns true if the puzzle was solved.
  bool checkAndTriggerEndGame({
    required GameBoard board,
    required Set<String> foundWords,
    required String? lastLoadedPuzzleId,
    required GameTimer timer,
    required GamePersistenceService persistenceService,
    required Set<CellKey> lockedCells,
    required bool isMuted,
    required AudioService audioService,
    bool playVictorySound = true,
  }) {
    final entriesNow = board.entries;
    if (entriesNow == null || entriesNow.isEmpty) {
      return false;
    }

    if (foundWords.length == entriesNow.length) {
      // Finalize timer
      timer.finalizeSync();

      // Persist progress immediately
      unawaited(
        persistenceService.persistNow(
          puzzleId: board.id,
          grid: board.grid,
          foundWords: foundWords,
          lockedCells: lockedCells,
          elapsedSeconds: timer.elapsedSeconds,
          isCompleted: true,
        ),
      );

      if (playVictorySound) {
        if (!isMuted) {
          audioService.playVictory();
        }
      }
      return true;
    }
    return false;
  }
}

/// Provider for GameEndgameService.
final gameEndgameServiceProvider = Provider<GameEndgameService>(
  (ref) => GameEndgameService(),
);
