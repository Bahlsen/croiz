import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';
import 'package:croiz/l10n/app_localizations.dart';

void main() {
  testWidgets('Language dropdown in menu updates locale and persists', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        child: Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: Stack(children: [CrosswordControlsMenu(onClose: () {})]),
              ),
            ),
          ),
        ),
      ),
    );

    // Verify dropdown exists
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    // Open the dropdown
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    // Tap French
    await tester.tap(find.text('French').last);
    await tester.pumpAndSettle();

    // Verify SharedPreferences contains the selected locale
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('locale'), 'fr');
  });
}
