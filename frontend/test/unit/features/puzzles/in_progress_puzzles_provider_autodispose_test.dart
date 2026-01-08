import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/puzzles/widgets/continue_playing_section.dart';

/// Tests for verifying that `inProgressPuzzlesProvider` uses `.autoDispose`.
///
/// This is critical because without auto-dispose, the provider caches its
/// value and does not refresh when the user navigates back to the puzzles
/// list after completing a word in a puzzle.
void main() {
  group('inProgressPuzzlesProvider autodispose', () {
    test('inProgressPuzzlesProvider should be configured as autoDispose', () {
      // With riverpod_generator, we can verify the provider is autoDispose
      // by checking its isAutoDispose property on the generated provider.
      expect(
        inProgressPuzzlesProvider.isAutoDispose,
        isTrue,
        reason:
            'inProgressPuzzlesProvider should be auto-dispose so it refreshes '
            'when the user navigates back to the puzzles list.',
      );
    });
  });
}
