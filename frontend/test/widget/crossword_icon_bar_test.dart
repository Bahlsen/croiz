import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_header.dart';

void main() {
  testWidgets('Menu icon is present and triggers callback', (
    WidgetTester tester,
  ) async {
    var menuPressed = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CrosswordClueHeader(
              onClear: () {},
              onMenu: () {
                menuPressed = true;
              },
            ),
          ),
        ),
      ),
    );

    // Find the menu icon button by key
    final menuButton = find.byKey(const Key('menu_button'));
    expect(menuButton, findsOneWidget);

    // Tap the menu icon
    await tester.tap(menuButton);
    await tester.pump();
    expect(menuPressed, isTrue);
  });

  testWidgets('Clear and toggle icons are present', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CrosswordClueHeader(onClear: () {}, onMenu: () {}),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('clear_button')), findsOneWidget);
    expect(find.byIcon(Icons.cleaning_services_outlined), findsOneWidget);
    // Keyboard toggle moved to the menu; verify keyboard icon is not present
    expect(find.byIcon(Icons.keyboard_alt_outlined), findsNothing);
  });
}
