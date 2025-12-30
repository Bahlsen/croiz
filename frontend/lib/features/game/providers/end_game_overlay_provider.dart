import 'package:flutter_riverpod/flutter_riverpod.dart';

// Listen to puzzle selection changes so the overlay is reset when a new
// puzzle is selected (fixes case where user hid the overlay and then
// navigated to another puzzle and completed it without the overlay
// reappearing).
import 'puzzle_loader_provider.dart';

class EndGameOverlayVisibleNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Default to visible on creation.
    // Reset to visible whenever the selected puzzle id changes.
    ref.listen<String?>(selectedPuzzleIdProvider, (previous, next) {
      // Only reset when a real puzzle is selected (next != null).
      if (next != null) {
        state = true;
      }
    });
    return true;
  }

  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}

final endGameOverlayVisibleProvider =
    NotifierProvider<EndGameOverlayVisibleNotifier, bool>(
      EndGameOverlayVisibleNotifier.new,
    );
