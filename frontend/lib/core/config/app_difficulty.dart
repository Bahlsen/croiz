import 'package:flutter/material.dart';

/// Configuration for puzzle difficulty levels.
class AppDifficulty {
  static const List<({int level, String label, Color color})> levels = [
    (level: 1, label: 'Easy', color: Colors.green),
    (level: 2, label: 'Medium', color: Colors.amber),
    (level: 3, label: 'Hard', color: Colors.red),
    (level: 4, label: 'Expert', color: Colors.purple),
    (level: 5, label: 'Master', color: Colors.black),
  ];

  static String getLabel(int level) =>
      levels
          .firstWhere((d) => d.level == level, orElse: () => levels.last)
          .label;

  static Color getColor(int level) =>
      levels
          .firstWhere((d) => d.level == level, orElse: () => levels.last)
          .color;

  static int get minLevel => levels.first.level;
  static int get maxLevel => levels.last.level;
}
