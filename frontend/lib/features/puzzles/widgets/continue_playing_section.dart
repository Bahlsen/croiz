import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../puzzles_provider.dart';
import '../../../services/persistence/puzzle_progress_service.dart';
import '../../../services/persistence/hive_puzzle_storage.dart';
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
final inProgressPuzzlesProvider =
    FutureProvider<List<InProgressPuzzleInfo>>((ref) async {
  final storage = HivePuzzleStorage();
  final service = PuzzleProgressService(
    storage: storage,
    assetLoader: defaultPuzzleJsonLoader,
  );

  // Get all puzzles with saved progress
  final progressList = await service.getInProgressPuzzlesSortedByRecency();
  if (progressList.isEmpty) {
    return [];
  }

  // Get the puzzle descriptors to match progress with metadata
  final puzzlesAsync = ref.watch(puzzlesProvider);
  final puzzles = puzzlesAsync.maybeWhen(
    data: (p) => p,
    orElse: () => <PuzzleDescriptor>[],
  );

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
      inProgressList.add(InProgressPuzzleInfo(
        descriptor: descriptor,
        progress: progress,
        completionPercent: percent.round(),
      ));
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

    return inProgressAsync.when(
      data: (puzzles) {
        if (puzzles.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No puzzles in progress',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Continue Playing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
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
    // Select the puzzle and navigate to the game
    ref.read(selectedPuzzleIdProvider.notifier).setSelected(puzzle.descriptor.id);
    context.go('/game');
  }

  /// Get the color for a difficulty level.
  static Color _difficultyColor(int difficulty) {
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
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  /// Format elapsed seconds as mm:ss.
  static String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficultyColor = _difficultyColor(puzzle.descriptor.difficulty);

    return Card(
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: () => _navigateToPuzzle(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                puzzle.descriptor.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Difficulty badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: difficultyColor),
                ),
                child: Text(
                  puzzle.descriptor.difficultyLabel,
                  style: TextStyle(
                    color: difficultyColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              // Progress and time row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress percentage
                  Text(
                    '${puzzle.completionPercent}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Elapsed time
                  Text(
                    _formatTime(puzzle.progress.elapsedSeconds),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Progress bar
              LinearProgressIndicator(
                value: puzzle.completionPercent / 100,
                backgroundColor: Colors.grey.shade200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
