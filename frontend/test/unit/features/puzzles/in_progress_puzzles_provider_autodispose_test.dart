import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/widgets/continue_playing_section.dart';

/// Tests for verifying that `inProgressPuzzlesProvider` uses `.autoDispose`.
///
/// This is critical because without auto-dispose, the provider caches its
/// value and does not refresh when the user navigates back to the puzzles
/// list after completing a word in a puzzle.
void main() {
  group('inProgressPuzzlesProvider autodispose', () {
    test('inProgressPuzzlesProvider should use autoDispose modifier', () async {
      // The provider should be auto-disposed so that it refreshes
      // when the user navigates back to the puzzles list.
      //
      // We can verify this by checking if the provider was created with
      // the autoDispose modifier. With Riverpod, when auto-dispose is enabled,
      // the provider will be disposed after a short delay when all listeners
      // are removed.

      // Create a container
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Listen to the provider to keep it alive
      final sub = container.listen(
        inProgressPuzzlesProvider,
        (previous, next) {},
      );

      // Trigger the provider to ensure it's created
      container.read(inProgressPuzzlesProvider);

      // The provider should exist while we have a listener
      expect(
        container.exists(inProgressPuzzlesProvider),
        isTrue,
        reason: 'Provider should exist while there are listeners',
      );

      // Close the subscription (simulating leaving the page)
      sub.close();

      // With autoDispose, the provider will be disposed after all listeners
      // are removed. We need to wait for the microtask queue to process.
      await Future<void>.delayed(Duration.zero);

      // If autoDispose is working, after closing the subscription and
      // waiting for the microtask queue, the provider should be disposed.
      expect(
        container.exists(inProgressPuzzlesProvider),
        isFalse,
        reason:
            'inProgressPuzzlesProvider should be auto-disposed '
            'when there are no listeners, so it refreshes on navigation back. '
            'It should not persist in the container after subscription closes.',
      );
    });
  });
}
