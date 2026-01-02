import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';

void main() {
  testWidgets('PuzzlesListPage shows provided puzzles', (
    WidgetTester tester,
  ) async {
    final sample = [
      PuzzleDescriptor(id: 'a', title: 'One', path: 'assets/data/a.json'),
      PuzzleDescriptor(id: 'b', title: 'Two', path: 'assets/data/b.json'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [puzzlesProvider.overrideWithValue(AsyncValue.data(sample))],
        child: Sizer(
          builder:
              (context, orientation, deviceType) =>
                  const MaterialApp(home: PuzzlesListPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // New UI shows puzzles directly in a flat list (no expansion tiles)
    expect(find.text('Puzzles'), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
  });
}
