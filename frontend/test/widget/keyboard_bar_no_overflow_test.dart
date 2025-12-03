import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/crossword_keyboard_bar.dart';
import 'package:croiz/features/game/widgets/crossword_clues_banner.dart';

void main() {
  testWidgets('No overflow for very small constraints', (tester) async {
    // Use a very small height to simulate cramped environments.
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              child: CrosswordKeyboardBar(
                onKey: (_) {},
                onBackspace: () {},
              ),
            ),
          ),
        ),
      ),
    );

    // If layout produces an overflow, the test framework throws an exception.
    await tester.pumpAndSettle();

    // Both widgets should still be present.
    expect(find.byType(CrosswordClueBanner), findsOneWidget);
    expect(find.byType(CrosswordKeyboardBar), findsOneWidget);

    // The bar's height equals the constraint we gave it.
    final barSize = tester.getSize(find.byType(CrosswordKeyboardBar));
    expect(barSize.height, equals(100.0));
  });
}
