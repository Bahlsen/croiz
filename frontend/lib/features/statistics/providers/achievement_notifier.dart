import 'dart:async';

import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'achievement_notifier.g.dart';

/// A notifier that broadcasts newly unlocked achievements.
/// Other parts of the app can listen to this stream to show popups.
@Riverpod(keepAlive: true, name: 'achievementNotifier')
class AchievementNotifier extends _$AchievementNotifier {
  final _controller = StreamController<List<AchievementId>>.broadcast();

  @override
  Stream<List<AchievementId>> build() {
    // Clean up when the provider is disposed
    ref.onDispose(_controller.close);

    return _controller.stream;
  }

  /// Notify listeners about newly unlocked achievements
  void notifyAchievements(List<AchievementId> achievements) {
    if (achievements.isNotEmpty) {
      _controller.add(achievements);
    }
  }
}
