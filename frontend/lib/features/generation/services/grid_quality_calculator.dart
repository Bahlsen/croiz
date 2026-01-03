import 'package:croiz/features/generation/models/grid_quality_metrics.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';

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
