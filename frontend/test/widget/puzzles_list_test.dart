import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';

void main() {
  testWidgets('PuzzlesListPage shows provided puzzles', (
    WidgetTester tester,
  ) async {
    final sample = [
      {'id': 'a', 'title': 'One', 'subtitle': 'S1'},
      {'id': 'b', 'title': 'Two', 'subtitle': 'S2'},
    ];

    await tester.pumpWidget(
      MaterialApp(home: PuzzlesListPage(puzzles: sample)),
    );

    expect(find.text('Puzzles'), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
  });
}
