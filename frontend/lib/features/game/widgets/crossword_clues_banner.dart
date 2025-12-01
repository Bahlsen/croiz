import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/board_helpers.dart';

/// Compact banner showing the clue for the currently selected word.
class CrosswordClueBanner extends ConsumerWidget {
  const CrosswordClueBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(gameBoardProvider);
    final selected = ref.watch(selectedCellProvider);
    final dir = ref.watch(wordDirectionProvider);

    if (selected == null) {
      return const SizedBox.shrink();
    }
    final horizontal = dir == WordDirection.horizontal;
    final bounds = board.blackCells.wordBounds(
      selected.row,
      selected.col,
      horizontal: horizontal,
    );
    final startX = horizontal ? bounds[0] : selected.col;
    final startY = horizontal ? selected.row : bounds[0];

    final entries = board.entries;
    if (entries == null || entries.isEmpty) {
      return const SizedBox.shrink();
    }

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

    if (entry.number == -1 || entry.clue == null || entry.clue!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Styling: no accent colors or glow; subtle border darker than the card.
    // Add left/right arrows outside the banner to navigate to previous/next word.
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Left arrow (previous word)
              _NavArrow(
                icon: Icons.chevron_left,
                onTap: () {
                  _navigateToAdjacentEntry(ref, entries, entry, -1);
                },
              ),
              // The clue banner
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[700]!, width: 1.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Text(
                    '${entry.number}  ${entry.clue!}',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Right arrow (next word)
              _NavArrow(
                icon: Icons.chevron_right,
                onTap: () {
                  _navigateToAdjacentEntry(ref, entries, entry, 1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 40,
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white70, size: 28),
      ),
    );
  }
}

void _navigateToAdjacentEntry(
  WidgetRef ref,
  List<PuzzleEntryData> entries,
  PuzzleEntryData current,
  int delta,
) {
  if (entries.isEmpty) return;
  // Sort by clue numbering then by direction to keep stable order.
  final sorted = List<PuzzleEntryData>.from(entries)
    ..sort((a, b) {
      final byNum = a.number.compareTo(b.number);
      if (byNum != 0) return byNum;
      return a.direction.compareTo(b.direction);
    });
  final idx = sorted.indexWhere((e) =>
      e.x == current.x && e.y == current.y && e.direction == current.direction);
  if (idx == -1) return;
  var nextIdx = idx + delta;
  if (nextIdx < 0) nextIdx = sorted.length - 1;
  if (nextIdx >= sorted.length) nextIdx = 0;
  final next = sorted[nextIdx];

  // Update selection and direction to the start of the target word.
  final newDir = next.direction == 'across'
      ? WordDirection.horizontal
      : WordDirection.vertical;
  ref.read(wordDirectionProvider.notifier).state = newDir;
  ref.read(selectedCellProvider.notifier).state = SelectedCell(next.y, next.x);
}