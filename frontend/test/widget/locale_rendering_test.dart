import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/l10n/app_localizations.dart';

void main() {
  testWidgets('AppLocalizations renders translations for supported locales', (
    tester,
  ) async {
    final cases = {
      const Locale('fr'): 'Mots croisés',
      const Locale('uk'): 'Головоломки',
    };

    for (final entry in cases.entries) {
      await tester.pumpWidget(
        MaterialApp(
          locale: entry.key,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: Center(
                    child: Text(AppLocalizations.of(context)!.puzzles),
                  ),
                ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    }
  });
}
