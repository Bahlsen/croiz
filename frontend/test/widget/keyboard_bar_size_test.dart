import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_header.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';

void main() {
  testWidgets('Keyboard bar large layout distributes space proportionally', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final bannerFinder = find.byType(CrosswordClueHeader);
    expect(bannerFinder, findsOneWidget);

    final bannerSize = tester.getSize(bannerFinder);
    final keyboardSize = tester.getSize(find.byType(VirtualKeyboard));

    // Banner now targets a portion of available space; ensure it's
    // reasonably large for readability but aligned with current layout.
    expect(bannerSize.height, greaterThanOrEqualTo(120.0));
    expect(bannerSize.height, lessThan(260.0));

    // Keyboard should remain usable (reduced but still reasonable)
    expect(keyboardSize.height, greaterThanOrEqualTo(140.0));
    expect(keyboardSize.height, lessThan(260.0));

    final barFinder = find.byType(CrosswordControlsBar);
    final barSize = tester.getSize(barFinder);

    // Total should equal constraint
    expect(barSize.height, equals(400.0));
  });

  testWidgets('Keyboard bar small layout respects minimums', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 180,
              child: CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final bannerFinder = find.byType(CrosswordClueHeader);
    expect(bannerFinder, findsOneWidget);
    final bannerSize = tester.getSize(bannerFinder);
    // Banner minimum should be respected where possible; in tight constraints
    // it may be reduced to keep keyboard usable. Validate a safe minimum.
    expect(bannerSize.height, greaterThanOrEqualTo(48.0));

    final keyboardSize = tester.getSize(find.byType(VirtualKeyboard));
    // Keyboard should respect minimum
    expect(keyboardSize.height, greaterThanOrEqualTo(100.0));

    final barFinder = find.byType(CrosswordControlsBar);
    final barSize = tester.getSize(barFinder);
    // Ensure the total bar height equals the constraint we provided
    expect(barSize.height, equals(180.0));
  });

  testWidgets('Keyboard bar adapts to different sizes dynamically', (
    tester,
  ) async {
    // Test that the same widget adjusts its layout when constraints change

    for (final height in [150.0, 250.0, 350.0, 450.0]) {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: height,
                child: CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final barSize = tester.getSize(find.byType(CrosswordControlsBar));
      expect(barSize.height, equals(height));

      // All components should be present
      expect(find.byType(CrosswordClueHeader), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);

      // No overflow
      expect(tester.takeException(), isNull);
    }
  });
}
