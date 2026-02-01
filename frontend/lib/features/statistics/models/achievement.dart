import 'package:flutter/material.dart';

enum AchievementId {
  firstPuzzle,
  tenPuzzles,
  hundredPuzzles,
  weekStreak,
  monthStreak,
  speedDemon, // < 3 mins
  perfectPuzzle, // No hints, 100% accuracy
  polyglot, // 3+ languages (not easily trackable without more complex queries, maybe skip for now)
  generator, // Generated 5 puzzles (needs tracking generation count)
}

extension AchievementMetadata on AchievementId {
  IconData get icon {
    switch (this) {
      case AchievementId.firstPuzzle:
        return Icons.star_outline_rounded;
      case AchievementId.tenPuzzles:
        return Icons.stars_rounded;
      case AchievementId.hundredPuzzles:
        return Icons.workspace_premium_rounded;
      case AchievementId.weekStreak:
        return Icons.local_fire_department_rounded;
      case AchievementId.monthStreak:
        return Icons.whatshot_rounded;
      case AchievementId.speedDemon:
        return Icons.timer_rounded;
      case AchievementId.perfectPuzzle:
        return Icons.check_circle_outline_rounded;
      case AchievementId.polyglot:
        return Icons.translate_rounded;
      case AchievementId.generator:
        return Icons.auto_awesome_rounded;
    }
  }

  // We will return translation keys, assuming standard naming
  String get titleKey => 'achievement_${name}_title';
  String get descKey => 'achievement_${name}_desc';
}
