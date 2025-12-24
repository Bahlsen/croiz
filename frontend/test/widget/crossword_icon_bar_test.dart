import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_icon_bar.dart';

void main() {
  testWidgets('Menu icon is present and triggers callback', (
    WidgetTester tester,
  ) async {
    var menuPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CrosswordIconBar(
            isAzerty: false,
            onClear: () {},
            onToggle: () {},
            onMenu: () {
              menuPressed = true;
            },
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
      MaterialApp(
        home: Scaffold(
          body: CrosswordIconBar(
            isAzerty: false,
            onClear: () {},
            onToggle: () {},
            onMenu: () {},
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('clear_button')), findsOneWidget);
    expect(find.byIcon(Icons.cleaning_services_outlined), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_alt_outlined), findsOneWidget);
  });
}
