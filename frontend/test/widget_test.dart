// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:croiz/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: CroizApp()),
    );

    // Verify that the home screen displays the welcome text
    expect(find.text('Welcome to Croiz'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);

    // Tap the Start Game button and verify navigation to crossword
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();
    expect(find.text('Crossword'), findsOneWidget);
  });
}
