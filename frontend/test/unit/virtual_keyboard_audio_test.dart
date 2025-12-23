import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/services/providers.dart';

import '../test_utils/fake_audio_service.dart';

void main() {
  testWidgets('VirtualKeyboard taps call playType', (tester) async {
    final fake = FakeAudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [gameAudioServiceProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: Scaffold(body: VirtualKeyboard())),
      ),
    );

    await tester.pumpAndSettle();

    // Tap a letter key (A should be present in default AZERTY layout).
    final aFinder = find.text('A');
    expect(aFinder, findsWidgets);
    await tester.tap(aFinder.first);
    await tester.pump();

    expect(fake.typeCount, 1);
  });

  testWidgets('VirtualKeyboard backspace calls playDelete', (tester) async {
    final fake = FakeAudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [gameAudioServiceProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: Scaffold(body: VirtualKeyboard())),
      ),
    );

    await tester.pumpAndSettle();

    final deleteFinder = find.bySemanticsLabel('Delete');
    expect(deleteFinder, findsOneWidget);
    await tester.tap(deleteFinder);
    await tester.pump();

    expect(fake.deleteCount, 1);
  });
}
