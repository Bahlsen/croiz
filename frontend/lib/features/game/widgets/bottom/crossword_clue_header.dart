import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/helpers/entry_lookup.dart';
import 'package:croiz/features/game/helpers/word_navigation.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_arrow.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_actions_row.dart';
import 'package:croiz/core/responsive/responsive.dart';

/// Header showing the clue for the currently selected word.
class CrosswordClueHeader extends ConsumerWidget {
  const CrosswordClueHeader({
    super.key,
    this.onMenu,
    this.onClear,
    this.onReveal,
  });

  final VoidCallback? onMenu;
  final VoidCallback? onClear;
  final VoidCallback? onReveal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCellProvider);
    final dir = ref.watch(wordDirectionProvider);

    // Build the main content of the header. Always render the left/right
    // action slots (menu / clear) when callbacks are provided so tests
    // relying on keys like 'menu_button' and 'clear_button' remain valid.
    Widget centerWidget;
    ClueBannerArrow? leftArrow;
    ClueBannerArrow? rightArrow;

    if (selected == null) {
      centerWidget = Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsivePadding.lg,
          vertical: ResponsivePadding.lg,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveBorderRadius.lg),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((0.12 * 255).round()),
            width: 1,
          ),
        ),
        child: Text(
          AppLocalizations.of(context)?.selectAWord ?? 'Select a word',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveFontSize.bodyMedium,
          ),
        ),
      );
    } else {
      final board = ref.watch(gameBoardProvider);
      final entryCtx = computeCurrentEntry(board, selected, dir);
      if (entryCtx == null) {
        centerWidget = const SizedBox.shrink();
      } else {
        centerWidget = ClueBannerContainer(entry: entryCtx.entry);
        leftArrow = ClueBannerArrow(
          icon: Icons.chevron_left,
          onTap:
              () => _navigateToAdjacentEntry(
                ref,
                entryCtx.entries,
                entryCtx.entry,
                -1,
              ),
        );
        rightArrow = ClueBannerArrow(
          icon: Icons.chevron_right,
          onTap:
              () => _navigateToAdjacentEntry(
                ref,
                entryCtx.entries,
                entryCtx.entry,
                1,
              ),
        );
      }
    }

    // Build row with arrows and center widget (no Stack)
    final mainRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leftArrow != null)
          leftArrow
        else
          const SizedBox(width: ClueBannerArrow.fixedWidth),
        SizedBox(width: ResponsivePadding.sm),
        Expanded(child: centerWidget),
        SizedBox(width: ResponsivePadding.sm),
        if (rightArrow != null)
          rightArrow
        else
          const SizedBox(width: ClueBannerArrow.fixedWidth),
      ],
    );

    // ACTIONS: Get the puzzle title if available to display in the header
    final puzzleAsync = ref.watch(puzzleLoaderProvider);
    final title = puzzleAsync.value?.title;

    // Actions row placed below the main clue bar
    final actionsRow = CrosswordClueActionsRow(
      onMenu: onMenu,
      onReveal: onReveal,
      onClear: onClear,
      title: title,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsivePadding.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [mainRow, SizedBox(height: ResponsiveSpacing.xs), actionsRow],
      ),
    );
  }

  void _navigateToAdjacentEntry(
    WidgetRef ref,
    List<PuzzleEntryData> entries,
    PuzzleEntryData current,
    int delta,
  ) {
    if (entries.isEmpty) {
      return;
    }
    final next = computeAdjacentEntry(entries, current, delta);
    final newDir =
        next.direction == 'across'
            ? WordDirection.horizontal
            : WordDirection.vertical;
    ref.read(wordDirectionProvider.notifier).setDirection(newDir);
    ref
        .read(selectedCellProvider.notifier)
        .select(SelectedCell(next.y, next.x));
  }
}
