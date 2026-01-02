import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import '../puzzle_filter_provider.dart';

/// A filter chip to toggle showing completed puzzles.
class CompletedFilterChip extends ConsumerWidget {
  const CompletedFilterChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(puzzleFilterProvider);
    final isSelected = filterState.showCompleted;

    return FilterChip(
      avatar: const Icon(Icons.check_circle_outline, size: 18),
      label: Text(AppLocalizations.of(context)?.completedFilter ?? 'Completed'),
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.secondaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
      labelStyle: TextStyle(
        color:
            isSelected
                ? Theme.of(context).colorScheme.onSecondaryContainer
                : null,
      ),
      side:
          isSelected
              ? BorderSide.none
              : BorderSide(color: Theme.of(context).colorScheme.outline),
      onSelected: (_) {
        ref.read(puzzleFilterProvider.notifier).toggleShowCompleted();
      },
    );
  }
}
