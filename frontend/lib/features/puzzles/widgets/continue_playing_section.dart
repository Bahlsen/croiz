import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../puzzles_provider.dart';
import '../../../services/persistence/puzzle_progress_service.dart';
import '../../../services/persistence/hive_puzzle_storage.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/responsive/responsive.dart';
import '../../game/providers/puzzle_loader_provider.dart';

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
final inProgressPuzzlesProvider = FutureProvider.autoDispose<
  List<InProgressPuzzleInfo>
>((ref) async {
  final storage = HivePuzzleStorage();

  // Listen to storage changes to automatically refresh the list
  // whenever a puzzle is saved (e.g. from the game screen).
  final subscription = storage.onDataChanged.listen((_) {
    // Debounce slightly if needed, but simple invalidation works fine
    ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  final service = PuzzleProgressService(
    storage: storage,
    assetLoader: defaultPuzzleJsonLoader,
  );

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

    final percent = service.calculateCompletionPercent(savedGrid, solution);

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
});

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
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
              child: Text(
                l10n?.continuePlaying ?? 'Continue Playing',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
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
            height: 20.h,
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

    context.go(
      Uri(
        path: '/crossword',
        queryParameters: {'id': puzzle.descriptor.id},
      ).toString(),
    );
  }

  static String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final difficultyColors = _getDifficultyColors(puzzle.descriptor.difficulty);

    return Container(
      width: 180,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPuzzle(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  puzzle.descriptor.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Difficulty tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        difficultyColors.first.withValues(alpha: 0.8),
                        difficultyColors.last.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    puzzle.descriptor.difficultyLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                // Progress and time row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${puzzle.completionPercent}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTime(puzzle.progress.elapsedSeconds),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: puzzle.completionPercent / 100,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
