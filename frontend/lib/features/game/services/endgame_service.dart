import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_timer_provider.dart';
import 'package:croiz/services/providers.dart';

/// Centralized end-game service: finalizes timer and plays victory audio.
class EndGameService {
  EndGameService(this.ref);
  final Ref ref;

  /// Called when the puzzle is completed. This will finalize the timer and
  /// attempt to play the victory audio. It is safe to call from tests as the
  /// service guards WidgetsBinding.
  void handleGameCompleted(String boardId) {
    try {
      // Finalize timer synchronously
      try {
        ref.read(gameTimerProvider(boardId)).finalizeSync();
      } on Object catch (e, st) {
        if (kDebugMode) {
          debugPrint('EndGameService.finalizeSync failed: $e\n$st');
        }
      }

      // Only attempt audio if framework bindings are available
      try {
        WidgetsBinding.instance;
      } on Object {
        // No binding (unit tests) — skip audio
        return;
      }

      try {
        ref.read(gameAudioServiceProvider).playVictory();
      } on Object catch (e, st) {
        if (kDebugMode) {
          debugPrint('EndGameService.playVictory failed: $e\n$st');
        }
      }
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('EndGameService.handleGameCompleted failed: $e\n$st');
      }
    }
  }
}

final endGameServiceProvider = Provider<EndGameService>(EndGameService.new);
