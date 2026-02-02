import 'package:croiz/features/monetization/services/ad_service.dart';
import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/features/statistics/providers/achievement_notifier.dart';
import 'package:croiz/features/statistics/widgets/achievement_notification.dart';
import 'package:croiz/routes/app_router.dart';
import 'package:croiz/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that listens for newly unlocked achievements and displays popups.
///
/// This widget should be placed in the `builder` of `MaterialApp.router` to
/// ensure it wraps the entire navigation tree. It uses [rootNavigatorKey] from
/// `app_router.dart` to access the Navigator's Overlay for displaying popups.
///
/// ## How it works:
/// 1. Listens to [achievementNotifier] for newly unlocked achievements
/// 2. Waits for any fullscreen ad to be dismissed (via [MonetizationService])
/// 3. Displays achievement popups sequentially with animations
/// 4. Plays the achievement sound for each popup
///
/// ## Usage:
/// ```dart
/// MaterialApp.router(
///   routerConfig: ref.watch(appRouterProvider),
///   builder: (context, child) => AchievementListener(child: child!),
/// )
/// ```
class AchievementListener extends ConsumerWidget {
  /// Creates an [AchievementListener] that wraps [child].
  ///
  /// The optional [navigatorKey] can be used in tests to inject a custom key.
  /// In production, [rootNavigatorKey] from `app_router.dart` is used.
  const AchievementListener({
    required this.child,
    this.navigatorKey,
    super.key,
  });

  /// The child widget to wrap.
  final Widget child;

  /// Optional navigator key for accessing the overlay.
  /// If not provided, uses [rootNavigatorKey] from `app_router.dart`.
  @visibleForTesting
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for new achievement IDs from the stream
    ref.listen<AsyncValue<List<AchievementId>>>(achievementNotifier, (
      previous,
      next,
    ) {
      if (next is AsyncData<List<AchievementId>>) {
        final achievements = next.value;
        if (achievements.isNotEmpty) {
          // Schedule showing notifications after the current frame
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _showAchievementNotifications(ref, achievements);
          });
        }
      }
    });

    return child;
  }

  /// Shows achievement notification popups for the given [achievements].
  ///
  /// This method:
  /// 1. Waits for any fullscreen ad to be dismissed
  /// 2. Gets the Overlay from the navigator key
  /// 3. Shows each achievement popup sequentially with a delay
  void _showAchievementNotifications(
    WidgetRef ref,
    List<AchievementId> achievements,
  ) async {
    final audioService = ref.read(gameAudioServiceProvider);
    final monetizationService = ref.read(monetizationServiceProvider);

    // Wait for any fullscreen ad to be dismissed before showing achievements.
    // We poll for up to 500ms to catch ads that are about to show.
    final startTime = DateTime.now();
    const maxWaitDuration = Duration(seconds: 60);
    const adStartGracePeriod = Duration(milliseconds: 500);

    while (monetizationService.isAdShowing.value ||
        DateTime.now().difference(startTime) < adStartGracePeriod) {
      if (DateTime.now().difference(startTime) > maxWaitDuration) {
        // Timeout - proceed anyway to avoid blocking forever
        break;
      }

      if (monetizationService.isAdShowing.value) {
        await monetizationService.waitForAdDismissed();
        break;
      }

      // Small delay to let ad potentially start
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    // Give time for the app to fully return to foreground
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Use the provided navigator key or the global one
    final navKey = navigatorKey ?? rootNavigatorKey;
    final navigatorState = navKey.currentState;
    if (navigatorState == null) {
      return;
    }

    final overlayState = navigatorState.overlay;
    if (overlayState == null) {
      return;
    }

    // Show each achievement notification sequentially
    for (final id in achievements) {
      // Play achievement sound
      try {
        await audioService.playAchievement();
      } on Object {
        // Ignore audio errors - don't block the notification
      }

      // Show the notification via Overlay
      if (overlayState.mounted) {
        late OverlayEntry entry;
        entry = OverlayEntry(
          builder:
              (entryContext) => Positioned(
                top: MediaQuery.of(entryContext).padding.top,
                left: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child:
                      AchievementNotification(achievementId: id)
                          .animate()
                          .slideY(
                            begin: -1,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn()
                          .then(delay: 3.seconds)
                          .slideY(
                            begin: 0,
                            end: -1,
                            duration: 400.ms,
                            curve: Curves.easeIn,
                          )
                          .fadeOut(),
                ),
              ),
        );

        overlayState.insert(entry);

        // Cleanup after animation finishes (total ~4.5 seconds)
        Future.delayed(const Duration(seconds: 5), () {
          if (entry.mounted) {
            entry.remove();
          }
        });
      }

      // Delay between multiple notifications to let user see each one
      await Future.delayed(const Duration(seconds: 4));
    }
  }
}
