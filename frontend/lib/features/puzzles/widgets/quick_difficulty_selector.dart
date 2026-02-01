import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_difficulty.dart';
import '../../../core/responsive/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../puzzle_filter_provider.dart';

/// A compact difficulty selector with Easy/Medium/Hard buttons and expand toggle.
///
/// Used in Quick Play mode for single-difficulty selection.
class QuickDifficultySelector extends ConsumerWidget {
  const QuickDifficultySelector({
    required this.onExpandToggle,
    required this.isExpanded,
    super.key,
  });

  /// Callback when the expand/collapse button is tapped.
  final VoidCallback onExpandToggle;

  /// Whether the advanced filters panel is currently expanded.
  final bool isExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final filterState = ref.watch(puzzleFilterProvider);

    // Get currently selected difficulty (first one if multiple)
    final selectedDifficulty =
        filterState.selectedDifficulties.isNotEmpty
            ? filterState.selectedDifficulties.first
            : 2;

    // Quick Play difficulties: Easy (1), Medium (2), Hard (3)
    final quickDifficulties = [
      AppDifficulty.levels[0], // Easy
      AppDifficulty.levels[1], // Medium
      AppDifficulty.levels[2], // Hard
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          // Segmented button for difficulty selection
          Expanded(
            child: SegmentedButton<int>(
              segments:
                  quickDifficulties
                      .map(
                        (d) => ButtonSegment<int>(
                          value: d.level,
                          label: Text(
                            _getDifficultyLabel(d.level, l10n),
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      )
                      .toList(),
              selected: {selectedDifficulty},
              onSelectionChanged: (Set<int> selection) {
                if (selection.isNotEmpty) {
                  ref
                      .read(puzzleFilterProvider.notifier)
                      .setDifficulty(selection.first);
                }
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Expand/collapse toggle for advanced filters
          IconButton(
            icon: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.tune,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            onPressed: onExpandToggle,
            tooltip: isExpanded ? 'Hide filters' : 'Show filters',
            style: IconButton.styleFrom(
              backgroundColor:
                  isExpanded
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyLabel(int level, AppLocalizations? l10n) {
    switch (level) {
      case 1:
        return l10n?.easy ?? 'Easy';
      case 2:
        return l10n?.medium ?? 'Medium';
      case 3:
        return l10n?.hard ?? 'Hard';
      default:
        return 'Unknown';
    }
  }
}
