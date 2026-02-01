import 'dart:convert';

import 'package:flutter/services.dart';

/// Interface for puzzle storage operations.
///
/// This abstraction allows for testing with mock implementations.
abstract class PuzzleStorageInterface {
  /// Load saved puzzle data by ID.
  Future<Map<String, dynamic>?> load(String id);

  /// Save puzzle data by ID.
  Future<void> save(String id, Map<String, dynamic> payload);

  /// Delete puzzle data by ID.
  Future<void> delete(String id);

  /// Get all saved puzzle IDs.
  Future<List<String>> getAllKeys();

  /// Stream of changes to the storage.
  Stream<void> get onDataChanged;
}

/// Function signature for loading puzzle assets.
///
/// This abstraction allows for testing with mock implementations.
typedef PuzzleJsonLoader = Future<Map<String, dynamic>> Function(String path);

/// Default asset loader using Flutter's rootBundle.
Future<Map<String, dynamic>> defaultPuzzleJsonLoader(String path) async {
  final raw = await rootBundle.loadString('assets/data/$path');
  return jsonDecode(raw) as Map<String, dynamic>;
}

/// Progress information for a puzzle.
class PuzzleProgress {
  PuzzleProgress({
    required this.puzzleId,
    required this.savedAt,
    required this.elapsedSeconds,
    this.completionPercent,
  });

  final String puzzleId;
  final DateTime savedAt;
  final int elapsedSeconds;
  final double? completionPercent;
}

/// Service for tracking puzzle progress.
///
/// Provides methods to:
/// - Get all in-progress puzzles
/// - Calculate completion percentage
/// - Check if a puzzle is completed
/// - Cache solutions for performance
class PuzzleProgressService {
  PuzzleProgressService({
    required PuzzleStorageInterface storage,
    required PuzzleJsonLoader assetLoader,
  }) : _storage = storage,
       _assetLoader = assetLoader;

  final PuzzleStorageInterface _storage;
  final PuzzleJsonLoader _assetLoader;

  /// Cache for loaded puzzle solutions to avoid redundant asset loads.
  final Map<String, List<List<String?>>> _solutionCache = {};

  /// Get all puzzle IDs that have saved progress.
  Future<List<String>> getAllInProgressPuzzleIds() async =>
      _storage.getAllKeys();

  /// Get progress information for a specific puzzle.
  ///
  /// Returns null if the puzzle has no saved progress.
  Future<PuzzleProgress?> getProgress(String puzzleId) async {
    final data = await _storage.load(puzzleId);
    if (data == null) {
      return null;
    }

    final savedAtStr = data['savedAt'] as String?;
    final savedAt =
        savedAtStr != null ? DateTime.parse(savedAtStr) : DateTime.now();
    final elapsedSeconds = (data['elapsedSeconds'] as int?) ?? 0;

    return PuzzleProgress(
      puzzleId: puzzleId,
      savedAt: savedAt,
      elapsedSeconds: elapsedSeconds,
    );
  }

  /// Delete progress for a specific puzzle.
  Future<void> deleteProgress(String puzzleId) async =>
      _storage.delete(puzzleId);

  /// Calculate completion percentage for a grid against a solution.
  ///
  /// - `grid` is the user's current grid
  /// - `solution` is the puzzle solution
  /// - Black cells (null in solution) are ignored
  /// - Returns 0-100 percentage
  ///
  /// **DEPRECATED**: This method calculates completion based on filled cells,
  /// not completed words. Use [calculateCompletionPercentByWords] instead.
  double calculateCompletionPercent(
    List<List<String?>> grid,
    List<List<String?>> solution,
  ) {
    var filledCount = 0;
    var totalWhiteCells = 0;

    for (var row = 0; row < solution.length; row++) {
      for (var col = 0; col < solution[row].length; col++) {
        final solutionCell = solution[row][col];
        // Skip black cells (null in solution)
        if (solutionCell == null) {
          continue;
        }
        totalWhiteCells++;

        // Check if user has filled this cell
        if (row < grid.length && col < grid[row].length) {
          final userCell = grid[row][col];
          if (userCell != null && userCell.isNotEmpty) {
            filledCount++;
          }
        }
      }
    }

    if (totalWhiteCells == 0) {
      return 0;
    }

    return (filledCount / totalWhiteCells) * 100;
  }

