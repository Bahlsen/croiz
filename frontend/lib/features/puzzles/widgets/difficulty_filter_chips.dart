import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/core/config/app_difficulty.dart';
import '../puzzle_filter_provider.dart';
import '../filtered_puzzles_provider.dart';

/// A row of filter chips for selecting puzzle difficulties.
class DifficultyFilterChips extends ConsumerWidget {
  const DifficultyFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(puzzleFilterProvider);

    // Use the derived provider for available difficulties
    final availableDifficulties =
        ref.watch(availableDifficultiesProvider).toList()..sort();

    // Filter difficulties to only those that exist in the puzzles
    final visibleDifficulties = AppDifficulty.levels
        .where((d) => availableDifficulties.contains(d.level))
        .toList();

    // Don't render if there's only one (or zero) difficulty available
    if (visibleDifficulties.length <= 1) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: visibleDifficulties.map((difficulty) {
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
