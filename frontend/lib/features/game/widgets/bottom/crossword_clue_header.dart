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

    // Build the main content of the header depending on selection.
    Widget mainContent;
    if (selected == null) {
      mainContent = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context)
                .colorScheme
                .onSurface
                .withAlpha((0.12 * 255).round()),
              width: 1),
        ),
        child: Text(
          'Select a word',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600),
        ),
      );
    } else {
      final board = ref.watch(gameBoardProvider);
      final entryCtx = computeCurrentEntry(board, selected, dir);
      if (entryCtx == null) {
        mainContent = const SizedBox.shrink();
      } else {
        final entry = entryCtx.entry;
        // Arrange as three vertical columns: left (arrow + optional menu),
        // center (banner), right (arrow + optional clear). This makes the
        // arrows appear higher and the icons sit directly under each arrow
        // and alongside the banner.
        mainContent = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClueBannerArrow(
                  icon: Icons.chevron_left,
                  onTap: () =>
                      _navigateToAdjacentEntry(ref, entryCtx.entries, entry, -1),
                ),
                const SizedBox(height: 8),
                if (onMenu != null)
                  SizedBox(
                    width: 56,
                    height: 40,
                    child: Center(child: ClueHeaderMenuButton(onPressed: onMenu)),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(child: ClueBannerContainer(entry: entry)),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClueBannerArrow(
                  icon: Icons.chevron_right,
                  onTap: () =>
                      _navigateToAdjacentEntry(ref, entryCtx.entries, entry, 1),
                ),
                const SizedBox(height: 8),
                if (onClear != null)
                  SizedBox(
                    width: 56,
                    height: 40,
                    child:
                        Center(child: ClueHeaderClearButton(onPressed: onClear)),
                  ),
              ],
            ),
          ],
        );
      }
    }

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
