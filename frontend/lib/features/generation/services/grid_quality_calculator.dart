import 'package:croiz/features/generation/models/grid_quality_metrics.dart';
import 'package:croiz/features/generation/models/placed_word.dart';

/// Calculator for grid quality metrics.
///
/// Analyzes placed words and grid structure to compute quality metrics
/// used for evaluating and comparing generation algorithms.
class GridQualityCalculator {
  /// Calculate comprehensive quality metrics for a generated grid.
  static GridQualityMetrics calculate({
    required List<PlacedWord> placedWords,
    required int gridWidth,
    required int gridHeight,
    required int totalWordsAttempted,
  }) {
    if (placedWords.isEmpty) {
      return GridQualityMetrics(
        wordsPlaced: 0,
        totalWords: totalWordsAttempted,
        letterDensity: 0,
        blackSquareRatio: 1,
        rowCoverage: 0,
        columnCoverage: 0,
        totalIntersections: 0,
        avgIntersectionsPerWord: 0,
        filledCells: 0,
        totalCells: gridWidth * gridHeight,
        boundingWidth: 0,
        boundingHeight: 0,
      );
    }
    if (totalWordsAttempted == 0) {
      return GridQualityMetrics(
        wordsPlaced: 0,
        totalWords: 0,
        letterDensity: 0,
        blackSquareRatio: 0,
        rowCoverage: 0,
        columnCoverage: 0,
        totalIntersections: 0,
        avgIntersectionsPerWord: 0,
        filledCells: 0,
        totalCells: gridWidth * gridHeight,
        boundingWidth: 0,
        boundingHeight: 0,
      );
    }

    // Build a grid map to track filled cells
    final grid = <String, String>{}; // "x,y" -> letter
    final rowsWithAcross = <int>{};
    final colsWithDown = <int>{};

    // Track bounding box
    var minX = gridWidth;
    var maxX = 0;
    var minY = gridHeight;
    var maxY = 0;

    for (final pw in placedWords) {
      // Track row/column coverage
      if (pw.isHorizontal) {
        rowsWithAcross.add(pw.startY);
      } else {
        colsWithDown.add(pw.startX);
      }

      // Fill grid and update bounding box
      for (var i = 0; i < pw.word.answer.length; i++) {
        final x = pw.isHorizontal ? pw.startX + i : pw.startX;
        final y = pw.isHorizontal ? pw.startY : pw.startY + i;

        grid['$x,$y'] = pw.word.answer[i];

        if (x < minX) {
          minX = x;
        }
        if (x > maxX) {
          maxX = x;
        }
        if (y < minY) {
          minY = y;
        }
        if (y > maxY) {
          maxY = y;
        }
      }
    }

    // Calculate metrics
    final filledCells = grid.length;
    final totalCells = gridWidth * gridHeight;
    final boundingWidth = maxX - minX + 1;
    final boundingHeight = maxY - minY + 1;
    final boundingArea = boundingWidth * boundingHeight;

    final letterDensity = boundingArea > 0 ? filledCells / boundingArea : 0.0;
    final blackSquareRatio =
        totalCells > 0 ? (totalCells - filledCells) / totalCells : 1.0;

    final rowCoverage =
        gridHeight > 0 ? rowsWithAcross.length / gridHeight : 0.0;
    final columnCoverage =
        gridWidth > 0 ? colsWithDown.length / gridWidth : 0.0;

    // Count intersections
    final intersections = _countIntersections(placedWords);
    final avgIntersectionsPerWord =
        placedWords.isNotEmpty ? intersections / placedWords.length : 0.0;

    return GridQualityMetrics(
      wordsPlaced: placedWords.length,
      totalWords: totalWordsAttempted,
      letterDensity: letterDensity,
      blackSquareRatio: blackSquareRatio,
      rowCoverage: rowCoverage,
      columnCoverage: columnCoverage,
      totalIntersections: intersections,
      avgIntersectionsPerWord: avgIntersectionsPerWord,
      filledCells: filledCells,
      totalCells: totalCells,
      boundingWidth: boundingWidth,
      boundingHeight: boundingHeight,
    );
  }

