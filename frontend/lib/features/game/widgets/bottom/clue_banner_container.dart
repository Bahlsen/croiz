import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';

class ClueBannerContainer extends ConsumerWidget {
  const ClueBannerContainer({
    required this.entry, required this.compact, Key? key,
  }) : super(key: key);

  final PuzzleEntryData entry;
  final bool compact;

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
        margin: EdgeInsets.symmetric(horizontal: compact ? 6 : 8),
        padding: EdgeInsets.symmetric(
          vertical: compact ? 12 : 16,
          horizontal: compact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
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
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
}
