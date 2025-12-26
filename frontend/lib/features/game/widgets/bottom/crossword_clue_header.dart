import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/helpers/entry_lookup.dart';
import 'package:croiz/features/game/helpers/word_navigation.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_arrow.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_actions.dart';

/// Header showing the clue for the currently selected word.
class CrosswordClueHeader extends ConsumerWidget {
  const CrosswordClueHeader({super.key, this.onMenu, this.onClear});

  final VoidCallback? onMenu;
  final VoidCallback? onClear;

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((0.12 * 255).round()),
            width: 1,
          ),
        ),
        child: Text(
          'Select a word',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
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
          onTap: () => _navigateToAdjacentEntry(
            ref,
            entryCtx.entries,
            entryCtx.entry,
            -1,
          ),
        );
        rightArrow = ClueBannerArrow(
          icon: Icons.chevron_right,
          onTap: () => _navigateToAdjacentEntry(
            ref,
            entryCtx.entries,
            entryCtx.entry,
            1,
          ),
        );
      }
    }

    final leftColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leftArrow != null) leftArrow,
        const SizedBox(height: 8),
        if (onMenu != null)
          SizedBox(
            width: 56,
            height: 40,
            child: Center(child: ClueHeaderMenuButton(onPressed: onMenu)),
          ),
      ],
    );

    final rightColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rightArrow != null) rightArrow,
        const SizedBox(height: 8),
        if (onClear != null)
          SizedBox(
            width: 56,
            height: 40,
            child: Center(child: ClueHeaderClearButton(onPressed: onClear)),
          ),
      ],
    );

    final mainContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leftColumn,
        const SizedBox(width: 8),
        Expanded(child: centerWidget),
        const SizedBox(width: 8),
        rightColumn,
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: mainContent,
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
    final newDir = next.direction == 'across'
        ? WordDirection.horizontal
        : WordDirection.vertical;
    ref.read(wordDirectionProvider.notifier).value = newDir;
    ref.read(selectedCellProvider.notifier).value = SelectedCell(
      next.y,
      next.x,
    );
  }
}