  /// Count the total number of cell intersections.
  ///
  /// An intersection occurs when a horizontal and vertical word
  /// share the same cell.
  static int _countIntersections(List<PlacedWord> placedWords) {
    // Build sets of cells for horizontal and vertical words
    final horizontalCells = <String>{};
    final verticalCells = <String>{};

    for (final pw in placedWords) {
      for (var i = 0; i < pw.word.answer.length; i++) {
        final x = pw.isHorizontal ? pw.startX + i : pw.startX;
        final y = pw.isHorizontal ? pw.startY : pw.startY + i;
        final key = '$x,$y';

        if (pw.isHorizontal) {
          horizontalCells.add(key);
        } else {
          verticalCells.add(key);
        }
      }
    }

    // Count cells that appear in both sets
    return horizontalCells.intersection(verticalCells).length;
  }

  /// Analyze sparse coverage and return details about missing rows/columns.
  static SparseCoverageAnalysis analyzeSparseCoverage({
    required List<PlacedWord> placedWords,
    required int gridWidth,
    required int gridHeight,
  }) {
    final rowsWithAcross = <int>{};
    final colsWithDown = <int>{};

    for (final pw in placedWords) {
      if (pw.isHorizontal) {
        rowsWithAcross.add(pw.startY);
      } else {
        colsWithDown.add(pw.startX);
      }
    }

    final missingRows = <int>[];
    final missingCols = <int>[];

    for (var y = 0; y < gridHeight; y++) {
      if (!rowsWithAcross.contains(y)) {
        missingRows.add(y);
      }
    }

    for (var x = 0; x < gridWidth; x++) {
      if (!colsWithDown.contains(x)) {
        missingCols.add(x);
      }
    }

    return SparseCoverageAnalysis(
      missingAcrossRows: missingRows,
      missingDownColumns: missingCols,
      totalRows: gridHeight,
      totalColumns: gridWidth,
    );
  }

  /// Perform a deep structural analysis to detect patterns like spines.
  static GridStructureAnalysis analyzeStructure(List<PlacedWord> placedWords) {
    if (placedWords.isEmpty) {
      return const GridStructureAnalysis.empty();
    }

    final horizontalWords = placedWords.where((w) => w.isHorizontal).toList();
    final verticalWords = placedWords.where((w) => !w.isHorizontal).toList();

    // Map cells to words for fast lookup
    final horizontalCells = <String, PlacedWord>{};
    for (final pw in horizontalWords) {
      for (var i = 0; i < pw.word.answer.length; i++) {
        horizontalCells['${pw.startX + i},${pw.startY}'] = pw;
      }
    }

    final verticalCells = <String, PlacedWord>{};
    for (final pw in verticalWords) {
      for (var i = 0; i < pw.word.answer.length; i++) {
        verticalCells['${pw.startX},${pw.startY + i}'] = pw;
      }
    }

    // Find intersection cells
    final intersectionCells = horizontalCells.keys.toSet().intersection(
      verticalCells.keys.toSet(),
    );
    final totalIntersections = intersectionCells.length;

    // Count intersections per word
    final wordIntersections = <PlacedWord, int>{};
    for (final pw in placedWords) {
      var count = 0;
      for (var i = 0; i < pw.word.answer.length; i++) {
        final x = pw.isHorizontal ? pw.startX + i : pw.startX;
        final y = pw.isHorizontal ? pw.startY : pw.startY + i;
        final key = '$x,$y';

        if (intersectionCells.contains(key)) {
          count++;
        }
      }
      wordIntersections[pw] = count;
    }

    // Detect spine pattern: one word has >70% of intersections
    PlacedWord? spineWord;
    double spineRatio = 0;
    if (totalIntersections > 0) {
      for (final entry in wordIntersections.entries) {
        final ratio = entry.value / totalIntersections;
        if (ratio > spineRatio) {
          spineRatio = ratio;
          spineWord = entry.key;
        }
      }
    }

    // Count isolated words (0 intersections)
    final isolatedWords =
        wordIntersections.entries.where((e) => e.value == 0).length;

    // Find minimum intersections per word
    final minIntersections =
        wordIntersections.values.isEmpty
            ? 0
            : wordIntersections.values.reduce((a, b) => a < b ? a : b);

    return GridStructureAnalysis(
      horizontalCount: horizontalWords.length,
      verticalCount: verticalWords.length,
      totalIntersections: totalIntersections,
      spineWord: spineWord,
      spineIntersectionRatio: spineRatio,
      isolatedWordCount: isolatedWords,
      minIntersectionsPerWord: minIntersections,
      wordIntersections: wordIntersections,
    );
  }
}

