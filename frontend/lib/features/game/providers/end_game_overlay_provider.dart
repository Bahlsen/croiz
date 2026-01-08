// ignore_for_file: provider_dependencies
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Listen to puzzle selection changes so the overlay is reset when a new
// puzzle is selected (fixes case where user hid the overlay and then
// navigated to another puzzle and completed it without the overlay
// reappearing).
import 'puzzle_loader_provider.dart';

part 'end_game_overlay_provider.g.dart';

@Riverpod(keepAlive: true, dependencies: [SelectedPuzzleIdNotifier])
class EndGameOverlayVisibleNotifier extends _$EndGameOverlayVisibleNotifier {
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
