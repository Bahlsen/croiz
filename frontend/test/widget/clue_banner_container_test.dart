import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// no riverpod needed
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('ClueBannerContainer', () {
    testWidgets('short clue keeps base font size of 20', (tester) async {
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
                clue: 'Short',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // RichText contains the text via TextSpan
      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final textSpan = richText.text as TextSpan;
      expect(textSpan.text, contains('1. Short'));
      expect(textSpan.style?.fontSize, equals(20));
    });

    testWidgets('banner has fixed height of 96 pixels', (tester) async {
      const entry = PuzzleEntryData(
        number: 1,
        direction: 'across',
        x: 0,
        y: 0,
        length: 3,
        clue: 'Short',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: ClueBannerContainer(entry: entry)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the SizedBox that sets the fixed height
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 96,
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets(
      'long clue scales down font and shows all text',
      (tester) async {
        // A very long clue that needs scaling
        const longClue =
            'This is an extremely long clue with many many many many words '
            'that definitely cannot possibly fit at font size 20 in the fixed '
            'height banner of only 96 pixels so it must be scaled down';
        const entry = PuzzleEntryData(
          number: 42,
          direction: 'across',
          x: 0,
          y: 0,
          length: 10,
          clue: longClue,
        );

        // Simulate the real layout: Row with Expanded wrapping the banner
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: Row(
                  children: [
                    SizedBox(width: 88), // left arrow space
                    SizedBox(width: 8),
                    Expanded(child: ClueBannerContainer(entry: entry)),
                    SizedBox(width: 8),
                    SizedBox(width: 88), // right arrow space
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Banner height should still be 96
        final sizedBoxFinder = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 96,
        );
        expect(sizedBoxFinder, findsOneWidget);

        // RichText should contain the full clue
        final richText = tester.widget<RichText>(find.byType(RichText).first);
        final textSpan = richText.text as TextSpan;
        expect(textSpan.text, contains('42.'));
        expect(textSpan.text, contains(longClue));
        
        // Font should be smaller than base 20
        expect(textSpan.style?.fontSize, lessThan(20));
      },
    );

    testWidgets('text shows full content without truncation', (tester) async {
      const mediumClue = 'A medium length clue that fits nicely in the banner';
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

      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final textSpan = richText.text as TextSpan;
      expect(textSpan.text, contains('5. $mediumClue'));
    });
  });
}
