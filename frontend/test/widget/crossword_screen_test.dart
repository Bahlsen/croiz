import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/crossword_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('CrosswordScreen loads and displays with puzzle data', (
    tester,
  ) async {
    // Wrap in ProviderScope for Riverpod
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CrosswordScreen())),
    );

    // Initial pump to start async loading
    await tester.pump();

    // Wait for puzzle to load (FutureProvider)
    await tester.pumpAndSettle();

    // Verify the screen builds without errors
    expect(find.byType(CrosswordScreen), findsOneWidget);

    // Verify AppBar title is present
    expect(find.text('Crossword'), findsOneWidget);

    // Note: The grid will be empty initially since we don't pre-fill solutions by default.
    // The test validates that the widget tree builds successfully with the JSON-loaded puzzle.
  });
}
