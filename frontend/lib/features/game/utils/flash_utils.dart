import 'dart:async';

import 'package:croiz/domain/entities/game_entities.dart';

/// Helper to set flashing cells and clear them after the configured delay.
///
/// This centralizes the common pattern used both when the user completes a
/// word via typing and when a word is revealed via the menu.
void triggerFlashAndClear(
  Set<CellKey> cells,
  void Function(Set<CellKey>) writeFlashingCells,
  Duration Function() readFlashClearDelay,
) {
  try {
    writeFlashingCells(cells);
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
