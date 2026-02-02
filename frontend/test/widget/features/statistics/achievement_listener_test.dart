import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/statistics/providers/achievement_notifier.dart';
import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/fake_audio_service.dart';

void main() {
  group('AchievementListener', () {
    testWidgets('AchievementNotifier broadcasts achievements correctly', (
      WidgetTester tester,
    ) async {
      // Test the notifier directly to verify the stream communication works
      final fakeAudio = FakeAudioService();

      List<AchievementId>? receivedAchievements;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [...commonOverrides(audioService: fakeAudio)],
          child: Sizer(
            builder:
                (context, orientation, deviceType) => MaterialApp(
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('en')],
                  home: Consumer(
                    builder: (context, ref, child) {
                      // Listen to the achievement notifier
                      ref.listen<AsyncValue<List<AchievementId>>>(
                        achievementNotifier,
                        (previous, next) {
                          if (next is AsyncData<List<AchievementId>>) {
                            receivedAchievements = next.value;
                          }
                        },
                      );
                      return const Scaffold(
                        body: Center(child: Text('Game Content')),
                      );
                    },
                  ),
                ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get the provider container
      final container = ProviderScope.containerOf(
        tester.element(find.text('Game Content')),
      );

      // Verify initially no achievements received
      expect(receivedAchievements, isNull);

      // Trigger achievement notification
      container.read(achievementNotifier.notifier).notifyAchievements([
        AchievementId.firstPuzzle,
        AchievementId.speedDemon,
      ]);

      // Pump to process the stream event
      await tester.pump();

      // Verify the achievements were received through the stream
      expect(receivedAchievements, isNotNull);
      expect(receivedAchievements, hasLength(2));
      expect(receivedAchievements, contains(AchievementId.firstPuzzle));
      expect(receivedAchievements, contains(AchievementId.speedDemon));
    });

    testWidgets('AchievementNotifier does not broadcast empty lists', (
      WidgetTester tester,
    ) async {
      final fakeAudio = FakeAudioService();
      var callCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [...commonOverrides(audioService: fakeAudio)],
          child: Sizer(
            builder:
                (context, orientation, deviceType) => MaterialApp(
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('en')],
                  home: Consumer(
                    builder: (context, ref, child) {
                      ref.listen<AsyncValue<List<AchievementId>>>(
                        achievementNotifier,
                        (previous, next) {
                          callCount++;
                        },
                      );
                      return const Scaffold(
                        body: Center(child: Text('Game Content')),
                      );
                    },
                  ),
                ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.text('Game Content')),
      );

      // Try to notify with an empty list
      container.read(achievementNotifier.notifier).notifyAchievements([]);

      await tester.pump();

      // Verify the callback was not called (empty list should not trigger)
      expect(callCount, equals(0));
    });
  });
}
