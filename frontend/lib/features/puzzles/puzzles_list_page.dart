import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/puzzle_filter_provider.dart';
import 'package:croiz/features/puzzles/filtered_puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/continue_playing_section.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_card.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_search_bar.dart';
import 'package:croiz/features/puzzles/widgets/puzzles_filter_row.dart';
import 'package:croiz/core/responsive/responsive.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';
import 'package:croiz/features/generation/widgets/generation_dialog.dart';

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
                data:
                    (puzzles) => Padding(
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
      backgroundColor:
          isLight ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(context, ref, puzzlesAsync),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.auto_awesome),
        label: Text(AppLocalizations.of(context)?.generateButton ?? 'GENERATE'),
        onPressed: () async {
          final puzzleId = await showDialog<String>(
            context: context,
            builder: (context) => const GenerationDialog(),
          );

          if (puzzleId != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)?.successMessage ??
                      'Puzzle generated successfully!',
                ),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)?.playButton ?? 'PLAY',
                  onPressed: () {
                    // Navigate to game
                    // Use go_router which should be available here
                    GoRouter.of(context).push('/game/$puzzleId');
                  },
                ),
              ),
            );
          }
        },
      ),
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
    WidgetRef ref,
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
    data: (allPuzzles) => _buildContent(context, ref, allPuzzles),
  );

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<PuzzleDescriptor> allPuzzles,
  ) {
    final filteredPuzzles = ref.watch(filteredPuzzlesProvider);
    final completedIdsAsync = ref.watch(completedPuzzleIdsProvider);
    final completedIds = completedIdsAsync.whenOrNull(data: (ids) => ids) ?? {};

    return CustomScrollView(
      slivers: [
        // Continue Playing Section (Top sticky engagement)
        const SliverToBoxAdapter(child: ContinuePlayingSection()),

        // Discovery Area: Search + Filters
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PuzzleSearchBar(),
              const PuzzlesFilterRow(),

              // Filtered count row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
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
                    if (filteredPuzzles.length < allPuzzles.length)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () => _clearFilters(ref),
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
            ],
          ),
        ),

        // Divider
        const SliverToBoxAdapter(child: Divider(height: 1)),

        // Puzzle list with performance optimizations
        SliverList.builder(
          itemCount: filteredPuzzles.length,
          itemBuilder: (context, index) {
            final puzzle = filteredPuzzles[index];
            final isCompleted = completedIds.contains(puzzle.id);
            return PuzzleCard(descriptor: puzzle, isCompleted: isCompleted);
          },
        ),
      ],
    );
  }

  void _clearFilters(WidgetRef ref) {
    ref.read(puzzleFilterProvider.notifier).clearFilters();
  }
}
