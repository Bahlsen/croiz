import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// no riverpod needed
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('short clue keeps base font size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClueBannerContainer(
            entry: PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 3,
              clue: 'Short clue',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.data, contains('1. Short clue'));
    expect(text.style?.fontSize, equals(18));
  });

  testWidgets('long clue reduces font size to fit within two lines', (
    tester,
  ) async {
    const long =
        'This is a very long clue that would normally overflow the banner and therefore needs to shrink to fit within two lines without ellipsis';
    const entry = PuzzleEntryData(
      number: 42,
      direction: 'across',
      x: 0,
      y: 0,
      length: 10,
      clue: long,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: const ClueBannerContainer(entry: entry),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.data, contains('42.'));
    // Font size should be reduced from base 18 when needed
    expect(text.style?.fontSize, lessThan(18));
    expect(text.style?.fontSize, greaterThanOrEqualTo(12));
  });
}
