import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../puzzles_provider.dart';
import '../puzzle_filter_provider.dart';

/// Search bar for puzzles with autocomplete suggestions.
class PuzzleSearchBar extends ConsumerWidget {
  const PuzzleSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzlesAsync = ref.watch(puzzlesProvider);

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }

          return puzzlesAsync.when(
            data: (puzzles) {
              final query = textEditingValue.text.toLowerCase();
              return puzzles
                  .map((p) => p.title)
                  .toSet()
                  .where((title) => title.toLowerCase().contains(query));
            },
            loading: () => const Iterable<String>.empty(),
            error: (error, stack) => const Iterable<String>.empty(),
          );
        },
        onSelected: (String selection) {
          ref.read(puzzleFilterProvider.notifier).setSearchQuery(selection);
        },
        fieldViewBuilder:
            (context, controller, focusNode, onFieldSubmitted) => TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search puzzles...',
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                suffixIcon:
                    controller.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            controller.clear();
                            ref
                                .read(puzzleFilterProvider.notifier)
                                .setSearchQuery('');
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                ref.read(puzzleFilterProvider.notifier).setSearchQuery(value);
              },
            ),
      ),
    );
  }
}
