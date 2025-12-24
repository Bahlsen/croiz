import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/helpers/entry_lookup.dart';
import 'package:croiz/features/game/helpers/word_navigation.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_arrow.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';

/// Compact banner showing the clue for the currently selected word.
class CrosswordClueBanner extends ConsumerWidget {
  const CrosswordClueBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCellProvider);
    final dir = ref.watch(wordDirectionProvider);

    final isCompact = MediaQuery.of(context).size.height < 72;
    final bannerHeight = isCompact ? 56.0 : 88.0;

    if (selected == null) {
      return Container(
        height: bannerHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!, width: 1),
        ),
        child: const Text('Select a word',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      );
    }

    final board = ref.watch(gameBoardProvider);
    final entryCtx = computeCurrentEntry(board, selected, dir);
    if (entryCtx == null) {
      return const SizedBox.shrink();
    }

    final entry = entryCtx.entry;

    return SizedBox(
      height: bannerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            ClueBannerArrow(
              icon: Icons.chevron_left,
              onTap: () => _navigateToAdjacentEntry(ref, entryCtx.entries, entry, -1),
              compact: isCompact,
            ),
            Expanded(
              child: ClueBannerContainer(entry: entry, compact: isCompact),
            ),
            ClueBannerArrow(
              icon: Icons.chevron_right,
              onTap: () => _navigateToAdjacentEntry(ref, entryCtx.entries, entry, 1),
              compact: isCompact,
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
    final newDir = next.direction == 'across' ? WordDirection.horizontal : WordDirection.vertical;
    ref.read(wordDirectionProvider.notifier).value = newDir;
    ref.read(selectedCellProvider.notifier).value = SelectedCell(next.y, next.x);
  }
}
