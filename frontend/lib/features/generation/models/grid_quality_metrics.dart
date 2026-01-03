/// Quality metrics for evaluating crossword grid generation.
///
/// These metrics measure various aspects of grid quality including
/// density, coverage, and intersection ratios.
class GridQualityMetrics {
  const GridQualityMetrics({
    required this.wordsPlaced,
    required this.totalWords,
    required this.letterDensity,
    required this.blackSquareRatio,
    required this.rowCoverage,
    required this.columnCoverage,
    required this.totalIntersections,
    required this.avgIntersectionsPerWord,
    required this.filledCells,
    required this.totalCells,
    required this.boundingWidth,
    required this.boundingHeight,
  });

  /// Number of words successfully placed on the grid
  final int wordsPlaced;

  /// Total number of words attempted to place
  final int totalWords;

  /// Ratio of filled cells to bounding box area (0.0 to 1.0)
  final double letterDensity;

  /// Ratio of black (empty) cells to total grid cells (0.0 to 1.0)
  final double blackSquareRatio;

  /// Ratio of rows containing at least one horizontal word (0.0 to 1.0)
  final double rowCoverage;

  /// Ratio of columns containing at least one vertical word (0.0 to 1.0)
  final double columnCoverage;

  /// Total number of cell intersections in the grid
  final int totalIntersections;

  /// Average number of intersections per placed word
  final double avgIntersectionsPerWord;

  /// Number of cells filled with letters
  final int filledCells;

  /// Total cells in the grid (width × height)
  final int totalCells;

  /// Width of the bounding box containing all words
  final int boundingWidth;

  /// Height of the bounding box containing all words
  final int boundingHeight;

  /// Placement rate as percentage (0-100)
  double get placementRate => totalWords > 0 ? wordsPlaced / totalWords : 0.0;

  /// Check if metrics meet minimum quality thresholds
  bool get meetsQualityThresholds =>
      rowCoverage >= 0.90 &&
      columnCoverage >= 0.90 &&
      avgIntersectionsPerWord >= 2.0 &&
      blackSquareRatio <= 0.20;

  /// Check if metrics meet basic viability thresholds
  bool get isViable =>
      wordsPlaced >= 10 && letterDensity >= 0.35 && blackSquareRatio <= 0.65;

  @override
  String toString() => '''
GridQualityMetrics(
  wordsPlaced: $wordsPlaced / $totalWords (${(placementRate * 100).toStringAsFixed(1)}%)
  letterDensity: ${(letterDensity * 100).toStringAsFixed(1)}%
  blackSquareRatio: ${(blackSquareRatio * 100).toStringAsFixed(1)}%
  rowCoverage: ${(rowCoverage * 100).toStringAsFixed(1)}%
  columnCoverage: ${(columnCoverage * 100).toStringAsFixed(1)}%
  avgIntersectionsPerWord: ${avgIntersectionsPerWord.toStringAsFixed(2)}
  meetsQualityThresholds: $meetsQualityThresholds
)''';

  /// Create a copy with modified values
  GridQualityMetrics copyWith({
    int? wordsPlaced,
    int? totalWords,
    double? letterDensity,
    double? blackSquareRatio,
    double? rowCoverage,
    double? columnCoverage,
    int? totalIntersections,
    double? avgIntersectionsPerWord,
    int? filledCells,
    int? totalCells,
    int? boundingWidth,
    int? boundingHeight,
  }) => GridQualityMetrics(
    wordsPlaced: wordsPlaced ?? this.wordsPlaced,
    totalWords: totalWords ?? this.totalWords,
    letterDensity: letterDensity ?? this.letterDensity,
    blackSquareRatio: blackSquareRatio ?? this.blackSquareRatio,
    rowCoverage: rowCoverage ?? this.rowCoverage,
    columnCoverage: columnCoverage ?? this.columnCoverage,
    totalIntersections: totalIntersections ?? this.totalIntersections,
    avgIntersectionsPerWord:
        avgIntersectionsPerWord ?? this.avgIntersectionsPerWord,
    filledCells: filledCells ?? this.filledCells,
    totalCells: totalCells ?? this.totalCells,
    boundingWidth: boundingWidth ?? this.boundingWidth,
    boundingHeight: boundingHeight ?? this.boundingHeight,
  );
}