  /// Calculate completion percentage based on completed words.
  ///
  /// - `grid` is the user's current grid
  /// - `solution` is the puzzle solution
  /// - `clues` is the list of clue definitions from the puzzle JSON
  /// - Returns 0-100 percentage based on how many words are fully correct
  ///
  /// A word is considered completed only if ALL its letters match the solution.
  double calculateCompletionPercentByWords(
    List<List<String?>> grid,
    List<List<String?>> solution,
    List<Map<String, dynamic>> clues,
  ) {
    if (clues.isEmpty) {
      return 0;
    }

    var completedWords = 0;

    for (final clue in clues) {
      final direction = clue['direction'] as String?;
      final x = clue['x'] as int?;
      final y = clue['y'] as int?;
      final length = clue['length'] as int?;

      if (direction == null || x == null || y == null || length == null) {
        continue;
      }

      var isWordComplete = true;

      for (var i = 0; i < length; i++) {
        final row = direction == 'across' ? y : y + i;
        final col = direction == 'across' ? x + i : x;

        // Check bounds
        if (row >= solution.length || col >= solution[row].length) {
          isWordComplete = false;
          break;
        }

        final solutionCell = solution[row][col];

        // Skip black cells
        if (solutionCell == null) {
          continue;
        }

        // Check if user's grid has this cell
        if (row >= grid.length || col >= grid[row].length) {
          isWordComplete = false;
          break;
        }

        final userCell = grid[row][col];

        // Check if cell matches solution (case-insensitive)
        if (userCell == null ||
            userCell.toUpperCase() != solutionCell.toUpperCase()) {
          isWordComplete = false;
          break;
        }
      }

      if (isWordComplete) {
        completedWords++;
      }
    }

    return (completedWords / clues.length) * 100;
  }

  /// Get all in-progress puzzles sorted by most recently saved.
  Future<List<PuzzleProgress>> getInProgressPuzzlesSortedByRecency() async {
    final ids = await getAllInProgressPuzzleIds();
    final progressList = <PuzzleProgress>[];

    for (final id in ids) {
      final progress = await getProgress(id);
      if (progress != null) {
        progressList.add(progress);
      }
    }

    // Sort by savedAt descending (newest first)
    progressList.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return progressList;
  }

  /// Check if a puzzle is completed (all cells match solution).
  ///
  /// - [grid] is the user's current grid
  /// - [puzzlePath] is the path to load the puzzle solution
  /// - Uses caching to avoid redundant asset loads
  Future<bool> isCompleted({
    required List<List<String?>> grid,
    required String puzzlePath,
  }) async {
    final solution = await _loadSolution(puzzlePath);

    for (var row = 0; row < solution.length; row++) {
      for (var col = 0; col < solution[row].length; col++) {
        final solutionCell = solution[row][col];
        // Skip black cells
        if (solutionCell == null) {
          continue;
        }

        // Check if user's answer matches
        if (row >= grid.length || col >= grid[row].length) {
          return false;
        }

        final userCell = grid[row][col];
        if (userCell == null ||
            userCell.toUpperCase() != solutionCell.toUpperCase()) {
          return false;
        }
      }
    }

    return true;
  }

  /// Load and cache the solution grid for a puzzle.
  Future<List<List<String?>>> _loadSolution(String puzzlePath) async {
    // Check cache first
    if (_solutionCache.containsKey(puzzlePath)) {
      return _solutionCache[puzzlePath]!;
    }

    // Load from assets
    final puzzleJson = await _assetLoader(puzzlePath);
    final solution = _extractSolutionGrid(puzzleJson);

    // Cache and return
    _solutionCache[puzzlePath] = solution;
    return solution;
  }

  /// Extract solution grid from puzzle JSON.
  ///
  /// Puzzle JSON has cells as a flat list with 'solution' field.
  /// We convert to 2D grid based on rows/cols.
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
            rowList.add(null); // Black cell
          } else {
            rowList.add(cell?['solution']?.toString());
          }
        } else {
          rowList.add(null);
        }
      }
      grid.add(rowList);
    }

    return grid;
  }

  /// Clear the solution cache to free memory.
  void clearSolutionCache() {
    _solutionCache.clear();
  }
}
