import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../puzzles_provider.dart';
import '../puzzle_filter_provider.dart';

/// Search bar for puzzles with autocomplete suggestions.
class PuzzleSearchBar extends ConsumerStatefulWidget {
  const PuzzleSearchBar({super.key});

  @override
  ConsumerState<PuzzleSearchBar> createState() => _PuzzleSearchBarState();
}

class _PuzzleSearchBarState extends ConsumerState<PuzzleSearchBar> {
  late final TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync controller with provider state on rebuild
    // If controller is empty but provider has a query, clear the provider
    final currentQuery = ref.read(puzzleFilterProvider).searchQuery;
    if (_controller.text.isEmpty && currentQuery.isNotEmpty) {
      // Reset the search query when returning to the page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(puzzleFilterProvider.notifier).setSearchQuery('');
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puzzlesAsync = ref.watch(puzzlesProvider);

    return Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  _isFocused
                      ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5)
                      : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
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
                (context, controller, focusNode, onFieldSubmitted) =>
                // Use our managed controller instead of the one provided by Autocomplete
                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() => _isFocused = hasFocus);
                  },
                  child: TextField(
                    controller: _controller,
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
                        color:
                            _isFocused
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      suffixIcon:
                          _controller.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _controller.clear();
                                  ref
                                      .read(puzzleFilterProvider.notifier)
                                      .setSearchQuery('');
                                  // Rebuild to hide the clear button
                                  setState(() {});
                                },
                              )
                              : null,
                    ),
                    onChanged: (value) {
                      ref
                          .read(puzzleFilterProvider.notifier)
                          .setSearchQuery(value);
                      // Rebuild to show/hide the clear button
                      setState(() {});
                    },
                  ),
                ),
          ),
        )
        .animate(target: _isFocused ? 1 : 0)
        .elevation(end: 4, borderRadius: BorderRadius.circular(22))
        .scale(end: const Offset(1.02, 1.02), duration: 200.ms);
  }
}
