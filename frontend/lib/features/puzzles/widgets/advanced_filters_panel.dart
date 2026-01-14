import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_difficulty.dart';
import '../../../core/config/feature_flags.dart';
import '../../../core/responsive/responsive.dart';
import '../filtered_puzzles_provider.dart';
import '../puzzle_filter_provider.dart';
import 'language_filter_selector.dart';
import 'puzzle_search_bar.dart';

/// Collapsible panel containing advanced puzzle filters.
///
/// Includes: search bar, language selector, completed toggle,
/// generated toggle, and Expert/Pro difficulty chips.
class AdvancedFiltersPanel extends ConsumerWidget {
  const AdvancedFiltersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filterState = ref.watch(puzzleFilterProvider);
    final availableDifficulties =
        ref.watch(availableDifficultiesProvider).toList()..sort();

    // Expert (4) and Pro (5) difficulties - shown only if available
    final advancedDifficulties =
        AppDifficulty.levels
            .where(
              (d) =>
                  (d.level == 4 || d.level == 5) &&
                  availableDifficulties.contains(d.level),
            )
            .toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          const PuzzleSearchBar(),
          SizedBox(height: 1.h),

          // Row with language + toggles
          Row(
            children: [
              // Language selector
              const LanguageFilterSelector(),
              const Spacer(),

              // Completed toggle
              _ToggleChip(
                label: 'Completed',
                isSelected: filterState.showCompleted,
                onTap: () {
                  ref.read(puzzleFilterProvider.notifier).toggleShowCompleted();
                },
              ),

              // Generated toggle (if feature enabled)
              if (FeatureFlags.isGenerationEnabled) ...[
                const SizedBox(width: 8),
                _ToggleChip(
                  label: 'Generated',
                  isSelected: filterState.showGeneratedOnly,
                  onTap: () {
                    ref
                        .read(puzzleFilterProvider.notifier)
                        .toggleShowGeneratedOnly();
                  },
                ),
              ],
            ],
          ),

          // Expert/Pro chips (if available)
          if (advancedDifficulties.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Wrap(
              spacing: 8,
              children:
                  advancedDifficulties.map((difficulty) {
                    final isSelected = filterState.selectedDifficulties
                        .contains(difficulty.level);
                    return FilterChip(
                      label: Text(difficulty.label),
                      selected: isSelected,
                      selectedColor: difficulty.color.withValues(alpha: 0.2),
                      checkmarkColor: difficulty.color,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      labelStyle: TextStyle(
                        color: isSelected ? difficulty.color : null,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color:
                            isSelected
                                ? difficulty.color
                                : Colors.grey.shade300,
                        width: 1,
                      ),
                      onSelected: (_) {
                        // Add/remove from current selection
                        final current = Set<int>.from(
                          filterState.selectedDifficulties,
                        );
                        if (current.contains(difficulty.level)) {
                          current.remove(difficulty.level);
                        } else {
                          current.add(difficulty.level);
                        }
                        ref
                            .read(puzzleFilterProvider.notifier)
                            .setDifficulties(current);
                      },
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small toggle chip for boolean filters.
class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
