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
    child: FractionallySizedBox(
      widthFactor: 0.9,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 96),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
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
          child: Center(
            child: Text(
              entry.clue == null || entry.clue!.isEmpty
                  ? '${entry.number}.'
                  : '${entry.number}. ${entry.clue!}',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
