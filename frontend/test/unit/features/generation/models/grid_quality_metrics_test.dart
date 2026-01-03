import 'package:croiz/features/generation/models/grid_quality_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GridQualityMetrics', () {
    test('should calculate placement rate correctly', () {
      const metrics = GridQualityMetrics(
        wordsPlaced: 15,
        totalWords: 30,
        letterDensity: 0.75,
        blackSquareRatio: 0.25,
        rowCoverage: 0.9,
        columnCoverage: 0.85,
        totalIntersections: 20,
        avgIntersectionsPerWord: 1.33,
        filledCells: 150,
        totalCells: 225,
        boundingWidth: 15,
        boundingHeight: 15,
      );

      expect(metrics.placementRate, 0.5);
    });

    test('should detect quality thresholds met', () {
      const goodMetrics = GridQualityMetrics(
        wordsPlaced: 25,
        totalWords: 30,
        letterDensity: 0.85,
        blackSquareRatio: 0.15,
        rowCoverage: 0.95,
        columnCoverage: 0.92,
        totalIntersections: 60,
        avgIntersectionsPerWord: 2.4,
        filledCells: 180,
        totalCells: 225,
        boundingWidth: 15,
        boundingHeight: 15,
      );

      expect(goodMetrics.meetsQualityThresholds, true);
    });

    test('should detect quality thresholds not met', () {
      const badMetrics = GridQualityMetrics(
        wordsPlaced: 10,
        totalWords: 30,
        letterDensity: 0.45,
        blackSquareRatio: 0.55,
        rowCoverage: 0.25,
        columnCoverage: 0.30,
        totalIntersections: 8,
        avgIntersectionsPerWord: 0.8,
        filledCells: 80,
        totalCells: 225,
        boundingWidth: 12,
        boundingHeight: 10,
      );

      expect(badMetrics.meetsQualityThresholds, false);
    });

    test('should detect viability', () {
      const viableMetrics = GridQualityMetrics(
        wordsPlaced: 12,
        totalWords: 30,
        letterDensity: 0.40,
        blackSquareRatio: 0.60,
        rowCoverage: 0.40,
        columnCoverage: 0.45,
        totalIntersections: 10,
        avgIntersectionsPerWord: 0.83,
        filledCells: 90,
        totalCells: 225,
        boundingWidth: 15,
        boundingHeight: 15,
      );

      expect(viableMetrics.isViable, true);
    });

    test('should detect non-viability with too few words', () {
      const nonViableMetrics = GridQualityMetrics(
        wordsPlaced: 5,
        totalWords: 30,
        letterDensity: 0.30,
        blackSquareRatio: 0.70,
        rowCoverage: 0.15,
        columnCoverage: 0.20,
        totalIntersections: 4,
        avgIntersectionsPerWord: 0.8,
        filledCells: 40,
        totalCells: 225,
        boundingWidth: 10,
        boundingHeight: 8,
      );

      expect(nonViableMetrics.isViable, false);
    });

    test('should handle zero words gracefully', () {
      const emptyMetrics = GridQualityMetrics(
        wordsPlaced: 0,
        totalWords: 30,
        letterDensity: 0,
        blackSquareRatio: 1,
        rowCoverage: 0,
        columnCoverage: 0,
        totalIntersections: 0,
        avgIntersectionsPerWord: 0,
        filledCells: 0,
        totalCells: 225,
        boundingWidth: 0,
        boundingHeight: 0,
      );

      expect(emptyMetrics.placementRate, 0);
      expect(emptyMetrics.isViable, false);
    });

    test('copyWith should create a copy with modified values', () {
      const original = GridQualityMetrics(
        wordsPlaced: 10,
        totalWords: 20,
        letterDensity: 0.5,
        blackSquareRatio: 0.5,
        rowCoverage: 0.5,
        columnCoverage: 0.5,
        totalIntersections: 10,
        avgIntersectionsPerWord: 1,
        filledCells: 100,
        totalCells: 200,
        boundingWidth: 10,
        boundingHeight: 10,
      );

      final modified = original.copyWith(wordsPlaced: 20, rowCoverage: 0.9);

      expect(modified.wordsPlaced, 20);
      expect(modified.rowCoverage, 0.9);
      expect(modified.totalWords, 20); // Unchanged
      expect(modified.letterDensity, 0.5); // Unchanged
    });

    test('toString should return readable format', () {
      const metrics = GridQualityMetrics(
        wordsPlaced: 15,
        totalWords: 30,
        letterDensity: 0.75,
        blackSquareRatio: 0.25,
        rowCoverage: 0.9,
        columnCoverage: 0.85,
        totalIntersections: 20,
        avgIntersectionsPerWord: 1.33,
        filledCells: 150,
        totalCells: 225,
        boundingWidth: 15,
        boundingHeight: 15,
      );

      final str = metrics.toString();
      expect(str, contains('wordsPlaced'));
      expect(str, contains('letterDensity'));
      expect(str, contains('meetsQualityThresholds'));
    });
  });
}
