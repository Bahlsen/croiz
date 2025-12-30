import 'dart:async';

import 'package:croiz/domain/entities/game_entities.dart';

/// Helper to set flashing cells and clear them after the configured delay.
///
/// This centralizes the common pattern used both when the user completes a
/// word via typing and when a word is revealed via the menu.
void triggerFlashAndPlaySuccess(
  Set<CellKey> cells,
  void Function(Set<CellKey>) writeFlashingCells,
  Duration Function() readFlashClearDelay, {

  /// Optional async callback to play a success sound when flashing starts.
  Future<void> Function()? playSuccess,

  /// Optional predicate to decide whether to play the success sound.
  /// If omitted, the helper will always attempt to play when `playSuccess`
  /// is provided. Callers should pass a function that returns true when
  /// audio is allowed (e.g. `() => !ref.read(gameAudioMutedProvider)`).
  bool Function()? shouldPlaySound,
}) {
  try {
    writeFlashingCells(cells);
    if (playSuccess != null) {
      try {
        final canPlay = shouldPlaySound == null || shouldPlaySound();
        if (canPlay) {
          // Fire-and-forget: don't await playback to avoid delaying UI logic.
          unawaited(playSuccess());
        }
      } on Object {
        // ignore audio failures
      }
    }
    final delay = readFlashClearDelay();
    if (delay == Duration.zero) {
      // Synchronous test mode: clear on next microtask
      unawaited(
        Future.microtask(() {
          try {
            writeFlashingCells(<CellKey>{});
          } on Object catch (_) {
            // ignore
          }
        }),
      );
    } else {
      Future.delayed(delay, () {
        try {
          writeFlashingCells(<CellKey>{});
        } on Object catch (_) {
          // ignore
        }
      });
    }
  } on Object catch (_) {
    // ignore errors from callers
  }
}
