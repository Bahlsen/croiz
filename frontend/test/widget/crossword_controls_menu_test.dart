import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/monetization/services/ad_service.dart';
import '../helpers/fake_monetization_service.dart';

void main() {
  testWidgets('Menu contains Report a Problem item', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monetizationServiceProvider.overrideWith(
            (ref) => FakeMonetizationService(),
          ),
        ],
        child: Sizer(
          builder:
              (context, orientation, deviceType) => MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: Stack(
                    children: [CrosswordControlsMenu(onClose: () {})],
                  ),
                ),
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final itemFinder = find.text('Report a problem');

    // Scroll if needed
    await tester.dragUntilVisible(
      itemFinder,
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(itemFinder, findsOneWidget);
    expect(find.byIcon(Icons.bug_report_outlined), findsOneWidget);
  });
}
