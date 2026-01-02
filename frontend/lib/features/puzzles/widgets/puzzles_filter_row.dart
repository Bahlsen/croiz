import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/core/config/app_difficulty.dart';
import '../puzzle_filter_provider.dart';
import '../filtered_puzzles_provider.dart';
import 'generated_filter_chip.dart';
import 'completed_filter_chip.dart';
import 'language_filter_selector.dart';

/// A horizontal scrollable row of all puzzle filters.
class PuzzlesFilterRow extends ConsumerWidget {
  const PuzzlesFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(puzzleFilterProvider);
    final availableDifficulties =
        ref.watch(availableDifficultiesProvider).toList()..sort();

    final visibleDifficulties =
        AppDifficulty.levels
            .where((d) => availableDifficulties.contains(d.level))
            .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Language Selector
          const LanguageFilterSelector(),
          const SizedBox(width: 8),

          // Difficulty Chips
          ...visibleDifficulties.map((difficulty) {
            final isSelected = filterState.selectedDifficulties.contains(
              difficulty.level,
            );
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(difficulty.label),
                selected: isSelected,
                selectedColor: difficulty.color.withValues(alpha: 0.2),
                checkmarkColor: difficulty.color,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                labelStyle: TextStyle(
                  color: isSelected ? difficulty.color : null,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? difficulty.color : Colors.grey.shade300,
                  width: 1,
                ),
                onSelected: (_) {
                  ref
                      .read(puzzleFilterProvider.notifier)
                      .toggleDifficulty(difficulty.level);
                },
              ),
            );
          }),

          // Completed Chip
          const CompletedFilterChip(),
          const SizedBox(width: 8),

          // Generated Chip
          const GeneratedFilterChip(),
        ],
      ),
    );
  }
}
