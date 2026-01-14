import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive.dart';
import '../filtered_puzzles_provider.dart';
import '../random_puzzles_provider.dart';
import 'puzzle_card.dart';

/// A 2x2 grid displaying 4 random puzzles for Quick Play mode.
class RandomPuzzleGrid extends ConsumerWidget {
  const RandomPuzzleGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final randomPuzzles = ref.watch(randomPuzzlesProvider);
    final completedIdsAsync = ref.watch(completedPuzzleIdsProvider);
    final completedIds = completedIdsAsync.whenOrNull(data: (ids) => ids) ?? {};

    if (randomPuzzles.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(4.w),
        child: Center(
          child: Text(
            'No matching puzzles',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            child: Text(
              '✨ Pick a puzzle:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Grid of puzzle cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 1.h,
              crossAxisSpacing: 2.w,
              childAspectRatio: 1.4,
            ),
            itemCount: randomPuzzles.length,
            itemBuilder: (context, index) {
              final puzzle = randomPuzzles[index];
              final isCompleted = completedIds.contains(puzzle.id);
              return PuzzleCard(
                descriptor: puzzle,
                isCompleted: isCompleted,
                compact: true,
              );
            },
          ),
        ],
      ),
    );
  }
}
