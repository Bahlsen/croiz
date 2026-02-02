import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
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

  String _getDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
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
