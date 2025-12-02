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
    final board = ref.watch(gameBoardProvider);
    final selected = ref.watch(selectedCellProvider);
    final dir = ref.watch(wordDirectionProvider);

    if (selected == null) {
      return const SizedBox.shrink();
    }

    final entryCtx = computeCurrentEntry(board, selected, dir);
    if (entryCtx == null) {
      return const SizedBox.shrink();
    }

    final horizontal = entryCtx.horizontal;
    final entry = entryCtx.entry;
    final entries = entryCtx.entries;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavArrow(
                icon: Icons.chevron_left,
                onTap: () => _navigateToAdjacentEntry(ref, entries, entry, -1),
              ),
              Expanded(
                child: _buildClueContainer(
                  ref: ref,
                  horizontal: horizontal,
                  entry: entry,
                ),
              ),
              _buildNavArrow(
                icon: Icons.chevron_right,
                onTap: () => _navigateToAdjacentEntry(ref, entries, entry, 1),
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
  Widget build(BuildContext context) => GestureDetector(
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

Widget _buildNavArrow({required IconData icon, required VoidCallback onTap}) => _NavArrow(icon: icon, onTap: onTap);

// Entry resolution logic moved to helpers/entry_lookup.dart

Widget _buildClueContainer({
  required WidgetRef ref,
  required bool horizontal,
  required PuzzleEntryData entry,
}) => GestureDetector(
    onTap: () {
      final newDir = horizontal ? WordDirection.vertical : WordDirection.horizontal;
      ref.read(wordDirectionProvider.notifier).value = newDir;
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Text(
        entry.clue == null || entry.clue!.isEmpty
            ? '${entry.number}'
            : '${entry.number}  ${entry.clue!}',
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
