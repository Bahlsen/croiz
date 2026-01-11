import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/game/widgets/keyboard/virtual_keyboard.dart';
import 'package:croiz/services/providers.dart';
import '../helpers/fake_audio_service.dart';

void main() {
  group('VirtualKeyboard simplified (no extra letters)', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            SystemChannels.platform,
            (methodCall) async => null,
          ); // Handle haptic feedback calls
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
    testWidgets(
      'injects backspace when includeBackspace true and absent from layout',
      (tester) async {
        // Default layout does not explicitly include BACKSPACE token.
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              gameAudioServiceProvider.overrideWithValue(FakeAudioService()),
            ],
            child: const MaterialApp(home: Scaffold(body: VirtualKeyboard())),
          ),
        );
        expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      },
    );

    testWidgets('does not inject backspace when includeBackspace=false', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(FakeAudioService()),
          ],
          child: const MaterialApp(
            home: Scaffold(body: VirtualKeyboard(includeBackspace: false)),
          ),
        ),
      );
      expect(find.byIcon(Icons.backspace_outlined), findsNothing);
    });

    testWidgets('no duplicate backspace if token already present', (
      tester,
    ) async {
      final customLayout = [
        ['A', 'B', 'C'],
        ['D', VirtualKeyboard.backspaceToken],
      ];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(FakeAudioService()),
          ],
          child: MaterialApp(
            home: Scaffold(body: VirtualKeyboard(layout: customLayout)),
          ),
        ),
      );
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('enabledLetters restricts taps for disabled letters', (
      tester,
    ) async {
      String? tapped;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(FakeAudioService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VirtualKeyboard(
                enabledLetters: const {'A', 'B'},
                onKey: (k) => tapped = k,
              ),
            ),
          ),
        ),
      );
      // Tap disabled letter C
      await tester.tap(find.text('C'));
      await tester.pump();
      expect(tapped, isNull);
      // Tap enabled letter A
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(tapped, 'A');
    });

    testWidgets('backspace tap triggers callback', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(FakeAudioService()),
          ],
          child: MaterialApp(
            home: Scaffold(body: VirtualKeyboard(onBackspace: () => count++)),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(count, 1);
    });

    testWidgets(
      'backspace long press triggers multiple callbacks (repeat acceleration)',
      (tester) async {
        var count = 0;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              gameAudioServiceProvider.overrideWithValue(FakeAudioService()),
            ],
            child: MaterialApp(
              home: Scaffold(body: VirtualKeyboard(onBackspace: () => count++)),
            ),
          ),
        );
        final backspaceFinder = find.byIcon(Icons.backspace_outlined);
        expect(backspaceFinder, findsOneWidget);
        // Long press (built-in helper). Timer logic should cause multiple invocations after enough time.
        await tester.longPress(backspaceFinder);
        // Allow time for several repeat phases.
        await tester.pump(const Duration(milliseconds: 900));
        expect(count >= 2, isTrue);
      },
    );

    testWidgets('custom lowercase layout emits uppercase letters', (
      tester,
    ) async {
      final layout = [
        ['a', 'b'],
      ];
      String? tapped;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(FakeAudioService()),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: VirtualKeyboard(
                layout: layout,
                onKey: (k) => tapped = k,
                includeBackspace: false,
                enableFeedback: false,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(tapped, 'A');
    });
  });
}
