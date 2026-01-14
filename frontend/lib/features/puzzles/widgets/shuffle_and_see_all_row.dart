import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive.dart';
import '../random_puzzles_provider.dart';

/// Row with Shuffle button and "See all" link.
class ShuffleAndSeeAllRow extends ConsumerWidget {
  const ShuffleAndSeeAllRow({
    required this.totalCount,
    required this.onSeeAll,
    super.key,
  });

  /// Total number of filtered puzzles.
  final int totalCount;

  /// Callback when "See all" is tapped.
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shuffle button
          OutlinedButton.icon(
            onPressed: () {
              ref.invalidate(randomPuzzlesProvider);
            },
            icon: const Icon(Icons.shuffle, size: 18),
            label: const Text('Shuffle'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 16),
          // Divider
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 16),
          // See all link
          TextButton.icon(
            onPressed: onSeeAll,
            icon: const Icon(Icons.list, size: 18),
            label: Text('See all ($totalCount)'),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}