/// Analysis of sparse coverage in a crossword grid.
class SparseCoverageAnalysis {
  const SparseCoverageAnalysis({
    required this.missingAcrossRows,
    required this.missingDownColumns,
    required this.totalRows,
    required this.totalColumns,
  });

  final List<int> missingAcrossRows;
  final List<int> missingDownColumns;
  final int totalRows;
  final int totalColumns;

  bool get isSparse =>
      missingAcrossRows.length > totalRows * 0.3 ||
      missingDownColumns.length > totalColumns * 0.3;

  String get warningMessage {
    if (!isSparse) {
      return '';
    }

    final parts = <String>[];
    if (missingAcrossRows.isNotEmpty) {
      parts.add(
        'missing across words for rows: ${missingAcrossRows.join(', ')}',
      );
    }
    if (missingDownColumns.isNotEmpty) {
      parts.add(
        'missing down words for cols: ${missingDownColumns.join(', ')}',
      );
    }

    return 'Sparse puzzle detected: ${parts.join('; ')}';
  }

  @override
  String toString() =>
      warningMessage.isNotEmpty ? warningMessage : 'Good coverage';
}

/// Detailed structural analysis of the grid
class GridStructureAnalysis {
  const GridStructureAnalysis({
    required this.horizontalCount,
    required this.verticalCount,
    required this.totalIntersections,
    required this.spineWord,
    required this.spineIntersectionRatio,
    required this.isolatedWordCount,
    required this.minIntersectionsPerWord,
    required this.wordIntersections,
  });

  const GridStructureAnalysis.empty()
    : horizontalCount = 0,
      verticalCount = 0,
      totalIntersections = 0,
      spineWord = null,
      spineIntersectionRatio = 0,
      isolatedWordCount = 0,
      minIntersectionsPerWord = 0,
      wordIntersections = const {};

  final int horizontalCount;
  final int verticalCount;
  final int totalIntersections;
  final PlacedWord? spineWord;
  final double spineIntersectionRatio;
  final int isolatedWordCount;
  final int minIntersectionsPerWord;
  final Map<PlacedWord, int> wordIntersections;

  /// Has spine pattern when one word has >70% of all intersections
  bool get hasSpinePattern =>
      spineIntersectionRatio > 0.7 && totalIntersections >= 3;

  String? get spineWordAnswer => spineWord?.word.answer;

  /// Orientation is unbalanced when ratio is >3:1
  bool get isOrientationUnbalanced {
    if (horizontalCount == 0 && verticalCount == 0) {
      return false;
    }
    return orientationRatio > 3.0;
  }

  double get orientationRatio {
    if (horizontalCount == 0 && verticalCount == 0) {
      return 1;
    }
    if (horizontalCount == 0 || verticalCount == 0) {
      return (horizontalCount + verticalCount).toDouble();
    }
    final max =
        horizontalCount > verticalCount ? horizontalCount : verticalCount;
    final min =
        horizontalCount < verticalCount ? horizontalCount : verticalCount;
    return max / min;
  }

  /// Has isolated words if any word has 0 intersections
  bool get hasIsolatedWords => isolatedWordCount > 0;

  @override
  String toString() => '''
GridStructureAnalysis(
  horizontal: $horizontalCount, vertical: $verticalCount,
  orientationRatio: ${orientationRatio.toStringAsFixed(2)},
  totalIntersections: $totalIntersections,
  spineWord: ${spineWordAnswer ?? 'none'}, spineRatio: ${(spineIntersectionRatio * 100).toStringAsFixed(1)}%,
  isolatedWords: $isolatedWordCount,
  minIntersections: $minIntersectionsPerWord
)''';
}
