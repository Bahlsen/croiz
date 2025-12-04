import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_keyboard_bar.dart';

void main() {
  testWidgets('Control buttons are positioned to the right and clear button present', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));

    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(
      body: Column(children: [
        const Expanded(child: Placeholder()),
        CrosswordKeyboardBar(onKey: (_) {}, onBackspace: () {}),
      ],),
    ))));

    await tester.pumpAndSettle();

    final clearFinder = find.byKey(const Key('clear_button'));
    expect(clearFinder, findsOneWidget);

    // Ensure clear button is on the right side of the bar (x coordinate > center)
    final barFinder = find.byType(CrosswordKeyboardBar);
    expect(barFinder, findsOneWidget);
    final barBox = tester.getRect(barFinder);
    final clearBox = tester.getRect(clearFinder);

    expect(clearBox.center.dx, greaterThan(barBox.center.dx));
  });
}
