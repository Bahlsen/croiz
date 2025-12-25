import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';

class ClueBannerContainer extends ConsumerWidget {
  const ClueBannerContainer({required this.entry, Key? key}) : super(key: key);

  final PuzzleEntryData entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () {
      final newDir = entry.direction == 'across'
          ? WordDirection.vertical
          : WordDirection.horizontal;
      ref.read(wordDirectionProvider.notifier).value = newDir;
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Center(
        child: Text(
          entry.clue == null || entry.clue!.isEmpty
              ? '${entry.number}.'
              : '${entry.number}. ${entry.clue!}',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
