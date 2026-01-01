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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  .toSet() // Deduplicate titles
                  .where((title) => title.toLowerCase().contains(query));
            },
            loading: () => const Iterable<String>.empty(),
            error: (error, stack) => const Iterable<String>.empty(),
          );
        },
        onSelected: (String selection) {
          ref.read(puzzleFilterProvider.notifier).setSearchQuery(selection);
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) =>
            TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Search puzzles...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
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
