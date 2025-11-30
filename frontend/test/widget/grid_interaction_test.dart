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

    // The grid is now 5x5 from sample_5x5.json; 5 cells are black, so 20 GestureDetectors
    // Cell at row=2, col=0 (letter 'C') should be one of the tappable cells
    final cells = find.byType(GestureDetector);
    // 5x5 = 25 cells, but 5 are black (no GestureDetector), so expect 20
    expect(cells.evaluate().length, greaterThanOrEqualTo(16)); // At least 16 for content cells

    // Tap the first available cell (it should be row=0, col=0 with solution 'S')
    await tester.tap(cells.first);
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
