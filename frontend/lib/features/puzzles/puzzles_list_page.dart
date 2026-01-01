import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/puzzle_filter_provider.dart';
import 'package:croiz/features/puzzles/filtered_puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/difficulty_filter_chips.dart';
import 'package:croiz/features/puzzles/widgets/language_filter_selector.dart';
import 'package:croiz/features/puzzles/widgets/continue_playing_section.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_list_tile_enhanced.dart';
import 'package:croiz/features/puzzles/widgets/generated_filter_chip.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_search_bar.dart';
import 'package:croiz/core/responsive/responsive.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';

/// Puzzle selection page with filters, continue playing section, and performance.
class PuzzlesListPage extends ConsumerWidget {
  const PuzzlesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final puzzlesAsync = ref.watch(puzzlesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('settings_icon'),
          icon: const Icon(Icons.settings),
          onPressed: () => _openSettings(context),
        ),
        title: Text(
          AppLocalizations.of(context)?.puzzles ?? 'Puzzles',
          style: TextStyle(fontSize: ResponsiveFontSize.titleMedium),
        ),
        actions: [
          // Show puzzle count
          puzzlesAsync.whenOrNull(
                data: (puzzles) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      '${puzzles.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      backgroundColor: isLight
          ? Colors.white
          : Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(context, ref, puzzlesAsync),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Stack(
        children: [
          CrosswordControlsMenu(onClose: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<PuzzleDescriptor>> puzzlesAsync,
  ) => puzzlesAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, st) => Center(
      child: Text(
        AppLocalizations.of(context)?.errorLoading ?? 'Error loading puzzles',
      ),
    ),
    data: (allPuzzles) => _buildContent(context, ref, allPuzzles),
  );

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<PuzzleDescriptor> allPuzzles,
  ) {
    final filteredPuzzles = ref.watch(filteredPuzzlesProvider);

    return Column(
      children: [
        // Continue Playing Section at top
        const ContinuePlayingSection(),

        // Search Bar
        const PuzzleSearchBar(),

        // Filter chips section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DifficultyFilterChips(),
              SizedBox(height: 8),
              Row(
                children: [
                  LanguageFilterSelector(),
                  SizedBox(width: 8),
                  GeneratedFilterChip(),
                ],
              ),
            ],
          ),
        ),

        // Divider
        const Divider(height: 1),

        // Filtered puzzle count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${filteredPuzzles.length} puzzles',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (filteredPuzzles.length < allPuzzles.length)
                TextButton(
                  onPressed: () => _clearFilters(ref),
                  child: const Text('Clear filters'),
                ),
            ],
          ),
        ),

        // Puzzle list with performance optimizations
        Expanded(
          child: ListView.builder(
            // Fixed height for O(1) scroll calculation
            itemExtent: 72,
            // Pre-render for smooth scrolling
            cacheExtent: 500,
            itemCount: filteredPuzzles.length,
            itemBuilder: (context, index) {
              final puzzle = filteredPuzzles[index];
              return PuzzleListTileEnhanced(descriptor: puzzle);
            },
          ),
        ),
      ],
    );
  }

  void _clearFilters(WidgetRef ref) {
    ref.read(puzzleFilterProvider.notifier).clearFilters();
  }
}
