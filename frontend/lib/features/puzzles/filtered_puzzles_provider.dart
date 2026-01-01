import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'puzzles_provider.dart';
import 'puzzle_filter_provider.dart';
import '../../services/persistence/hive_puzzle_storage.dart';

/// Provider that returns the set of completed puzzle IDs.
///
/// A puzzle is considered "completed" if it has been saved with 100%
/// completion in storage. This checks the `isCompleted` field in the
/// saved puzzle data.
final completedPuzzleIdsProvider = FutureProvider<Set<String>>((ref) async {
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

/// Provider that returns all available languages from the puzzle index.
///
/// Derives the set of unique language codes from all puzzles.
final availableLanguagesProvider = Provider<Set<String>>((ref) {
  final puzzlesAsync = ref.watch(puzzlesProvider);
  return puzzlesAsync.when(
    data: (puzzles) => puzzles.map((p) => p.language).toSet(),
    loading: () => const {'en'},
    error: (e, s) => const {'en'},
  );
});

/// Provider that returns all available difficulties from the puzzle index.
///
/// Derives the set of unique difficulty levels from all puzzles.
final availableDifficultiesProvider = Provider<Set<int>>((ref) {
  final puzzlesAsync = ref.watch(puzzlesProvider);
  return puzzlesAsync.when(
    data: (puzzles) => puzzles.map((p) => p.difficulty).toSet(),
    loading: () => const {},
    error: (e, s) => const {},
  );
});

/// Provider that returns puzzles filtered by the current filter state.
///
/// Watches both [puzzlesProvider] and [puzzleFilterProvider] and returns
/// only puzzles that match the current filters.
final filteredPuzzlesProvider = Provider<List<PuzzleDescriptor>>((ref) {
  final puzzlesAsync = ref.watch(puzzlesProvider);
  final filterState = ref.watch(puzzleFilterProvider);
  final completedIdsAsync = ref.watch(completedPuzzleIdsProvider);
  final availableLanguages = ref.watch(availableLanguagesProvider);

  // Get completed IDs set (empty if loading/error)
  final completedIds = completedIdsAsync.when(
    data: (ids) => ids,
    loading: () => <String>{},
    error: (e, s) => <String>{},
  );

  return puzzlesAsync.when(
    data: (puzzles) =>
        _filterPuzzles(puzzles, filterState, completedIds, availableLanguages),
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Filter puzzles based on the current filter state.
List<PuzzleDescriptor> _filterPuzzles(
  List<PuzzleDescriptor> puzzles,
  PuzzleFilterState filterState,
  Set<String> completedIds,
  Set<String> availableLanguages,
) => puzzles.where((puzzle) {
  // Filter by difficulty
  if (!filterState.selectedDifficulties.contains(puzzle.difficulty)) {
    return false;
  }

  // Filter by language
  // If selectedLanguages is empty, show all puzzles (multilingual default)
  if (filterState.selectedLanguages.isNotEmpty &&
      !filterState.selectedLanguages.contains(puzzle.language)) {
    return false;
  }

  // Filter by generated status
  if (filterState.showGeneratedOnly) {
    // Assuming 'generated' or 'ai' identifies generated puzzles.
    // Also matching 'test' as user context showed 'test' origin.
    // Ideally this should be more robust.
    final isGenerated =
        puzzle.origin.toLowerCase().contains('generated') ||
        puzzle.origin.toLowerCase() == 'ai' ||
        puzzle.origin.toLowerCase() ==
            'test'; // temporary: include 'test' for user context
    if (!isGenerated) {
      return false;
    }
  }

  // Filter by search query
  if (filterState.searchQuery.isNotEmpty) {
    final query = filterState.searchQuery.toLowerCase();
    final matchesTitle = puzzle.title.toLowerCase().contains(query);
    final matchesSubtitle = puzzle.subtitle.toLowerCase().contains(query);
    if (!matchesTitle && !matchesSubtitle) {
      return false;
    }
  }

  // Filter by completion status
  if (!filterState.showCompleted && completedIds.contains(puzzle.id)) {
    return false;
  }

  return true;
}).toList();
