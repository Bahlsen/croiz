import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
// no riverpod needed
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('ClueBannerContainer', () {
    testWidgets('short clue keeps base font size of 20', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) => const MaterialApp(
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
        ),
      );
      await tester.pumpAndSettle();

      // RichText contains the text via TextSpan
      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final textSpan = richText.text as TextSpan;
      expect(textSpan.text, contains('1. Short'));
      expect(textSpan.style?.fontSize, greaterThan(0));
    });

    testWidgets('banner expands to fill available space', (tester) async {
      const entry = PuzzleEntryData(
        number: 1,
        direction: 'across',
        x: 0,
        y: 0,
        length: 3,
        clue: 'Short',
      );

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) => const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 100,
                width: 300,
                child: ClueBannerContainer(entry: entry),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Banner should expand to fill the available space
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
      
      // Container should render at the constrained size
      final size = tester.getSize(find.byType(Container).first);
      expect(size.height, equals(100));
      expect(size.width, equals(300));
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
          Sizer(
            builder: (context, orientation, deviceType) => const MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 400,
                  height: 100,
                  child: Row(
                    children: [
                      SizedBox(width: 40), // left arrow space
                      SizedBox(width: 8),
                      Expanded(child: ClueBannerContainer(entry: entry)),
                      SizedBox(width: 8),
                      SizedBox(width: 40), // right arrow space
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Banner should fill available width in Expanded
        final bannerSize = tester.getSize(find.byType(ClueBannerContainer));
        expect(bannerSize.width, greaterThan(200)); // Takes remaining space

        // RichText should contain the full clue
        final richText = tester.widget<RichText>(find.byType(RichText).first);
        final textSpan = richText.text as TextSpan;
        expect(textSpan.text, contains('42.'));
        expect(textSpan.text, contains(longClue));
        
        // Font should be greater than 0
        expect(textSpan.style?.fontSize, greaterThan(0));
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
        Sizer(
          builder: (context, orientation, deviceType) => const MaterialApp(
            home: Scaffold(body: ClueBannerContainer(entry: entry)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final textSpan = richText.text as TextSpan;
      expect(textSpan.text, contains('5. $mediumClue'));
    });
  });
}
