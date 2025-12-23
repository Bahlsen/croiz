import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/splash/splash_screen.dart';
import 'package:croiz/services/audio_service.dart';
import 'package:croiz/services/providers.dart';

class _ImmediateAudioService implements AudioService {
  @override
  Future<void> get ready => Future.value();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playDelete() async {}

  @override
  Future<void> playSuccess() async {}

  @override
  Future<void> playType() async {}

  @override
  Future<void> playVictory() async {}
}

void main() {
  testWidgets('Splash waits at least animation duration before finishing',
      (WidgetTester tester) async {
    var initialized = false;

    await tester.pumpWidget(
      ProviderScope(overrides: [
        gameAudioServiceProvider.overrideWithValue(_ImmediateAudioService()),
      ], child: MaterialApp(home: SplashScreen(onInitialized: () {
        initialized = true;
      }))),
    );

    // initial pump starts animation; onInitialized should NOT be called immediately
    await tester.pump();
    expect(initialized, isFalse);

    // Advance less than animation duration (1500ms): still should not be initialized
    await tester.pump(const Duration(milliseconds: 800));
    expect(initialized, isFalse);

    // Advance to just before animation+buffer (1500 + 300 = 1800ms total)
    await tester.pump(const Duration(milliseconds: 900));
    // Total advanced: 1700ms (800+900) - still less than 1800
    expect(initialized, isFalse);

    // Advance the remaining to surpass animation + buffer
    await tester.pump(const Duration(milliseconds: 200));
    // Now the callback should have been invoked
    expect(initialized, isTrue);
  });
}
