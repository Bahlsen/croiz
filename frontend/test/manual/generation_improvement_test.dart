// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
// ignore_for_file: always_put_control_body_on_new_line, unnecessary_parenthesis
// This is a manual test script, not production code

import 'package:croiz/features/generation/services/grid_generator.dart';
import 'package:croiz/features/generation/models/generated_word.dart';

/// Script de test manuel pour valider les améliorations de l'algorithme
///
/// Usage: Exécutez ce fichier pour voir les statistiques
/// de génération avec les nouveaux paramètres.
void main() async {
  print('🧪 Test des Améliorations de Génération - Janvier 2026\n');
  print('=' * 60);

  // Simuler des mots générés (en production, ils viennent de Gemini)
  final testWords = _generateTestWords();

  print('\n📊 Configuration:');
  print('  - Mots disponibles: ${testWords.length}');
  print('  - Grille: 15×15 (225 cases)');
  print('  - Tentatives de restart: 150');
  print('  - Passes de raffinement: 7');

  print('\n🔄 Génération en cours...\n');

  final generator = GridGenerator(width: 15, height: 15);
  final placed = generator.generate(testWords, language: 'fr');

  // Calculer les statistiques
  final stats = _calculateStatistics(placed, 15, 15);

  print('✅ Résultats:\n');
  print('  📝 Mots placés: ${stats['wordsPlaced']} / ${testWords.length}');
  print('     Taux de placement: ${stats['placementRate']}%');
  print('');
  print('  📐 Grille:');
  print(
    '     Bounding box: ${stats['boundingWidth']}×${stats['boundingHeight']}',
  );
  print('     Cases remplies: ${stats['filledCells']}');
  print('     Densité: ${stats['density']}%');
  print('');
  print(
    '  ⬛ Cases noires: ${stats['blackSquares']} (${stats['blackSquarePercent']}%)',
  );
  print('');
  print('  🔗 Intersections:');
  print('     Total: ${stats['totalIntersections']}');
  print('     Par mot (moyenne): ${stats['intersectionsPerWord']}');
  print('');
  print('  📏 Longueurs de mots:');
  print('     Moyenne: ${stats['avgWordLength']} lettres');
  print('     Min: ${stats['minWordLength']}, Max: ${stats['maxWordLength']}');

  print('\n' + '=' * 60);
  print('\n🎯 Objectifs vs Résultats:\n');

  _printComparison('Mots placés', '≥20', stats['wordsPlaced']);
  _printComparison('Densité', '≥75%', stats['density'], suffix: '%');
  _printComparison(
    'Cases noires',
    '≤32%',
    stats['blackSquarePercent'],
    suffix: '%',
    inverse: true,
  );

  print('\n' + '=' * 60);
}

List<GeneratedWord> _generateTestWords() {
  // Simuler 40 mots de différentes longueurs (comme Gemini générerait)
  final words = [
    // Mots courts (3-5 lettres) - 40%
    'CHAT', 'PAIN', 'LUNE', 'VENT', 'PEUR', 'JOIE', 'REVE', 'PAIX',
    'FLEUR', 'ARBRE', 'SOLEIL', 'TERRE', 'OCEAN', 'NUAGE',

    // Mots moyens (6-8 lettres) - 40%
    'MAISON', 'JARDIN', 'FENETRE', 'LUMIERE', 'MUSIQUE', 'HISTOIRE',
    'SCIENCE', 'CULTURE', 'NATURE', 'VOYAGE', 'MONTAGNE', 'RIVIERE',
    'ETOILE', 'PLANETE',

    // Mots longs (9-15 lettres) - 20%
    'ORDINATEUR', 'TELEPHONE', 'UNIVERSITE', 'BIBLIOTHEQUE',
    'MATHEMATIQUE', 'PHILOSOPHIE', 'ARCHITECTURE', 'PHOTOGRAPHIE',
  ];

  return words
      .map((word) => GeneratedWord(answer: word, clue: 'Indice pour $word'))
      .toList();
}

Map<String, dynamic> _calculateStatistics(
  List<PlacedWord> placed,
  int gridWidth,
  int gridHeight,
) {
  if (placed.isEmpty) {
    return {
      'wordsPlaced': 0,
      'placementRate': 0.0,
      'boundingWidth': 0,
      'boundingHeight': 0,
      'filledCells': 0,
      'density': 0.0,
      'blackSquares': gridWidth * gridHeight,
      'blackSquarePercent': 100.0,
      'totalIntersections': 0,
      'intersectionsPerWord': 0.0,
      'avgWordLength': 0.0,
      'minWordLength': 0,
      'maxWordLength': 0,
    };
  }

  // Calculer le bounding box
  var minX = gridWidth;
  var maxX = 0;
  var minY = gridHeight;
  var maxY = 0;
  final cellSet = <String>{};

  for (final pw in placed) {
    for (var i = 0; i < pw.word.answer.length; i++) {
      final x = pw.isHorizontal ? pw.startX + i : pw.startX;
      final y = pw.isHorizontal ? pw.startY : pw.startY + i;

      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;

      cellSet.add('$x,$y');
    }
  }

  final boundingWidth = maxX - minX + 1;
  final boundingHeight = maxY - minY + 1;
  final boundingArea = boundingWidth * boundingHeight;
  final filledCells = cellSet.length;
  final density = (filledCells / boundingArea * 100);

  final totalGridCells = gridWidth * gridHeight;
  final blackSquares = totalGridCells - filledCells;
  final blackSquarePercent = (blackSquares / totalGridCells * 100);

  // Compter les intersections (approximation)
  var totalIntersections = 0;
  // Chaque mot après le premier a au moins 1 intersection
  totalIntersections = placed.length - 1;
  totalIntersections = totalIntersections.clamp(0, 999);

  final intersectionsPerWord =
      placed.length > 1 ? totalIntersections / (placed.length - 1) : 0.0;

  // Statistiques de longueur
  final lengths = placed.map((pw) => pw.word.answer.length).toList();
  final avgWordLength = lengths.reduce((a, b) => a + b) / lengths.length;
  final minWordLength = lengths.reduce((a, b) => a < b ? a : b);
  final maxWordLength = lengths.reduce((a, b) => a > b ? a : b);

  return {
    'wordsPlaced': placed.length,
    'placementRate': (placed.length / 40 * 100).toStringAsFixed(1),
    'boundingWidth': boundingWidth,
    'boundingHeight': boundingHeight,
    'filledCells': filledCells,
    'density': density.toStringAsFixed(1),
    'blackSquares': blackSquares,
    'blackSquarePercent': blackSquarePercent.toStringAsFixed(1),
    'totalIntersections': totalIntersections,
    'intersectionsPerWord': intersectionsPerWord.toStringAsFixed(2),
    'avgWordLength': avgWordLength.toStringAsFixed(1),
    'minWordLength': minWordLength,
    'maxWordLength': maxWordLength,
  };
}

void _printComparison(
  String metric,
  String target,
  dynamic actual, {
  String suffix = '',
  bool inverse = false,
}) {
  final actualStr = '$actual$suffix';
  final targetNum = double.tryParse(target.replaceAll(RegExp(r'[^0-9.]'), ''));
  final actualNum = double.tryParse(actual.toString());

  String status;
  if (targetNum != null && actualNum != null) {
    final isGood = inverse ? actualNum <= targetNum : actualNum >= targetNum;
    status = isGood ? '✅' : '⚠️';
  } else {
    status = '❓';
  }

  print('  $status $metric: $actualStr (objectif: $target)');
}
