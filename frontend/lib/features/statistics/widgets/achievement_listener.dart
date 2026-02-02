import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/features/statistics/providers/achievement_notifier.dart';
import 'package:croiz/features/statistics/widgets/achievement_popup.dart';
import 'package:croiz/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that listens for newly unlocked achievements and displays a popup.
/// This should be placed high in the widget tree (e.g., wrapping MaterialApp's builder).
class AchievementListener extends ConsumerWidget {
  const AchievementListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for new achievement IDs
    ref.listen<AsyncValue<List<AchievementId>>>(achievementNotifier, (
      previous,
      next,
    ) {
      if (next is AsyncData<List<AchievementId>>) {
        final achievements = next.value;
        if (achievements.isNotEmpty) {
          _showAchievementPopups(context, ref, achievements);
        }
      }
    });

    return child;
  }

  void _showAchievementPopups(
    BuildContext context,
    WidgetRef ref,
    List<AchievementId> achievements,
  ) async {
    final audioService = ref.read(gameAudioServiceProvider);

    for (final id in achievements) {
      // Play achievement sound
      await audioService.playAchievement();

      // Show the popup
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AchievementPopup(achievementId: id),
        );
      }

      // Small delay between multiple popups
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
}
