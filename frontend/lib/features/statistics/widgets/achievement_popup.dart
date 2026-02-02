import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A popup dialog that celebrates unlocking an achievement.
class AchievementPopup extends StatelessWidget {
  const AchievementPopup({required this.achievementId, super.key});

  final AchievementId achievementId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Get achievement title and description
    final title = _getTitle(l10n);
    final description = _getDescription(l10n);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Achievement icon with glow effect
                Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        achievementId.icon,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 2.seconds,
                      color: Colors.white.withValues(alpha: 0.3),
                    )
                    .shake(hz: 0.5, curve: Curves.easeInOut),

                const SizedBox(height: 24),

                // "Achievement Unlocked!" text
                Text(
                  l10n.achievementUnlocked,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3, end: 0),

                const SizedBox(height: 12),

                // Achievement title
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.3, end: 0),

                const SizedBox(height: 8),

                // Achievement description
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 600.ms).slideY(begin: -0.3, end: 0),

                const SizedBox(height: 24),

                // Close button
                FilledButton.tonal(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(l10n.continueButton),
                    )
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
          )
          .animate()
          .scale(
            duration: 500.ms,
            curve: Curves.elasticOut,
            begin: const Offset(0.5, 0.5),
          )
          .fadeIn(duration: 300.ms),
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

  String _getDescription(AppLocalizations l10n) {
    switch (achievementId) {
      case AchievementId.firstPuzzle:
        return l10n.achievement_firstPuzzle_desc;
      case AchievementId.tenPuzzles:
        return l10n.achievement_tenPuzzles_desc;
      case AchievementId.hundredPuzzles:
        return l10n.achievement_hundredPuzzles_desc;
      case AchievementId.weekStreak:
        return l10n.achievement_weekStreak_desc;
      case AchievementId.monthStreak:
        return l10n.achievement_monthStreak_desc;
      case AchievementId.speedDemon:
        return l10n.achievement_speedDemon_desc;
      case AchievementId.perfectPuzzle:
        return l10n.achievement_perfectPuzzle_desc;
      case AchievementId.polyglot:
        return l10n.achievement_polyglot_desc;
      case AchievementId.generator:
        return l10n.achievement_generator_desc;
    }
  }
}
