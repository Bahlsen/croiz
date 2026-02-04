import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/core/responsive/responsive.dart';
import 'package:croiz/features/puzzles/logic/generated_puzzles_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/routes/app_routes.dart';
import 'package:flutter/services.dart'; // For HapticFeedback

import 'package:croiz/features/monetization/services/ad_service.dart';
import 'package:croiz/features/monetization/providers/subscription_provider.dart';

import 'dart:async'; // For unawaited

/// A premium, branded card representing a puzzle in the list.
class PuzzleCard extends ConsumerWidget {
  const PuzzleCard({
    required this.descriptor,
    this.completionPercent,
    this.isCompleted = false,
    this.isPending = false,
    this.compact = false,
    super.key,
  });

  final PuzzleDescriptor descriptor;
  final int? completionPercent;
  final bool isCompleted;
  final bool isPending;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _getDifficultyColors(descriptor.difficulty);

    return Opacity(
      opacity: isCompleted ? 0.6 : (isPending ? 0.5 : 1.0),
      child: Container(
        margin:
            compact
                ? EdgeInsets.zero
                : EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(compact ? 8 : 12),
          boxShadow: [
            if (!isPending)
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
          border: Border.all(
            color:
                isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            // Updated to be async for Ad logic
            onTap:
                (isPending || isCompleted) ? null : () => _onTap(context, ref),
            onLongPress:
                (isPending || !descriptor.source.isLocal)
                    ? null
                    : () => _onLongPress(context, ref),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Difficulty Color Strip
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: colors,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 3.w : 4.w,
                        vertical: compact ? 1.h : 1.2.h,
                      ),
                      child: Row(
                        children: [
                          // Left Section: Importance Info
                          Expanded(
                            child:
                                compact
                                    ? _buildCompactContent(
                                      context,
                                      theme,
                                      colors,
                                    )
                                    : _buildFullContent(context, theme, colors),
                          ),
                          if (!compact) SizedBox(width: 3.w),
                          // Right Section: Progress or Pending Indicator
                          if (isPending)
                            _buildPendingIndicator(theme, colors.last)
                          else
                            _buildProgressIndicator(theme, colors.last),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    // Check premium status
    final isPremium = ref.read(subscriptionProvider).value ?? false;

    if (!isPremium) {
      final adService = ref.read(monetizationServiceProvider);
      await adService.incrementPuzzleLoadCount();
      if (adService.shouldShowInterstitial) {
        await adService.showInterstitialAd();
      }
    }

    if (context.mounted) {
      ref.read(selectedPuzzleIdProvider.notifier).setSelected(descriptor.id);
      CrosswordRoute(id: descriptor.id).go(context);
    }
  }

  Future<void> _onLongPress(BuildContext context, WidgetRef ref) async {
    unawaited(HapticFeedback.mediumImpact());

    if (!context.mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)?.deletePuzzle ?? 'Delete Puzzle?',
            ),
            content: Text(
              AppLocalizations.of(context)?.deletePuzzleConfirmation ??
                  'Are you sure you want to delete "${descriptor.title}"? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(generatedPuzzlesControllerProvider.notifier)
            .deletePuzzle(descriptor.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              content: Text(
                AppLocalizations.of(context)?.deleteSuccessMessage ??
                    'Puzzle deleted successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on Object catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting puzzle: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildFullContent(
    BuildContext context,
    ThemeData theme,
    List<Color> colors,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        children: [
          Text(
            _getDifficultyLabel(descriptor.difficulty, context).toUpperCase(),
            style: TextStyle(
              color: colors.last,
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              descriptor.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                letterSpacing: -0.3,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      if (descriptor.origin.isNotEmpty || descriptor.year.isNotEmpty) ...[
        SizedBox(height: 0.4.h),
        _buildMetadata(theme),
      ],
    ],
  );

  Widget _buildCompactContent(
    BuildContext context,
    ThemeData theme,
    List<Color> colors,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        _getDifficultyLabel(descriptor.difficulty, context).toUpperCase(),
        style: TextStyle(
          color: colors.last,
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      SizedBox(height: 0.2.h),
      Text(
        descriptor.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          letterSpacing: -0.3,
          height: 1.1,
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );

  String _getDifficultyLabel(int difficulty, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (difficulty) {
      case 1:
        return l10n?.easy ?? 'Easy';
      case 2:
        return l10n?.medium ?? 'Medium';
      case 3:
        return l10n?.hard ?? 'Hard';
      case 4:
        return l10n?.expert ?? 'Expert';
      case 5:
        return l10n?.pro ?? 'Pro';
      default:
        return descriptor.difficultyLabel;
    }
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
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        fontWeight: FontWeight.w500,
        fontSize: 11.sp,
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, Color primaryColor) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
      );
    }

    if (completionPercent == null) {
      return const SizedBox.shrink();
    }

    final percent = completionPercent!;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 3,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: primaryColor,
          ),
        ),
        Text(
          '$percent%',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 10.sp,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingIndicator(ThemeData theme, Color primaryColor) =>
      SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: primaryColor.withValues(alpha: 0.5),
        ),
      );

  List<Color> _getDifficultyColors(int difficulty) => switch (difficulty) {
    1 => [Colors.green, Colors.teal],
    2 => [Colors.amber, Colors.orange],
    3 => [Colors.orange, Colors.deepOrange],
    4 => [Colors.red, Colors.pink],
    5 => [Colors.purple, Colors.indigo],
    _ => [Colors.grey, Colors.blueGrey],
  };
}
