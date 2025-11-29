import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/main.dart';

void main() {
  testWidgets('tap a known cell (2,0), enter a letter, and see it updated', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CroizApp()));

    // Navigate to crossword screen
    expect(find.text('Start Game'), findsOneWidget);
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    // The grid is 13x13; cell at row=2,col=0 is index = 2*13 + 0 = 26
    const cellIndex = 2 * 13 + 0;
    final cells = find.byType(GestureDetector);
    expect(cells.evaluate().length, greaterThan(cellIndex));

    await tester.tap(cells.at(cellIndex));
    await tester.pumpAndSettle();

    // Enter a letter in the focused TextField
    final tfFinder = find.byType(TextField).first;
    expect(tfFinder, findsOneWidget);
    await tester.enterText(tfFinder, 'Z');
    await tester.pumpAndSettle();

    // Verify the letter appears in the UI
    expect(find.text('Z'), findsWidgets);
  });
}
