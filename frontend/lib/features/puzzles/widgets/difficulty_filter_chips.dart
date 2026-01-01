import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../puzzle_filter_provider.dart';

/// A row of filter chips for selecting puzzle difficulties.
class DifficultyFilterChips extends ConsumerWidget {
  const DifficultyFilterChips({super.key});

  /// Difficulty configuration: level, label, and color.
  static const List<({int level, String label, Color color})> _difficulties = [
    (level: 1, label: 'Easy', color: Colors.green),
    (level: 2, label: 'Medium', color: Colors.amber),
    (level: 3, label: 'Hard', color: Colors.red),
    (level: 4, label: 'Expert', color: Colors.purple),
    (level: 5, label: 'Master', color: Colors.black),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(puzzleFilterProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _difficulties.map((difficulty) {
        final isSelected = filterState.selectedDifficulties.contains(
          difficulty.level,
        );

        return FilterChip(
          label: Text(difficulty.label),
          selected: isSelected,
          selectedColor: difficulty.color.withValues(alpha: 0.3),
          checkmarkColor: difficulty.color,
          labelStyle: TextStyle(
            color: isSelected ? difficulty.color : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? difficulty.color : Colors.grey.shade300,
          ),
          onSelected: (_) {
            ref
                .read(puzzleFilterProvider.notifier)
                .toggleDifficulty(difficulty.level);
          },
        );
      }).toList(),
    );
  }
}
