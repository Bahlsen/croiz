import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/crossword_keyboard_bar.dart';
import 'package:croiz/features/game/widgets/crossword_clues_banner.dart';

void main() {
  testWidgets('Keyboard bar large layout uses desired sizes', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 480,
              child: CrosswordKeyboardBar(
                onKey: (_) {},
                onBackspace: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final bannerFinder = find.byType(CrosswordClueBanner);
    expect(bannerFinder, findsOneWidget);

    final bannerSize = tester.getSize(bannerFinder);
    // Desired banner height is 120
    expect(bannerSize.height, greaterThanOrEqualTo(120.0));

    final barFinder = find.byType(CrosswordKeyboardBar);
    final barSize = tester.getSize(barFinder);

    // Ensure the whole bar is at least the total desired height (120+44+160)
    expect(barSize.height, greaterThanOrEqualTo(120.0 + 44.0 + 160.0));
  });

  testWidgets('Keyboard bar small layout respects minimums', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 180,
              child: CrosswordKeyboardBar(
                onKey: (_) {},
                onBackspace: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final bannerFinder = find.byType(CrosswordClueBanner);
    expect(bannerFinder, findsOneWidget);
    final bannerSize = tester.getSize(bannerFinder);
    // Minimum banner height is 64
    expect(bannerSize.height, greaterThanOrEqualTo(64.0));

    final barFinder = find.byType(CrosswordKeyboardBar);
    final barSize = tester.getSize(barFinder);
    // Ensure the total bar height equals the constraint we provided
    expect(barSize.height, equals(180.0));
  });
}
