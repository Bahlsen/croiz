import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';

void main() {
  testWidgets('TDD: keyboard and keys are larger by default', (tester) async {
    await tester.binding.setSurfaceSize(const Size(411, 823));
    // Note: keep semantics enabled; simplify the widget tree instead.

    // Use a minimal scaffold to limit the number of semantics/overlay
    // widgets the test has to deal with.
    await tester.pumpWidget(
      ProviderScope(
        child: Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 240,
                child: VirtualKeyboard(
                  layout: VirtualKeyboard.azertyLayout,
                  onKey: (_) {},
                  onBackspace: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // The keyboard should be visible
    final keyboardFinder = find.byType(VirtualKeyboard);
    expect(keyboardFinder, findsOneWidget);

    // Find one letter key's button and measure its height
    final letterButtonFinder = find.widgetWithText(FilledButton, 'A');
    expect(letterButtonFinder, findsWidgets);
    final letterSize = tester.getSize(letterButtonFinder.first);

    // Target: keys should be larger than the previous ~52px default
    expect(letterSize.height, greaterThanOrEqualTo(56));

    // Keyboard should be reasonably tall
    final keyboardSize = tester.getSize(keyboardFinder);
    expect(keyboardSize.height, greaterThanOrEqualTo(120));
  });
}
