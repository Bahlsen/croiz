import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clues_banner.dart';
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

    final bannerFinder = find.byType(CrosswordClueBanner);
    expect(bannerFinder, findsOneWidget);

    final bannerSize = tester.getSize(bannerFinder);
    final keyboardSize = tester.getSize(find.byType(VirtualKeyboard));

    // Banner should take ~35% of available space
    expect(bannerSize.height, greaterThan(100.0));
    expect(bannerSize.height, lessThan(200.0));

    // Keyboard should take ~50% and be usable
    expect(keyboardSize.height, greaterThan(150.0));
    expect(keyboardSize.height, lessThan(300.0));

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

    final bannerFinder = find.byType(CrosswordClueBanner);
    expect(bannerFinder, findsOneWidget);
    final bannerSize = tester.getSize(bannerFinder);
    // Minimum banner height is 48
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
      expect(find.byType(CrosswordClueBanner), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);

      // No overflow
      expect(tester.takeException(), isNull);
    }
  });
}
