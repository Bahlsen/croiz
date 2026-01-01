import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';
import 'package:go_router/go_router.dart';

/// Enhanced puzzle list tile with difficulty badge, progress indicator, and language.
class PuzzleListTileEnhanced extends ConsumerWidget {
  const PuzzleListTileEnhanced({
    required this.descriptor,
    this.progress,
    this.completionPercent,
    this.isCompleted = false,
    super.key,
  });

  final PuzzleDescriptor descriptor;
  final PuzzleProgress? progress;
  final int? completionPercent;
  final bool isCompleted;

  /// Get color for difficulty level.
  static Color getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.amber;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      leading: _buildLeading(),
      title: Text(descriptor.title),
      subtitle: _buildSubtitle(theme),
      trailing: _buildTrailing(theme),
      onTap: () {
        ref.read(selectedPuzzleIdProvider.notifier).setSelected(descriptor.id);
        final encodedId = Uri.encodeComponent(descriptor.id);
        context.go('/crossword?id=$encodedId');
      },
    );
  }

  Widget _buildLeading() {
    final difficultyLabel = descriptor.difficultyLabel;

    if (difficultyLabel.isEmpty) {
      return const SizedBox(width: 48);
    }

    final color = getDifficultyColor(descriptor.difficulty);

    return Container(
      width: 48,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        difficultyLabel,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget? _buildSubtitle(ThemeData theme) {
    final parts = <String>[];

    if (descriptor.origin.isNotEmpty) {
      parts.add(descriptor.origin);
    }

    if (descriptor.year.isNotEmpty) {
      parts.add(descriptor.year);
    }

    if (parts.isEmpty) {
      return null;
    }

    return Text(
      parts.join(' • '),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTrailing(ThemeData theme) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Language indicator
      if (descriptor.language.isNotEmpty && descriptor.language != 'en')
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            descriptor.language.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      // Status indicator: completed, in progress, or nothing
      _buildStatusIndicator(theme),
    ],
  );

  Widget _buildStatusIndicator(ThemeData theme) {
    if (isCompleted) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 24);
    }

    if (completionPercent != null && completionPercent! > 0) {
      return Container(
        width: 40,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$completionPercent%',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
