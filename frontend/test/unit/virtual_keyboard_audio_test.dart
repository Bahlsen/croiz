import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/services/audio_service.dart';
import 'package:croiz/services/providers.dart';

class FakeAudioService implements AudioService {
  int typeCount = 0;
  int deleteCount = 0;
  int successCount = 0;
  int victoryCount = 0;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playDelete() async {
    deleteCount++;
  }

  @override
  Future<void> playSuccess() async {
    successCount++;
  }

  @override
  Future<void> playType() async {
    typeCount++;
  }

  @override
  Future<void> playVictory() async {
    victoryCount++;
  }

  @override
  Future<void> get ready async => Future<void>.value();
}

void main() {
  testWidgets('VirtualKeyboard taps call playType', (tester) async {
    final fake = FakeAudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [gameAudioServiceProvider.overrideWithValue(fake)],
        child: const MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(),
          ),
        ),
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
        child: const MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(),
          ),
        ),
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
