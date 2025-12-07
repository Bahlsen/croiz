import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/helpers/entry_lookup.dart';
import 'package:croiz/features/game/helpers/word_navigation.dart';

/// Compact banner showing the clue for the currently selected word.
class CrosswordClueBanner extends ConsumerWidget {
  const CrosswordClueBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer using the loader provider as a resilient source of truth
    // when the full `gameBoardProvider` may not be synchronously available
    // during tests or early startup.
    final pu = ref.watch(puzzleLoaderProvider);
    final board = pu.maybeWhen(
      data: (d) => d,
      orElse: () => createEmptyBoard(5),
    );
    final selected = ref.watch(selectedCellProvider);
    final dir = ref.watch(wordDirectionProvider);

    if (selected == null) {
      // When there's no selection (tests / early startup), render a
      // small placeholder banner so the layout remains stable and
      // measurable. This prevents zero-height banners in tests.
      return Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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

    final entryCtx = computeCurrentEntry(board, selected, dir);
    if (entryCtx == null) {
      return const SizedBox.shrink();
    }

    final horizontal = entryCtx.horizontal;
    final entry = entryCtx.entry;
    final entries = entryCtx.entries;

    // Use MediaQuery here instead of a LayoutBuilder to avoid introducing
    // an extra relayout boundary inside the banner which can cause layout
    // ordering races during widget tests. The visual adaptation is minor
    // and MediaQuery size is sufficient for our compact threshold.
    final availableHeight = MediaQuery.of(context).size.height;
    final isCompact = availableHeight < 72;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: isCompact ? 3 : 6,
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
                      _navigateToAdjacentEntry(ref, entries, entry, -1),
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
                  onTap: () => _navigateToAdjacentEntry(ref, entries, entry, 1),
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
      width: compact ? 40 : 44,
      height: compact ? 44 : 48,
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white70, size: compact ? 28 : 32),
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
    // Give the container a little more horizontal breathing room
    // so it appears wider visually when available.
    margin: EdgeInsets.symmetric(horizontal: compact ? 10 : 16),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(compact ? 10 : 12),
      border: Border.all(color: Colors.grey[700]!, width: 1),
    ),
    padding: EdgeInsets.symmetric(
      vertical: compact ? 12 : 16,
      horizontal: compact ? 16 : 22,
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        entry.clue == null || entry.clue!.isEmpty
            ? '${entry.number}.'
            : '${entry.number}. ${entry.clue!}',
        textAlign: TextAlign.center,
        maxLines: compact ? 2 : 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 17 : 19,
          fontWeight: FontWeight.w600,
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
