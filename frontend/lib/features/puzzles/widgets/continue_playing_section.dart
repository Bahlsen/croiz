import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/routes/app_routes.dart';
import '../puzzles_provider.dart';
import '../../../services/persistence/storage_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/responsive/responsive.dart';
import '../../game/providers/puzzle_loader_provider.dart';
import '../logic/generated_puzzles_controller.dart';

import '../../game/providers/game_providers.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart'; // For PuzzleProgressService, PuzzleProgress
import 'package:croiz/services/persistence/puzzle_progress_provider.dart'; // For provider
import 'package:flutter/services.dart'; // For HapticFeedback

part 'continue_playing_section.g.dart';

/// Information about an in-progress puzzle for display.
class InProgressPuzzleInfo {
  const InProgressPuzzleInfo({
    required this.descriptor,
    required this.progress,
    required this.completionPercent,
  });

  final PuzzleDescriptor descriptor;
  final PuzzleProgress progress;
  final int completionPercent;
}

/// Provider that returns the list of in-progress puzzles sorted by recency.
///
/// Fetches all puzzles with saved progress, calculates completion percent,
/// and returns them sorted by most recently played.
@riverpod
Future<List<InProgressPuzzleInfo>> inProgressPuzzles(Ref ref) async {
  final storage = ref.watch(puzzleStorageProvider);

  // Listen to storage changes to automatically refresh the list
  // whenever a puzzle is saved (e.g. from the game screen).
  final subscription = storage.onDataChanged.listen((_) {
    // Debounce slightly if needed, but simple invalidation works fine
    ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  final service = ref.watch(puzzleProgressServiceProvider);

  // Get all puzzles with saved progress
  final progressList = await service.getInProgressPuzzlesSortedByRecency();
  if (progressList.isEmpty) {
    return [];
  }

  // Get the puzzle descriptors to match progress with metadata.
  // IMPORTANT: We must await the .future to properly wait for puzzlesProvider
  // to load. Using maybeWhen with orElse would return empty list before
  // the puzzles are loaded, causing the in-progress section to appear empty.
  final puzzles = await ref.watch(puzzlesProvider.future);

  if (puzzles.isEmpty) {
    return [];
  }

  // Create a map for quick lookup
  final puzzleMap = {for (final p in puzzles) p.id: p};

  final inProgressList = <InProgressPuzzleInfo>[];

  for (final progress in progressList) {
    final descriptor = puzzleMap[progress.puzzleId];
    if (descriptor == null) {
      continue;
    }

    // Load saved data to calculate completion percent
    final data = await storage.load(progress.puzzleId);
    if (data == null) {
      continue;
    }

    // Skip completed puzzles
    final isCompleted = data['isCompleted'] as bool? ?? false;
    if (isCompleted) {
      continue;
    }

    // Calculate completion percent from saved grid
    final savedGrid = _extractGrid(data);
    if (savedGrid == null) {
      continue;
    }

    // Load solution to calculate percent
    final puzzleJson = await defaultPuzzleJsonLoader(descriptor.path);
    final solution = _extractSolutionGrid(puzzleJson);
    final clues = _extractClues(puzzleJson);

    final percent = service.calculateCompletionPercentByWords(
      savedGrid,
      solution,
      clues,
    );

    // Only show puzzles that are actually in progress (not 0% or 100%)
    if (percent > 0 && percent < 100) {
      inProgressList.add(
        InProgressPuzzleInfo(
          descriptor: descriptor,
          progress: progress,
          completionPercent: percent.round(),
        ),
      );
    }
  }

  return inProgressList;
}

/// Extract grid from saved puzzle data.
List<List<String?>>? _extractGrid(Map<String, dynamic> data) {
  final gridData = data['grid'];
  if (gridData == null || gridData is! List) {
    return null;
  }

  return gridData.map<List<String?>>((row) {
    if (row is! List) {
      return <String?>[];
    }
    return row.map<String?>((cell) => cell as String?).toList();
  }).toList();
}

/// Extract solution grid from puzzle JSON.
List<List<String?>> _extractSolutionGrid(Map<String, dynamic> puzzleJson) {
  final cells = puzzleJson['cells'] as List<dynamic>? ?? [];
  final cols = puzzleJson['cols'] as int? ?? 0;
  final rows = puzzleJson['rows'] as int? ?? 0;

  if (cols == 0 || rows == 0) {
    return [];
  }

  final grid = <List<String?>>[];
  for (var row = 0; row < rows; row++) {
    final rowList = <String?>[];
    for (var col = 0; col < cols; col++) {
      final index = row * cols + col;
      if (index < cells.length) {
        final cell = cells[index] as Map<String, dynamic>?;
        if (cell != null && cell['is_black'] == true) {
          rowList.add(null);
        } else {
          rowList.add(cell?['solution'] as String?);
        }
      } else {
        rowList.add(null);
      }
    }
    grid.add(rowList);
  }
  return grid;
}

/// Extract clues from puzzle JSON.
List<Map<String, dynamic>> _extractClues(Map<String, dynamic> puzzleJson) {
  // Use 'entries' which is the standard key for our Puzzle model
  final entries = puzzleJson['entries'] as List<dynamic>?;
  if (entries != null) {
    return entries.cast<Map<String, dynamic>>().toList();
  }

  // Fallback to 'clues' if it's a list (legacy or different format)
  final cluesData = puzzleJson['clues'];
  if (cluesData is List) {
    return cluesData.cast<Map<String, dynamic>>().toList();
  }

  return [];
}

/// A horizontal scrollable section showing puzzles that are in progress.
class ContinuePlayingSection extends ConsumerWidget {
  const ContinuePlayingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inProgressAsync = ref.watch(inProgressPuzzlesProvider);
    final theme = Theme.of(context);

    return inProgressAsync.when(
      data: (puzzles) {
        final l10n = AppLocalizations.of(context);
        if (puzzles.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n?.noPuzzlesInProgress ?? 'No puzzles in progress',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0.5.h),
              child: Row(
                children: [
                  Text(
                    l10n?.continuePlaying ?? 'Continue Playing',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: theme.colorScheme.primary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${puzzles.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 115, // Significantly reduced from 155
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                itemCount: puzzles.length,
                itemBuilder: (context, index) {
                  final puzzle = puzzles[index];
                  return _InProgressCard(puzzle: puzzle);
                },
              ),
            ),
          ],
        );
      },
      loading:
          () => SizedBox(
            height: 15.h,
            child: const Center(child: CircularProgressIndicator()),
          ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

/// Card displaying an in-progress puzzle.
class _InProgressCard extends ConsumerWidget {
  const _InProgressCard({required this.puzzle});

  final InProgressPuzzleInfo puzzle;

  /// Navigate to the puzzle game screen.
  void _navigateToPuzzle(BuildContext context, WidgetRef ref) {
    ref
        .read(selectedPuzzleIdProvider.notifier)
        .setSelected(puzzle.descriptor.id);

    CrosswordRoute(id: puzzle.descriptor.id).go(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _getDifficultyColors(puzzle.descriptor.difficulty);

    return Container(
      width: 160, // Compact width for better density
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPuzzle(context, ref),
          onLongPress:
              puzzle.descriptor.source.isLocal
                  ? () => _onLongPress(context, ref)
                  : null,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Subtle background progress hint
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: puzzle.completionPercent / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.first.withValues(alpha: 0.05),
                            colors.last.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _DifficultyDot(
                          difficulty: puzzle.descriptor.difficulty,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            puzzle.descriptor.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _getDifficultyLabel(
                            puzzle.descriptor.difficulty,
                            context,
                          ).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.last.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w800,
                            fontSize: 11.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${puzzle.completionPercent}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.last,
                            fontWeight: FontWeight.w900,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bottom Progress Bar (Neon line)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: puzzle.completionPercent / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: colors),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        return 'Unknown';
    }
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

  Future<void> _onLongPress(BuildContext context, WidgetRef ref) async {
    await HapticFeedback.mediumImpact();

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
                  'Are you sure you want to delete "${puzzle.descriptor.title}"? This cannot be undone.',
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
            .deletePuzzle(puzzle.descriptor.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              content: Text(
                AppLocalizations.of(context)?.successMessage ??
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
}

class _DifficultyDot extends StatelessWidget {
  const _DifficultyDot({required this.difficulty});
  final int difficulty;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  List<Color> _getColors() {
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
