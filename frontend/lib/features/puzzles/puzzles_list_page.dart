import 'package:flutter/material.dart';

import 'package:croiz/features/puzzles/widgets/empty_puzzles_state.dart';
import 'package:croiz/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/pending_puzzles_provider.dart';
import 'package:croiz/features/puzzles/puzzle_filter_provider.dart';
import 'package:croiz/features/puzzles/filtered_puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/continue_playing_section.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_card.dart';
import 'package:croiz/features/puzzles/widgets/quick_difficulty_selector.dart';
import 'package:croiz/features/puzzles/widgets/advanced_filters_panel.dart';
import 'package:croiz/features/puzzles/widgets/random_puzzle_grid.dart';
import 'package:croiz/features/puzzles/widgets/shuffle_and_see_all_row.dart';
import 'package:croiz/core/responsive/responsive.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';
import 'package:croiz/features/generation/widgets/generation_dialog.dart';
import 'package:croiz/features/generation/logic/generation_controller.dart';
import 'package:croiz/core/exceptions/user_friendly_exception.dart';
import 'package:croiz/core/config/feature_flags.dart';

/// Puzzle selection page with Quick Play mode and expandable filters.
class PuzzlesListPage extends ConsumerStatefulWidget {
  const PuzzlesListPage({super.key});

  @override
  ConsumerState<PuzzlesListPage> createState() => _PuzzlesListPageState();
}

class _PuzzlesListPageState extends ConsumerState<PuzzlesListPage> {
  /// Whether the advanced filters panel is expanded.
  bool _showAdvancedFilters = false;

  /// Whether to show the full puzzle list instead of Quick Play grid.
  bool _showFullList = false;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final puzzlesAsync = ref.watch(puzzlesProvider);

    // Listen to background generation status (if enabled)
    if (FeatureFlags.isGenerationEnabled) {
      ref.listen(generationControllerProvider, (previous, next) {
        next.when(
          data: (puzzleId) {
            if (puzzleId != null && context.mounted) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                    content: Text(
                      AppLocalizations.of(context)?.successMessage ??
                          'Puzzle generated successfully!',
                    ),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)?.playButton ?? 'PLAY',
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        if (context.mounted) {
                          CrosswordRoute(id: puzzleId).push(context);
                        }
                      },
                    ),
                  ),
                );
            }
          },
          error: (e, st) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      e is UserFriendlyException
                          ? e.userMessage
                          : 'Failed to generate puzzle',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
            }
          },
          loading: () {},
        );
      });
    }

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
          // Back to Quick Play if in full list mode
          if (_showFullList)
            IconButton(
              icon: const Icon(Icons.grid_view),
              tooltip: 'Quick Play',
              onPressed: () => setState(() => _showFullList = false),
            ),
        ],
      ),
      backgroundColor:
          isLight ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(context, puzzlesAsync),
      floatingActionButton:
          FeatureFlags.isGenerationEnabled
              ? FloatingActionButton.extended(
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  AppLocalizations.of(context)?.generateButton ?? 'GENERATE',
                ),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => const GenerationDialog(),
                  );
                },
              )
              : null,
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Stack(
            children: [
              CrosswordControlsMenu(onClose: () => Navigator.of(context).pop()),
            ],
          ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<PuzzleDescriptor>> puzzlesAsync,
  ) => puzzlesAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error:
        (e, st) => Center(
          child: Text(
            AppLocalizations.of(context)?.errorLoading ??
                'Error loading puzzles',
          ),
        ),
    data: (allPuzzles) => _buildContent(context, allPuzzles),
  );

  Widget _buildContent(
    BuildContext context,
    List<PuzzleDescriptor> allPuzzles,
  ) {
    final filteredPuzzles = ref.watch(filteredPuzzlesProvider);
    final completedIdsAsync = ref.watch(completedPuzzleIdsProvider);
    final completedIds = completedIdsAsync.whenOrNull(data: (ids) => ids) ?? {};

    final hasPuzzles = allPuzzles.isNotEmpty;
    final hasResults = filteredPuzzles.isNotEmpty;

    // Full list mode
    if (_showFullList) {
      return _buildFullList(
        context,
        filteredPuzzles,
        completedIds,
        hasPuzzles,
        hasResults,
      );
    }

    // Quick Play mode (default)
    return _buildQuickPlayMode(context, filteredPuzzles, hasPuzzles);
  }

  /// Builds the Quick Play mode UI with 4 random puzzles.
  Widget _buildQuickPlayMode(
    BuildContext context,
    List<PuzzleDescriptor> filteredPuzzles,
    bool hasPuzzles,
  ) => CustomScrollView(
    slivers: [
      // Continue Playing Section
      const SliverToBoxAdapter(child: ContinuePlayingSection()),

      // Quick Difficulty Selector
      if (hasPuzzles)
        SliverToBoxAdapter(
          child: QuickDifficultySelector(
            isExpanded: _showAdvancedFilters,
            onExpandToggle:
                () => setState(
                  () => _showAdvancedFilters = !_showAdvancedFilters,
                ),
          ),
        ),

      // Advanced Filters Panel (collapsible)
      if (hasPuzzles && _showAdvancedFilters)
        const SliverToBoxAdapter(child: AdvancedFiltersPanel()),

      // Random Puzzle Grid
      if (hasPuzzles) const SliverToBoxAdapter(child: RandomPuzzleGrid()),

      // Shuffle + See All Row
      if (hasPuzzles)
        SliverToBoxAdapter(
          child: ShuffleAndSeeAllRow(
            totalCount: filteredPuzzles.length,
            onSeeAll: () => setState(() => _showFullList = true),
          ),
        ),

      // Empty state if no puzzles at all
      if (!hasPuzzles)
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyPuzzlesState(
            isNoResults: false,
            onClearFilters: _clearFilters,
          ),
        ),
    ],
  );

  /// Builds the full list mode UI with all filtered puzzles.
  Widget _buildFullList(
    BuildContext context,
    List<PuzzleDescriptor> filteredPuzzles,
    Set<String> completedIds,
    bool hasPuzzles,
    bool hasResults,
  ) => CustomScrollView(
    slivers: [
      // Continue Playing Section
      const SliverToBoxAdapter(child: ContinuePlayingSection()),

      // Advanced Filters Panel (always shown in full list mode)
      const SliverToBoxAdapter(child: AdvancedFiltersPanel()),

      // Results count
      if (hasResults)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredPuzzles.length} ${AppLocalizations.of(context)?.puzzles ?? 'puzzles'}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_list_off, size: 14),
                  label: Text(
                    AppLocalizations.of(context)?.clearFilters ??
                        'Clear filters',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),

      // Divider
      if (hasResults) const SliverToBoxAdapter(child: Divider(height: 1)),

      // Full puzzle list
      if (hasResults)
        SliverList.builder(
          itemCount: filteredPuzzles.length,
          itemBuilder: (context, index) {
            final puzzle = filteredPuzzles[index];
            final isCompleted = completedIds.contains(puzzle.id);
            final isPending = ref
                .watch(pendingPuzzlesProvider)
                .any((p) => p.tempId == puzzle.id);
            return PuzzleCard(
              descriptor: puzzle,
              isCompleted: isCompleted,
              isPending: isPending,
            );
          },
        )
      else
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyPuzzlesState(
            isNoResults: hasPuzzles,
            onClearFilters: _clearFilters,
          ),
        ),
    ],
  );

  void _clearFilters() {
    ref.read(puzzleFilterProvider.notifier).clearFilters();
  }
}
