import 'package:croiz/features/statistics/models/achievement.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    required this.id,
    required this.isUnlocked,
    super.key,
  });

  final AchievementId id;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isUnlocked
            ? Colors.amber
            : theme.colorScheme.onSurface.withValues(alpha: 0.1);

    // Fallback strings if l10n is not ready
    // Actually we should create l10n keys for these
    // For now, simple mapping of name

    return Tooltip(
      message: _getDescription(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isUnlocked
                    ? Colors.amber.withValues(alpha: 0.5)
                    : Colors.transparent,
            width: 2,
          ),
          boxShadow:
              isUnlocked
                  ? [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(id.icon, size: 32, color: color)
                .animate(target: isUnlocked ? 1 : 0)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.1, 1.1),
                )
                .shimmer(duration: 2.seconds),
            const SizedBox(height: 8),
            Text(
              _getTitle(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                color:
                    isUnlocked
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    // Map id to l10n keys manually as codegen for dynamic keys is hard or use simple map
    // For this iteration, I'll return hardcoded defaults if l10n key missing
    switch (id) {
      case AchievementId.firstPuzzle:
        return 'First Steps';
      case AchievementId.tenPuzzles:
        return 'Getting Serious';
      case AchievementId.hundredPuzzles:
        return 'Crossword Master';
      case AchievementId.weekStreak:
        return 'Week Warrior';
      case AchievementId.monthStreak:
        return 'Monthly Habit';
      case AchievementId.speedDemon:
        return 'Speed Demon';
      case AchievementId.perfectPuzzle:
        return 'Perfectionist';
      case AchievementId.polyglot:
        return 'Polyglot';
      case AchievementId.generator:
        return 'Creator';
    }
  }

  String _getDescription(BuildContext context) {
    switch (id) {
      case AchievementId.firstPuzzle:
        return 'Complete your first puzzle';
      case AchievementId.tenPuzzles:
        return 'Complete 10 puzzles';
      case AchievementId.hundredPuzzles:
        return 'Complete 100 puzzles';
      case AchievementId.weekStreak:
        return 'Play for 7 days in a row';
      case AchievementId.monthStreak:
        return 'Play for 30 days in a row';
      case AchievementId.speedDemon:
        return 'Complete a puzzle in under 3 minutes';
      case AchievementId.perfectPuzzle:
        return 'Complete a puzzle with 100% accuracy and no hints';
      case AchievementId.polyglot:
        return 'Complete puzzles in 3 different languages';
      case AchievementId.generator:
        return 'Generate 5 custom puzzles';
    }
  }
}
