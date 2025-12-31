import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'puzzles_provider.dart';
import 'puzzle_filter_provider.dart';
import '../../services/persistence/hive_puzzle_storage.dart';

/// Provider that returns the set of completed puzzle IDs.
///
/// A puzzle is considered "completed" if it has been saved with 100%
/// completion in storage. This checks the `isCompleted` field in the
/// saved puzzle data.
final completedPuzzleIdsProvider =
    FutureProvider<Set<String>>((ref) async {
  final storage = HivePuzzleStorage();
  final allKeys = await storage.getAllKeys();
  final completedIds = <String>{};

  for (final puzzleId in allKeys) {
    final data = await storage.load(puzzleId);
    if (data != null) {
      // Check if puzzle is marked as completed
      final isCompleted = data['isCompleted'] as bool? ?? false;
      if (isCompleted) {
        completedIds.add(puzzleId);
      }
    }
  }

  return completedIds;
});

/// Provider that returns puzzles filtered by the current filter state.
///
/// Watches both [puzzlesProvider] and [puzzleFilterProvider] and returns
/// only puzzles that match the current filters.
final filteredPuzzlesProvider = Provider<List<PuzzleDescriptor>>((ref) {
  final puzzlesAsync = ref.watch(puzzlesProvider);
  final filterState = ref.watch(puzzleFilterProvider);
  final completedIdsAsync = ref.watch(completedPuzzleIdsProvider);

  // Get completed IDs set (empty if loading/error)
  final completedIds = completedIdsAsync.when(
    data: (ids) => ids,
    loading: () => <String>{},
    error: (e, s) => <String>{},
  );

  return puzzlesAsync.when(
    data: (puzzles) => _filterPuzzles(puzzles, filterState, completedIds),
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Filter puzzles based on the current filter state.
List<PuzzleDescriptor> _filterPuzzles(
  List<PuzzleDescriptor> puzzles,
  PuzzleFilterState filterState,
  Set<String> completedIds,
) =>
    puzzles.where((puzzle) {
      // Filter by difficulty
      if (!filterState.selectedDifficulties.contains(puzzle.difficulty)) {
        return false;
      }

      // Filter by language
      if (!filterState.selectedLanguages.contains(puzzle.language)) {
        return false;
      }

      // Filter by completion status
      if (!filterState.showCompleted && completedIds.contains(puzzle.id)) {
        return false;
      }

      return true;
    }).toList();
