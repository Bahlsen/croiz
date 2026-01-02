import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/generation/widgets/generation_dialog.dart';

void main() {
  testWidgets('GenerationDialog handles small height without overflow', (
    WidgetTester tester,
  ) async {
    // Standard small phone size (common for keyboard simulation)
    // 360x640 is a standard Android size.
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: GenerationDialog())),
      ),
    );

    await tester.pumpAndSettle();

    // Verify dialog is there
    expect(find.byType(GenerationDialog), findsOneWidget);

    // Tap GENERATE to trigger error and height increase
    final generateButton = find.text('GENERATE');
    await tester.ensureVisible(generateButton);
    await tester.tap(generateButton);
    await tester.pumpAndSettle();

    // Verify error and no overflow
    expect(find.text('Please enter a topic'), findsOneWidget);
  });
}
