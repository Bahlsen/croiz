import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/helpers/entry_lookup.dart';
import 'package:croiz/features/game/helpers/word_navigation.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_arrow.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_actions.dart';

/// Compact header showing the clue for the currently selected word.
class CrosswordClueHeader extends ConsumerWidget {
  const CrosswordClueHeader({super.key, this.onMenu, this.onClear});

  final VoidCallback? onMenu;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCellProvider);
    final dir = ref.watch(wordDirectionProvider);

    final isCompact = MediaQuery.of(context).size.height < 72;
    final bannerHeight = isCompact ? 56.0 : 88.0;

    // Build the main content of the header depending on selection.
    Widget mainContent;
    if (selected == null) {
      mainContent = Container(
        height: bannerHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!, width: 1),
        ),
        child: const Text(
          'Select a word',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    } else {
      final board = ref.watch(gameBoardProvider);
      final entryCtx = computeCurrentEntry(board, selected, dir);
      if (entryCtx == null) {
        mainContent = const SizedBox.shrink();
      } else {
        final entry = entryCtx.entry;
        mainContent = Row(
          children: [
            ClueBannerArrow(
              icon: Icons.chevron_left,
              onTap: () =>
                  _navigateToAdjacentEntry(ref, entryCtx.entries, entry, -1),
              compact: isCompact,
            ),
            Expanded(
              child: ClueBannerContainer(entry: entry, compact: isCompact),
            ),
            ClueBannerArrow(
              icon: Icons.chevron_right,
              onTap: () =>
                  _navigateToAdjacentEntry(ref, entryCtx.entries, entry, 1),
              compact: isCompact,
            ),
          ],
        );
      }
    }

    return SizedBox(
      height: bannerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Stack(
          children: [
            mainContent,
            // Menu icon: bottom-left (aligned under left arrow)
            if (onMenu != null)
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isCompact ? 4 : 6,
                    bottom: isCompact ? 4 : 6,
                  ),
                  child: ClueHeaderMenuButton(
                    onPressed: onMenu,
                    isCompact: isCompact,
                  ),
                ),
              ),
            // Clear icon: bottom-right (aligned under right arrow)
            if (onClear != null)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isCompact ? 4 : 6,
                    bottom: isCompact ? 4 : 6,
                  ),
                  child: ClueHeaderClearButton(
                    onPressed: onClear,
                    isCompact: isCompact,
                  ),
                ),
              ),
          ],
        ),
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
