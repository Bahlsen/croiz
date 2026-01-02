import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/core/responsive/responsive.dart';
import 'package:go_router/go_router.dart';

/// A premium, branded card representing a puzzle in the list.
class PuzzleCard extends ConsumerWidget {
  const PuzzleCard({
    required this.descriptor,
    this.completionPercent,
    this.isCompleted = false,
    super.key,
  });

  final PuzzleDescriptor descriptor;
  final int? completionPercent;
  final bool isCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Opacity(
      opacity: isCompleted ? 0.7 : 1.0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color:
                isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _onTap(context, ref),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDifficultyTag(theme, context),
                        SizedBox(height: 1.h),
                        Text(
                          descriptor.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color:
                                isCompleted
                                    ? theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6)
                                    : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        _buildMetadata(theme),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  // Progress Section
                  _buildProgressIndicator(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    ref.read(selectedPuzzleIdProvider.notifier).setSelected(descriptor.id);
    final encodedId = Uri.encodeComponent(descriptor.id);
    context.go('/crossword?id=$encodedId');
  }

  Widget _buildDifficultyTag(ThemeData theme, BuildContext context) {
    final colors = _getDifficultyColors(descriptor.difficulty);
    final l10n = AppLocalizations.of(context);
    String label;
    switch (descriptor.difficulty) {
      case 1:
        label = l10n?.easy ?? 'Easy';
        break;
      case 2:
        label = l10n?.medium ?? 'Medium';
        break;
      case 3:
        label = l10n?.hard ?? 'Hard';
        break;
      case 4:
        label = l10n?.expert ?? 'Expert';
        break;
      case 5:
        label = l10n?.pro ?? 'Pro';
        break;
      default:
        label = descriptor.difficultyLabel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.first.withValues(alpha: 0.8),
            colors.last.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMetadata(ThemeData theme) {
    final parts = [
      if (descriptor.origin.isNotEmpty) descriptor.origin,
      if (descriptor.year.isNotEmpty) descriptor.year,
      descriptor.language.toUpperCase(),
    ];

    return Text(
      parts.join(' • '),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
      );
    }

    final percent = completionPercent ?? 0;
    if (percent == 0) {
      return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 4,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          '$percent%',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  List<Color> _getDifficultyColors(int difficulty) {
    switch (difficulty) {
      case 1:
        return [Colors.green, Colors.teal];
      case 2:
        return [Colors.amber, Colors.orange];
      case 3:
        return [Colors.orange, Colors.deepOrange];
      case 4:
        return [Colors.red, Colors.pink];
      case 5:
        return [Colors.purple, Colors.indigo];
      default:
        return [Colors.grey, Colors.blueGrey];
    }
  }
}
