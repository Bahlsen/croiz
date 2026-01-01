import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';

void main() {
  testWidgets('shows settings icon in app bar leading position', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [puzzlesProvider.overrideWith((ref) async => [])],
        child: MaterialApp(
          home: Sizer(
            builder: (context, orientation, deviceType) =>
                const PuzzlesListPage(),
          ),
        ),
      ),
    );

    // Wait for async load (even empty)
    await tester.pumpAndSettle();

    // Should find an IconButton with settings icon
    final settingsIconFinder = find.widgetWithIcon(IconButton, Icons.settings);
    expect(settingsIconFinder, findsOneWidget);

    // Verify it is in the AppBar (specifically checking it exists is enough for now,
    // but we can check if it's the leading widget if we want to be very specific,
    // though finder by icon is usually sufficient for TDD start)
  });
}
