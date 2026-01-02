import 'dart:math';

import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// A mix of English and French words for variety
const _wordBank = [
  'APPLE',
  'BANANA',
  'CHERRY',
  'DATE',
  'ELDERBERRY',
  'FIG',
  'GRAPE',
  'HONEYDEW',
  'KIWI',
  'LEMON',
  'MANGO',
  'NECTARINE',
  'ORANGE',
  'PAPAYA',
  'QUINCE',
  'RASPBERRY',
  'STRAWBERRY',
  'TANGERINE',
  'UGLI',
  'VANILLA',
  'WATERMELON',
  'XIGUA',
  'YAM',
  'ZUCCHINI',
  'MAISON',
  'CHAISE',
  'TABLE',
  'FENETRE',
  'PORTE',
  'TOIT',
  'JARDIN',
  'FLEUR',
  'ARBRE',
  'VOITURE',
  'ROUTE',
  'VILLE',
  'PAYS',
  'MONDE',
  'LUMIERE',
  'SOLEIL',
  'LUNE',
  'ETOILE',
  'CIEL',
  'NUAGE',
  'PLUIE',
  'NEIGE',
  'VENT',
  'ORAGE',
  'ECLAIR',
  'TONNERRE',
  'RIVIERE',
  'MER',
  'OCEAN',
  'MONTAGNE',
  'VALLEE',
  'FORET',
  'DESERT',
  'SABLE',
  'ROCHE',
  'PIERRE',
  'CAILLOU',
  'CHEMIN',
  'SENTIER',
  'RUE',
  'AVENUE',
  'PLACE',
  'PARC',
  'BANQUE',
  'ECOLE',
  'HOPITAL',
  'MAIRIE',
  'EGLISE',
  'GARE',
  'AEROPORT',
  'PORT',
  'USINE',
  'BUREAU',
  'MAGASIN',
  'MARCHE',
  'HOTEL',
  'RESTAURANT',
  'CAFE',
  'BAR',
  'CINEMA',
  'THEATRE',
  'MUSEE',
  'STADE',
  'PISCINE',
  'PLAGE',
  'VACANCES',
  'VOYAGE',
  'AVENTURE',
  'HISTOIRE',
  'MYSTERE',
  'SECRET',
  'TRESOR',
  'CARTE',
  'BOUSSOLE',
  'DIRECTON',
  'NORD',
  'SUD',
  'EST',
  'OUEST',
  'GAUCHE',
  'DROITE',
  'HAUT',
  'BAS',
];

void main() {
  group('GridGenerator Mass Test', () {
    test('run mass generation and report stats', () {
      final generator = GridGenerator(width: 20, height: 20);
      final random = Random(42); // Fixed seed for reproducibility

      // Accumulators for stats
      var totalInputWords = 0;
      var totalPlacedWords = 0;
      var totalFilledCells = 0;
      var totalBoundingBoxArea = 0;
      var totalIntersections = 0;
      const iterations = 50;

      debugPrint('Running $iterations iterations...');

      for (var i = 0; i < iterations; i++) {
        // Pick 20 random words
        const count = 20;
        final words = <GeneratedWord>[];
        for (var j = 0; j < count; j++) {
          final wordStr = _wordBank[random.nextInt(_wordBank.length)];
          words.add(GeneratedWord(answer: wordStr, clue: 'Clue for $wordStr'));
        }

        // Run generation
        final result = generator.generate(words);
        totalInputWords += count;
        totalPlacedWords += result.length;

        // Calculate metrics for this run
        if (result.isEmpty) {
          continue;
        }

        var minX = 20;
        var maxX = 0;
        var minY = 20;
        var maxY = 0;
        var filledCount = 0;

        // Create a temporary grid to count filled cells correctly
        // (handling overlap which is effectively shared cells)
        final tempGrid = List.generate(20, (_) => List<bool>.filled(20, false));

        for (final pw in result) {
          for (var k = 0; k < pw.word.answer.length; k++) {
            final x = pw.isHorizontal ? pw.startX + k : pw.startX;
            final y = pw.isHorizontal ? pw.startY : pw.startY + k;

            // Update bounding box
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

            // Mark filled
            if (!tempGrid[y][x]) {
              tempGrid[y][x] = true;
              filledCount++;
            }
          }
        }

        // Calculate approx intersections
        // (Sum of lengths - filledCount)
        final sumLengths = result.fold<int>(
          0,
          (p, e) => p + e.word.answer.length,
        );
        final intersections = sumLengths - filledCount;
        totalIntersections += intersections;

        totalFilledCells += filledCount;

        final width = maxX - minX + 1;
        final height = maxY - minY + 1;
        totalBoundingBoxArea += width * height;
      }

      final avgPlacedPct = (totalPlacedWords / totalInputWords) * 100;
      final avgFilledPerRun = totalFilledCells / iterations;
      final avgAreaPerRun = totalBoundingBoxArea / iterations;
      final avgDensity =
          avgAreaPerRun > 0 ? (avgFilledPerRun / avgAreaPerRun) : 0.0;
      final avgIntersections = totalIntersections / iterations;

      debugPrint('--- MASS TEST RESULTS ---');
      debugPrint('Iterations: $iterations');
      debugPrint(
        'Avg Words Placed: ${(totalPlacedWords / iterations).toStringAsFixed(1)} / ${(totalInputWords / iterations).toStringAsFixed(1)} ($avgPlacedPct%)',
      );
      debugPrint(
        'Avg Focused Density (Filled / BoundingBox): ${avgDensity.toStringAsFixed(2)}',
      );
      debugPrint('Avg Intersections: ${avgIntersections.toStringAsFixed(1)}');
      debugPrint('-------------------------');

      // Fail if performance is too bad (baseline check)
      // Current baseline approx: 20-30% words placed, density maybe 0.3
      // We want to improve this.
      expect(
        avgPlacedPct,
        greaterThan(10),
        reason: 'Placement rate is extremely low!',
      );
    });
  });
}
