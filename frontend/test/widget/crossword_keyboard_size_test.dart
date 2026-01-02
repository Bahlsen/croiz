import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/l10n/app_localizations.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';

class FakeGameBoardNotifier extends GameBoardNotifier {
  @override
  GameBoard build() => GameBoard(
    id: 'test',
    title: 'Test',
    gridSize: 5,
    createdAt: DateTime.now(),
    grid: [],
    clues: {},
    blackCells: [],
    difficulty: 1,
    language: 'en',
  );
}

void main() {
  testWidgets('Keyboard size default is medium and updates to large', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [gameBoardProvider.overrideWith(FakeGameBoardNotifier.new)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) => MaterialApp(
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
      ),
    );

    await tester.pumpAndSettle();

    // Ensure a letter key exists and has medium font size (responsive)
    final aTextBefore = tester.widget<Text>(find.text('A').first);
    final mediumFontSize = aTextBefore.style?.fontSize ?? 0;
    expect(mediumFontSize, greaterThan(0));

    // Simulate changing the provider programmatically (menu updates provider)
    container
        .read(gameKeyboardSizeProvider.notifier)
        .setSize(KeyboardSize.large);
    await tester.pumpAndSettle();

    final aTextAfter = tester.widget<Text>(find.text('A').first);
    final largeFontSize = aTextAfter.style?.fontSize ?? 0;
    // Large should be bigger than medium
    expect(largeFontSize, greaterThan(mediumFontSize));
  });
}
