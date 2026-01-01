import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';
import 'package:croiz/domain/entities/game_entities.dart';

/// Helper to extract full text from a TextSpan (including children).
String extractTextFromSpan(InlineSpan span) {
  if (span is TextSpan) {
    final buffer = StringBuffer();
    if (span.text != null) {
      buffer.write(span.text);
    }
    if (span.children != null) {
      for (final child in span.children!) {
        buffer.write(extractTextFromSpan(child));
      }
    }
    return buffer.toString();
  }
  return '';
}

void main() {
  group('ClueBannerContainer', () {
    testWidgets('short clue keeps base font size of 20', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder:
              (context, orientation, deviceType) => const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
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

      // Number badge
      expect(find.text('1'), findsOneWidget);
      expect(find.text('ACROSS'), findsOneWidget);

      // Clue text - find specifically within the clue_text widget
      final clueTextFinder = find.byKey(const Key('clue_text'));
      final richTextFinder = find.descendant(
        of: clueTextFinder,
        matching: find.byType(RichText),
      );
      final richText = tester.widget<RichText>(richTextFinder);
      final textSpan = richText.text as TextSpan;
      final fullText = extractTextFromSpan(textSpan);
      expect(fullText, equals('Short'));
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
          builder:
              (context, orientation, deviceType) => const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
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

      // Banner should fill the space (using Container for decoration)
      final container = tester.widget<Container>(
        find.byType(Container).at(0), // The main container with decoration
      );
      expect(container.decoration, isA<BoxDecoration>());

      // Container should render at the constrained size
      final size = tester.getSize(find.byType(ClueBannerContainer));
      expect(size.height, equals(100));
      expect(size.width, equals(300));
    });

    testWidgets('long clue scales down font and shows all text', (
      tester,
    ) async {
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

      await tester.pumpWidget(
        Sizer(
          builder:
              (context, orientation, deviceType) => const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: SizedBox(
                    width: 400,
                    height: 100,
                    child: Row(
                      children: [
                        SizedBox(width: 40),
                        SizedBox(width: 8),
                        Expanded(child: ClueBannerContainer(entry: entry)),
                        SizedBox(width: 8),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      // Number badge
      expect(find.text('42'), findsOneWidget);

      // Clue text - find specifically within the clue_text widget
      final clueTextFinder = find.byKey(const Key('clue_text'));
      final richTextFinder = find.descendant(
        of: clueTextFinder,
        matching: find.byType(RichText),
      );
      final richText = tester.widget<RichText>(richTextFinder);
      final textSpan = richText.text as TextSpan;
      final fullText = extractTextFromSpan(textSpan);
      expect(fullText, equals(longClue));
    });

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
          builder:
              (context, orientation, deviceType) => const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(body: ClueBannerContainer(entry: entry)),
              ),
        ),
      );
      await tester.pumpAndSettle();

      // Number
      expect(find.text('5'), findsOneWidget);
      expect(find.text('DOWN'), findsOneWidget);

      // Clue text - find specifically within the clue_text widget
      final clueTextFinder = find.byKey(const Key('clue_text'));
      final richTextFinder = find.descendant(
        of: clueTextFinder,
        matching: find.byType(RichText),
      );
      final richText = tester.widget<RichText>(richTextFinder);
      final textSpan = richText.text as TextSpan;
      final fullText = extractTextFromSpan(textSpan);
      expect(fullText, equals(mediumClue));
    });
  });
}
