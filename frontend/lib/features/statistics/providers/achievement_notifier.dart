import 'dart:async';

import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'achievement_notifier.g.dart';

/// A stream-based notifier that broadcasts newly unlocked achievements.
///
/// This notifier uses a broadcast [StreamController] to allow multiple listeners
/// (e.g., the `AchievementListener` widget) to react to achievement unlocks.
///
/// ## Usage:
/// ```dart
/// // Listen to achievements (typically done in AchievementListener)
/// ref.listen(achievementNotifier, (previous, next) {
///   if (next is AsyncData<List<AchievementId>>) {
///     // Show popup for next.value
///   }
/// });
///
/// // Notify about new achievements (typically done in StatisticsService)
/// ref.read(achievementNotifier.notifier).notifyAchievements([
///   AchievementId.firstPuzzle,
/// ]);
/// ```
@Riverpod(keepAlive: true, name: 'achievementNotifier')
class AchievementNotifier extends _$AchievementNotifier {
  final _controller = StreamController<List<AchievementId>>.broadcast();

  @override
  Stream<List<AchievementId>> build() {
    // Clean up when the provider is disposed
    ref.onDispose(_controller.close);
    return _controller.stream;
  }

  /// Broadcasts newly unlocked achievements to all listeners.
  ///
  /// This is typically called by `StatisticsService.recordPuzzleCompletion`
  /// after checking for new achievements.
  void notifyAchievements(List<AchievementId> achievements) {
    if (achievements.isNotEmpty) {
      _controller.add(achievements);
    }
  }
}
