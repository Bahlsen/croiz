import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../puzzle_filter_provider.dart';

/// A filter chip to toggle showing only generated puzzles.
class GeneratedFilterChip extends ConsumerWidget {
  const GeneratedFilterChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(puzzleFilterProvider);
    final isSelected = filterState.showGeneratedOnly;

    return FilterChip(
      avatar: const Icon(Icons.auto_awesome, size: 18),
      label: const Text('Generated'),
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.tertiaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.tertiary,
      labelStyle: TextStyle(
        color:
            isSelected
                ? Theme.of(context).colorScheme.onTertiaryContainer
                : null, // Default
      ),
      side:
          isSelected
              ? BorderSide.none
              : BorderSide(color: Theme.of(context).colorScheme.outline),
      onSelected: (selected) {
        ref
            .read(puzzleFilterProvider.notifier)
            .setShowGeneratedOnly(showGeneratedOnly: selected);
      },
    );
  }
}
