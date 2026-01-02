import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/l10n/app_localizations.dart';

void main() {
  testWidgets('Menu toggles persist across open/close', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Sizer(
          builder:
              (context, orientation, deviceType) => MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
                ),
              ),
        ),
      ),
    );

    // Open menu
    final menuButton = find.byKey(const Key('menu_button'));
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Verify keyboard style switch initially false
    final ksFinder = find.widgetWithText(SwitchListTile, 'Keyboard style');
    expect(ksFinder, findsOneWidget);
    var ks = tester.widget<SwitchListTile>(ksFinder);
    expect(ks.value, isFalse);

    // Toggle keyboard style
    await tester.tap(ksFinder);
    await tester.pumpAndSettle();

    // Close menu
    final closeButton = find.byIcon(Icons.close);
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    // Re-open menu
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Verify keyboard style persisted (true)
    final ksFinder2 = find.widgetWithText(SwitchListTile, 'Keyboard style');
    expect(ksFinder2, findsOneWidget);
    ks = tester.widget<SwitchListTile>(ksFinder2);
    expect(ks.value, isTrue);
  });
}
