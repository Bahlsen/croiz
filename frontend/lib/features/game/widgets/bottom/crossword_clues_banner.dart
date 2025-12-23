import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/features/game/helpers/entry_lookup.dart';
import 'package:croiz/features/game/helpers/word_navigation.dart';

/// Compute current entry without full GameBoard dependency.
/// This allows watching only entries+blackCells (stable) instead of grid.
EntryContext? _computeCurrentEntryFromParts({
  required List<PuzzleEntryData> entries,
  required List<List<bool>> blackCells,
  required SelectedCell selected,
  required WordDirection dir,
}) {
  final horizontal = dir == WordDirection.horizontal;
  final bounds = blackCells.wordBounds(
    selected.row,
    selected.col,
    horizontal: horizontal,
  );
  final startX = horizontal ? bounds[0] : selected.col;
  final startY = horizontal ? selected.row : bounds[0];

  final dirStr = horizontal ? 'across' : 'down';
  final entry = entries.firstWhere(
    (e) => e.x == startX && e.y == startY && e.direction == dirStr,
    orElse: () => const PuzzleEntryData(
      number: -1,
      direction: 'across',
      x: -1,
      y: -1,
      length: 0,
      clue: null,
    ),
  );
  if (entry.number == -1) {
    return null;
  }

  return EntryContext(horizontal: horizontal, entry: entry, entries: entries);
}

/// Compact banner showing the clue for the currently selected word.
class CrosswordClueBanner extends ConsumerWidget {
  const CrosswordClueBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCellProvider);
    // If nothing selected, render the stable placeholder immediately.
    final dir = ref.watch(wordDirectionProvider);

    // Determine available vertical space to decide compact mode.
    final availableHeight = MediaQuery.of(context).size.height;
    final isCompact = availableHeight < 72;

    if (selected == null) {
      // When there's no selection (tests / early startup), render a
      // small placeholder banner so the layout remains stable and
      // measurable. This prevents zero-height banners in tests.
      return Container(
        // Increase placeholder height to match larger fixed clue banner
        height: isCompact ? 88 : 160,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
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
    }

    // Performance: watch only entries and blackCells, not the entire board.
    // The grid changes on every keystroke but entries/blackCells are stable.
    final entries = ref.watch(gameBoardProvider.select((b) => b.entries));
    final blackCells = ref.watch(gameBoardProvider.select((b) => b.blackCells));

    if (entries == null || entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final entryCtx = _computeCurrentEntryFromParts(
      entries: entries,
      blackCells: blackCells,
      selected: selected,
      dir: dir,
    );
    if (entryCtx == null) {
      return const SizedBox.shrink();
    }

    final horizontal = entryCtx.horizontal;
    final entry = entryCtx.entry;
    final allEntries = entryCtx.entries;

    // Make the banner a smaller fixed height so it doesn't dominate
    // the controls area. Use much smaller defaults than before.
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(height: isCompact ? 56 : 88),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: isCompact ? 6 : 8,
        ),
        child: Center(
          child: ConstrainedBox(
            // Allow a wider banner so clues can use more horizontal space
            // on larger phones and tablets. Tests that need a small
            // width still work because the ConstrainedBox only applies
            // a maximum width.
            constraints: const BoxConstraints(maxWidth: 820),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNavArrow(
                  icon: Icons.chevron_left,
                  onTap: () =>
                      _navigateToAdjacentEntry(ref, allEntries, entry, -1),
                  compact: isCompact,
                ),
                Expanded(
                  child: _buildClueContainer(
                    ref: ref,
                    horizontal: horizontal,
                    entry: entry,
                    compact: isCompact,
                  ),
                ),
                _buildNavArrow(
                  icon: Icons.chevron_right,
                  onTap: () =>
                      _navigateToAdjacentEntry(ref, allEntries, entry, 1),
                  compact: isCompact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.onTap,
    this.compact = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      // Make arrows visibly larger and more tappable.
      width: compact ? 30 : 36,
      height: compact ? 40 : 46,
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white70, size: compact ? 24 : 28),
    ),
  );
}

Widget _buildNavArrow({
  required IconData icon,
  required VoidCallback onTap,
  bool compact = false,
}) => _NavArrow(icon: icon, onTap: onTap, compact: compact);

// Entry resolution logic moved to helpers/entry_lookup.dart

Widget _buildClueContainer({
  required WidgetRef ref,
  required bool horizontal,
  required PuzzleEntryData entry,
  bool compact = false,
}) => GestureDetector(
  onTap: () {
    final newDir = horizontal
        ? WordDirection.vertical
        : WordDirection.horizontal;
    ref.read(wordDirectionProvider.notifier).value = newDir;
  },
  behavior: HitTestBehavior.opaque,
  child: Container(
    // Reduce outer margins so the clue container can use more of the
    // available width (we borrow a bit of space from the nav arrows).
    margin: EdgeInsets.symmetric(horizontal: compact ? 6 : 8),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(compact ? 10 : 12),
      border: Border.all(color: Colors.grey[700]!, width: 1),
    ),
    // Increase vertical padding to make the banner feel taller
    padding: EdgeInsets.symmetric(
      vertical: compact ? 16 : 22,
      horizontal: compact ? 12 : 16,
    ),
    child: SizedBox.expand(
      child: Center(
        child: Text(
          entry.clue == null || entry.clue!.isEmpty
              ? '${entry.number}.'
              : '${entry.number}. ${entry.clue!}',
          textAlign: TextAlign.center,
          // Keep text behavior consistent: limit lines and use ellipsis.
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  ),
);

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

  // Update selection and direction to the start of the target word.
  final newDir = next.direction == 'across'
      ? WordDirection.horizontal
      : WordDirection.vertical;
  ref.read(wordDirectionProvider.notifier).value = newDir;
  ref.read(selectedCellProvider.notifier).value = SelectedCell(next.y, next.x);
}
