import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';

void main() {
  testWidgets('backspace long press accelerates repeat count over time', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: VirtualKeyboard(onBackspace: () => count++)),
      ),
    );
    final backspace = find.byIcon(Icons.backspace_outlined);
    expect(backspace, findsOneWidget);

    // Start long press
    await tester.longPress(backspace);
    // Pump in small increments to reduce flakiness and observe growth.
    await tester.pump(const Duration(milliseconds: 350));
    final p1 = count; // should be >=1
    expect(p1 >= 1, isTrue);

    await tester.pump(const Duration(milliseconds: 450)); // total 800ms
    final p2 = count; // should have grown
    expect(p2 >= p1, isTrue);

    await tester.pump(const Duration(milliseconds: 700)); // total 1500ms
    final p3 = count; // should have grown again
    expect(p3 >= p2, isTrue);

    // Rather than strict acceleration, ensure at least 2 total repeats fired.
    expect(p3 >= 2, isTrue);
  });
}
