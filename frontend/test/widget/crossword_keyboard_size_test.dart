import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/l10n/app_localizations.dart';

void main() {
  testWidgets('Keyboard size default is medium and updates to large', (
    tester,
  ) async {
    final container = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Stack(
              children: [
                // Show both menu and controls bar so UI uses same providers
                CrosswordControlsMenu(onClose: () {}),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CrosswordControlsBar(
                    onKey: (_) {},
                    onBackspace: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure a letter key exists and has medium font size (16)
    final aTextBefore = tester.widget<Text>(find.text('A').first);
    expect(aTextBefore.style?.fontSize, 16);

    // Simulate changing the provider programmatically (menu updates provider)
    container.read(gameKeyboardSizeProvider.notifier).setSize(KeyboardSize.large);
    await tester.pumpAndSettle();

    final aTextAfter = tester.widget<Text>(find.text('A').first);
    expect(aTextAfter.style?.fontSize, 20);
  });
}
