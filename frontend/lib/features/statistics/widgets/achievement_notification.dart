import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A non-intrusive notification that celebration unlocking an achievement.
/// Designed to slide in from the top of the screen.
class AchievementNotification extends StatelessWidget {
  const AchievementNotification({required this.achievementId, super.key});

  final AchievementId achievementId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final title = _getTitle(l10n);

    return SafeArea(
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Icon
              Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      achievementId.icon,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(
                    duration: 2.seconds,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),

              const SizedBox(width: 12),

              // Text info
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.achievementUnlocked.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    switch (achievementId) {
      case AchievementId.firstPuzzle:
        return l10n.achievement_firstPuzzle_title;
      case AchievementId.tenPuzzles:
        return l10n.achievement_tenPuzzles_title;
      case AchievementId.hundredPuzzles:
        return l10n.achievement_hundredPuzzles_title;
      case AchievementId.weekStreak:
        return l10n.achievement_weekStreak_title;
      case AchievementId.monthStreak:
        return l10n.achievement_monthStreak_title;
      case AchievementId.speedDemon:
        return l10n.achievement_speedDemon_title;
      case AchievementId.perfectPuzzle:
        return l10n.achievement_perfectPuzzle_title;
      case AchievementId.polyglot:
        return l10n.achievement_polyglot_title;
      case AchievementId.generator:
        return l10n.achievement_generator_title;
    }
  }
}
