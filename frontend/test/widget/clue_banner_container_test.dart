import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// no riverpod needed
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('ClueBannerContainer', () {
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
      expect(text.style?.fontSize, equals(20));
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
      // Font size should be reduced from base 20 when needed
      expect(text.style?.fontSize, lessThan(20));
      expect(text.style?.fontSize, greaterThanOrEqualTo(14));
    });

    testWidgets(
      'extremely long clue shows ellipsis when it cannot fit at minFontSize',
      (tester) async {
        // An extremely long clue that cannot fit even at minFontSize of 14
        const extremelyLong =
            'This is an extremely long clue that absolutely cannot fit within '
            'two lines even at the smallest allowed font size of fourteen '
            'pixels because it just goes on and on and on forever with so many '
            'words that it must eventually be truncated with an ellipsis '
            'indicator so the user knows there is more text available';
        const entry = PuzzleEntryData(
          number: 99,
          direction: 'across',
          x: 0,
          y: 0,
          length: 15,
          clue: extremelyLong,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ConstrainedBox(
                // Very narrow constraint to force truncation
                constraints: const BoxConstraints(maxWidth: 150),
                child: const ClueBannerContainer(entry: entry),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final text = tester.widget<Text>(find.byType(Text));
        // Should have ellipsis overflow to indicate truncation
        expect(text.overflow, equals(TextOverflow.ellipsis));
        // Font size should be at minFontSize since text is too long
        expect(text.style?.fontSize, equals(14));
      },
    );

    testWidgets('text is not truncated without ellipsis when clue fits', (
      tester,
    ) async {
      // A clue that fits at reduced font size
      const mediumClue = 'A medium length clue that fits';
      const entry = PuzzleEntryData(
        number: 5,
        direction: 'down',
        x: 0,
        y: 0,
        length: 5,
        clue: mediumClue,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ClueBannerContainer(entry: entry)),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.byType(Text));
      // Full text should be visible
      expect(text.data, contains('5. $mediumClue'));
      // Overflow should be ellipsis (for consistency, even if text fits)
      expect(text.overflow, equals(TextOverflow.ellipsis));
    });
  });
}
