// ignore_for_file: avoid_print

import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/fill_dictionary_service.dart';

import 'package:croiz/features/generation/services/grid_first_generator.dart';
import 'package:flutter_test/flutter_test.dart';

/// AI-simulated integration test for crossword generation.
///
/// Uses pre-generated word lists (simulating Gemini) to test the generation
/// algorithm without needing the real API.
///
/// Run with:
/// ```
/// flutter test integration_test/generation_simulated_test.dart
/// ```
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // AI-generated word lists per topic (simulating Gemini responses)
  final topicWords = <String, List<GeneratedWord>>{
    'Butter': [
      const GeneratedWord(answer: 'BUTTER', clue: 'Dairy spread'),
      const GeneratedWord(answer: 'CREAM', clue: 'Whipped dairy product'),
      const GeneratedWord(answer: 'MILK', clue: 'White liquid from cows'),
      const GeneratedWord(answer: 'CHURN', clue: 'Device for making butter'),
      const GeneratedWord(answer: 'DAIRY', clue: 'Farm producing milk'),
      const GeneratedWord(answer: 'FAT', clue: 'Lipid component'),
      const GeneratedWord(answer: 'SPREAD', clue: 'To apply thinly'),
      const GeneratedWord(answer: 'TOAST', clue: 'Bread for buttering'),
      const GeneratedWord(answer: 'MELT', clue: 'Become liquid'),
      const GeneratedWord(answer: 'SALT', clue: 'Often added seasoning'),
      const GeneratedWord(answer: 'UNSALTED', clue: 'Without sodium'),
      const GeneratedWord(answer: 'CULTURED', clue: 'Made with bacteria'),
      const GeneratedWord(answer: 'ORGANIC', clue: 'Naturally produced'),
      const GeneratedWord(answer: 'FARM', clue: 'Where cows live'),
      const GeneratedWord(answer: 'COW', clue: 'Milk-producing animal'),
      const GeneratedWord(answer: 'PASTEURIZED', clue: 'Heat-treated'),
      const GeneratedWord(answer: 'YELLOW', clue: 'Butter color'),
      const GeneratedWord(answer: 'RICH', clue: 'Full of flavor'),
      const GeneratedWord(answer: 'SMOOTH', clue: 'Texture quality'),
      const GeneratedWord(answer: 'WHIP', clue: 'Beat vigorously'),
      const GeneratedWord(answer: 'BLEND', clue: 'Mix together'),
      const GeneratedWord(answer: 'SOFT', clue: 'Room temperature state'),
      const GeneratedWord(answer: 'GOLDEN', clue: 'Warm color'),
      const GeneratedWord(answer: 'PURE', clue: 'Unadulterated'),
      const GeneratedWord(answer: 'FRESH', clue: 'Recently made'),
      const GeneratedWord(answer: 'NATURAL', clue: 'Without additives'),
      const GeneratedWord(answer: 'BAKING', clue: 'Oven cooking method'),
      const GeneratedWord(answer: 'RECIPE', clue: 'Cooking instructions'),
      const GeneratedWord(answer: 'INGREDIENT', clue: 'Recipe component'),
      const GeneratedWord(answer: 'CUISINE', clue: 'Style of cooking'),
      const GeneratedWord(answer: 'FOOD', clue: 'What we eat'),
      const GeneratedWord(answer: 'TASTE', clue: 'Flavor sensation'),
      const GeneratedWord(answer: 'DELICIOUS', clue: 'Very tasty'),
      const GeneratedWord(answer: 'CREAMY', clue: 'Smooth texture'),
      const GeneratedWord(answer: 'EUROPEAN', clue: 'Continental style'),
      const GeneratedWord(answer: 'ARTISAN', clue: 'Handcrafted'),
      const GeneratedWord(answer: 'PREMIUM', clue: 'High quality'),
      const GeneratedWord(answer: 'GRASS', clue: 'Cow food'),
      const GeneratedWord(answer: 'PASTURE', clue: 'Grazing field'),
      const GeneratedWord(answer: 'CONTAINER', clue: 'Storage vessel'),
    ],
    'Coffee': [
      const GeneratedWord(answer: 'COFFEE', clue: 'Popular caffeine drink'),
      const GeneratedWord(answer: 'ESPRESSO', clue: 'Strong Italian brew'),
      const GeneratedWord(answer: 'LATTE', clue: 'Milk-based coffee'),
      const GeneratedWord(answer: 'CAPPUCCINO', clue: 'Foamy coffee drink'),
      const GeneratedWord(answer: 'MOCHA', clue: 'Chocolate coffee'),
      const GeneratedWord(answer: 'ARABICA', clue: 'Popular bean variety'),
      const GeneratedWord(answer: 'ROBUSTA', clue: 'Strong bean variety'),
      const GeneratedWord(answer: 'BREW', clue: 'To make coffee'),
      const GeneratedWord(answer: 'GRIND', clue: 'Crush beans'),
      const GeneratedWord(answer: 'ROAST', clue: 'Heat beans'),
      const GeneratedWord(answer: 'BEAN', clue: 'Coffee seed'),
      const GeneratedWord(answer: 'CUP', clue: 'Drinking vessel'),
      const GeneratedWord(answer: 'MUG', clue: 'Large cup'),
      const GeneratedWord(answer: 'CAFFEINE', clue: 'Stimulant compound'),
      const GeneratedWord(answer: 'BARISTA', clue: 'Coffee maker'),
      const GeneratedWord(answer: 'CAFE', clue: 'Coffee shop'),
      const GeneratedWord(answer: 'FILTER', clue: 'Brewing tool'),
      const GeneratedWord(answer: 'DRIP', clue: 'Brewing method'),
      const GeneratedWord(answer: 'STEAM', clue: 'Hot vapor'),
      const GeneratedWord(answer: 'FOAM', clue: 'Milk bubbles'),
      const GeneratedWord(answer: 'CREAM', clue: 'Dairy additive'),
      const GeneratedWord(answer: 'SUGAR', clue: 'Sweetener'),
      const GeneratedWord(answer: 'AROMA', clue: 'Pleasant smell'),
      const GeneratedWord(answer: 'FLAVOR', clue: 'Taste sensation'),
      const GeneratedWord(answer: 'BOLD', clue: 'Strong taste'),
      const GeneratedWord(answer: 'MILD', clue: 'Gentle flavor'),
      const GeneratedWord(answer: 'DARK', clue: 'Heavy roast'),
      const GeneratedWord(answer: 'LIGHT', clue: 'Gentle roast'),
      const GeneratedWord(answer: 'MORNING', clue: 'Coffee time'),
      const GeneratedWord(answer: 'WAKE', clue: 'Become alert'),
      const GeneratedWord(answer: 'ENERGY', clue: 'Power boost'),
      const GeneratedWord(answer: 'HOT', clue: 'Temperature'),
      const GeneratedWord(answer: 'ICED', clue: 'Cold style'),
      const GeneratedWord(answer: 'BLACK', clue: 'No additions'),
      const GeneratedWord(answer: 'DECAF', clue: 'No caffeine'),
      const GeneratedWord(answer: 'ORGANIC', clue: 'Natural'),
      const GeneratedWord(answer: 'FAIR', clue: 'Trade type'),
      const GeneratedWord(answer: 'INSTANT', clue: 'Quick dissolving'),
      const GeneratedWord(answer: 'FRENCH', clue: 'Press type'),
      const GeneratedWord(answer: 'ITALIAN', clue: 'Espresso origin'),
    ],
    'Music': [
      const GeneratedWord(answer: 'MUSIC', clue: 'Art of sound'),
      const GeneratedWord(answer: 'MELODY', clue: 'Tune sequence'),
      const GeneratedWord(answer: 'RHYTHM', clue: 'Beat pattern'),
      const GeneratedWord(answer: 'HARMONY', clue: 'Chord blend'),
      const GeneratedWord(answer: 'SONG', clue: 'Musical piece'),
      const GeneratedWord(answer: 'LYRICS', clue: 'Song words'),
      const GeneratedWord(answer: 'GUITAR', clue: 'String instrument'),
      const GeneratedWord(answer: 'PIANO', clue: 'Keyboard instrument'),
      const GeneratedWord(answer: 'DRUM', clue: 'Percussion'),
      const GeneratedWord(answer: 'VIOLIN', clue: 'Bowed strings'),
      const GeneratedWord(answer: 'BASS', clue: 'Low frequency'),
      const GeneratedWord(answer: 'SINGER', clue: 'Vocalist'),
      const GeneratedWord(answer: 'BAND', clue: 'Musical group'),
      const GeneratedWord(answer: 'CONCERT', clue: 'Live performance'),
      const GeneratedWord(answer: 'ALBUM', clue: 'Song collection'),
      const GeneratedWord(answer: 'TRACK', clue: 'Single recording'),
      const GeneratedWord(answer: 'NOTE', clue: 'Musical pitch'),
      const GeneratedWord(answer: 'CHORD', clue: 'Note combination'),
      const GeneratedWord(answer: 'SCALE', clue: 'Note sequence'),
      const GeneratedWord(answer: 'TEMPO', clue: 'Speed'),
      const GeneratedWord(answer: 'BEAT', clue: 'Rhythmic unit'),
      const GeneratedWord(answer: 'TONE', clue: 'Sound quality'),
      const GeneratedWord(answer: 'PITCH', clue: 'Note height'),
      const GeneratedWord(answer: 'VOLUME', clue: 'Loudness'),
      const GeneratedWord(answer: 'LOUD', clue: 'High volume'),
      const GeneratedWord(answer: 'SOFT', clue: 'Quiet'),
      const GeneratedWord(answer: 'ROCK', clue: 'Music genre'),
      const GeneratedWord(answer: 'JAZZ', clue: 'Improvised genre'),
      const GeneratedWord(answer: 'POP', clue: 'Popular music'),
      const GeneratedWord(answer: 'CLASSICAL', clue: 'Traditional style'),
      const GeneratedWord(answer: 'BLUES', clue: 'Soulful genre'),
      const GeneratedWord(answer: 'FOLK', clue: 'Traditional songs'),
      const GeneratedWord(answer: 'OPERA', clue: 'Dramatic singing'),
      const GeneratedWord(answer: 'ORCHESTRA', clue: 'Large ensemble'),
      const GeneratedWord(answer: 'COMPOSER', clue: 'Music writer'),
      const GeneratedWord(answer: 'ARTIST', clue: 'Performer'),
      const GeneratedWord(answer: 'STUDIO', clue: 'Recording space'),
      const GeneratedWord(answer: 'LIVE', clue: 'Real-time'),
      const GeneratedWord(answer: 'DANCE', clue: 'Move to music'),
      const GeneratedWord(answer: 'LISTEN', clue: 'Hear attentively'),
    ],
    'Science': [
      const GeneratedWord(answer: 'SCIENCE', clue: 'Systematic study'),
      const GeneratedWord(answer: 'EXPERIMENT', clue: 'Test procedure'),
      const GeneratedWord(answer: 'HYPOTHESIS', clue: 'Educated guess'),
      const GeneratedWord(answer: 'THEORY', clue: 'Explanation'),
      const GeneratedWord(answer: 'LAB', clue: 'Research room'),
      const GeneratedWord(answer: 'DATA', clue: 'Information'),
      const GeneratedWord(answer: 'RESEARCH', clue: 'Investigation'),
      const GeneratedWord(answer: 'ANALYZE', clue: 'Examine'),
      const GeneratedWord(answer: 'MOLECULE', clue: 'Atom group'),
      const GeneratedWord(answer: 'ATOM', clue: 'Smallest unit'),
      const GeneratedWord(answer: 'CELL', clue: 'Life unit'),
      const GeneratedWord(answer: 'DNA', clue: 'Genetic code'),
      const GeneratedWord(answer: 'GENE', clue: 'Heredity unit'),
      const GeneratedWord(answer: 'EVOLUTION', clue: 'Species change'),
      const GeneratedWord(answer: 'PHYSICS', clue: 'Matter study'),
      const GeneratedWord(answer: 'CHEMISTRY', clue: 'Substance study'),
      const GeneratedWord(answer: 'BIOLOGY', clue: 'Life study'),
      const GeneratedWord(answer: 'FORMULA', clue: 'Mathematical rule'),
      const GeneratedWord(answer: 'EQUATION', clue: 'Math statement'),
      const GeneratedWord(answer: 'PROOF', clue: 'Verification'),
      const GeneratedWord(answer: 'DISCOVER', clue: 'Find new'),
      const GeneratedWord(answer: 'INVENT', clue: 'Create new'),
      const GeneratedWord(answer: 'ELEMENT', clue: 'Pure substance'),
      const GeneratedWord(answer: 'ENERGY', clue: 'Work capacity'),
      const GeneratedWord(answer: 'FORCE', clue: 'Push or pull'),
      const GeneratedWord(answer: 'MASS', clue: 'Amount of matter'),
      const GeneratedWord(answer: 'GRAVITY', clue: 'Attraction force'),
      const GeneratedWord(answer: 'LIGHT', clue: 'Electromagnetic wave'),
      const GeneratedWord(answer: 'SOUND', clue: 'Acoustic wave'),
      const GeneratedWord(answer: 'HEAT', clue: 'Thermal energy'),
      const GeneratedWord(answer: 'ELECTRIC', clue: 'Charge-based'),
      const GeneratedWord(answer: 'MAGNETIC', clue: 'Attraction property'),
      const GeneratedWord(answer: 'QUANTUM', clue: 'Smallest discrete'),
      const GeneratedWord(answer: 'NUCLEAR', clue: 'Atom core related'),
      const GeneratedWord(answer: 'TELESCOPE', clue: 'Star viewer'),
      const GeneratedWord(answer: 'MICROSCOPE', clue: 'Small viewer'),
      const GeneratedWord(answer: 'SCIENTIST', clue: 'Researcher'),
      const GeneratedWord(answer: 'STUDY', clue: 'Learn deeply'),
      const GeneratedWord(answer: 'TEST', clue: 'Verify'),
      const GeneratedWord(answer: 'OBSERVE', clue: 'Watch carefully'),
    ],
  };

  group('Simulated Generation Tests (AI as Gemini)', () {
    test('Analyze fill dictionary coverage', () async {
      print('\n${'=' * 70}');
      print('📚 FILL DICTIONARY ANALYSIS');
      print('=' * 70);

      final fillService = FillDictionaryService.instance;
      final words = await fillService.loadDictionary('en');

      final byLength = <int, int>{};
      for (final word in words) {
        byLength[word.length] = (byLength[word.length] ?? 0) + 1;
      }

      print('\nTotal words: ${words.length}');
      print('\nDistribution by length:');
      final sortedLengths = byLength.keys.toList()..sort();
      for (final len in sortedLengths) {
        final count = byLength[len]!;
        final bar = '█' * (count ~/ 50).clamp(0, 40);
        print(
          '  Length ${len.toString().padLeft(2)}: ${count.toString().padLeft(5)} $bar',
        );
      }

      // Identify gaps
      print('\n⚠️  Coverage issues:');
      for (var len = 3; len <= 15; len++) {
        final count = byLength[len] ?? 0;
        if (count < 100) {
          print('   Length $len: Only $count words (recommend 100+)');
        }
      }

      expect(words.length, greaterThan(1000));
    });

    for (final topic in ['Butter', 'Coffee', 'Music', 'Science']) {
      for (final size in [15, 20]) {
        test('Generate "$topic" ${size}x$size', () async {
          print('\n${'=' * 70}');
          print('🎯 GENERATION TEST: "$topic" ${size}x$size');
          print('=' * 70);

          final themeWords = topicWords[topic]!;
          print('\n📝 Theme words: ${themeWords.length}');
          print(
            '   Examples: ${themeWords.take(5).map((w) => w.answer).join(", ")}',
          );

          // Load fill dictionary
          final fillService = FillDictionaryService.instance;
          final fillWords = await fillService.loadDictionary('en');
          print('\n📚 Fill dictionary: ${fillWords.length} words');

          // Run multiple attempts
          const attempts = 5;
          final results = <Map<String, dynamic>>[];

          for (var i = 1; i <= attempts; i++) {
            print('\n--- Attempt $i/$attempts ---');

            final stopwatch = Stopwatch()..start();
            final generator = GridFirstGenerator(
              width: size,
              height: size,
              targetBlackRatio: 0.18,
              maxAttempts: 50,
            );

            final result = generator.generate(
              themeWords: themeWords,
              fillWords: fillWords,
            );
            final timeMs = stopwatch.elapsedMilliseconds;

            final totalCells = size * size;
            final blackCells =
                result.template
                    .expand((row) => row)
                    .where((cell) => cell)
                    .length;
            final filledCells =
                result.grid
                    .expand((row) => row)
                    .where((cell) => cell != null)
                    .length;
            final density = filledCells / totalCells;

            results.add({
              'words': result.placedWords.length,
              'density': density,
              'blackRatio': blackCells / totalCells,
              'emptyWhite':
                  (totalCells - blackCells - filledCells) / totalCells,
              'success': result.success,
              'timeMs': timeMs,
            });

            print(
              '   Words: ${result.placedWords.length}, '
              'Density: ${(density * 100).toStringAsFixed(1)}%, '
              'Time: ${timeMs}ms, '
              'Success: ${result.success}',
            );
          }

          // Summary
          print('\n📊 SUMMARY ($attempts attempts):');
          final avgWords =
              results.map((r) => r['words'] as int).reduce((a, b) => a + b) /
              attempts;
          final avgDensity =
              results
                  .map((r) => r['density'] as double)
                  .reduce((a, b) => a + b) /
              attempts;
          final avgTime =
              results.map((r) => r['timeMs'] as int).reduce((a, b) => a + b) /
              attempts;
          final successRate =
              results.where((r) => r['success'] as bool).length / attempts;

          print('   Avg words placed: ${avgWords.toStringAsFixed(1)}');
          print('   Avg density: ${(avgDensity * 100).toStringAsFixed(1)}%');
          print('   Avg time: ${avgTime.toStringAsFixed(0)}ms');
          print('   Success rate: ${(successRate * 100).toStringAsFixed(0)}%');

          // Expectations
          expect(
            avgWords,
            greaterThan(5),
            reason: 'Should place 5+ words on average',
          );
          expect(
            avgDensity,
            greaterThan(0.25),
            reason: 'Density should be 25%+',
          );
        });
      }
    }
  });

  group('Slot Length Analysis', () {
    test('Analyze slot length distribution vs dictionary', () async {
      print('\n${'=' * 70}');
      print('🔍 SLOT LENGTH ANALYSIS');
      print('=' * 70);

      final fillService = FillDictionaryService.instance;
      final fillWords = await fillService.loadDictionary('en');

      // Build dictionary coverage
      final dictByLength = <int, int>{};
      for (final word in fillWords) {
        dictByLength[word.length] = (dictByLength[word.length] ?? 0) + 1;
      }

      // Generate a template and analyze slots
      for (final size in [15, 20, 25]) {
        print('\n📏 Grid size: ${size}x$size');

        final generator = GridFirstGenerator(
          width: size,
          height: size,
          targetBlackRatio: 0.18,
        );

        final result = generator.generate(
          themeWords: topicWords['Butter']!,
          fillWords: fillWords,
        );

        // Count slots by length (approximate from placed words)
        final slotLengths = <int, int>{};
        for (final pw in result.placedWords) {
          final len = pw.word.answer.length;
          slotLengths[len] = (slotLengths[len] ?? 0) + 1;
        }

        print('   Filled slot lengths:');
        final sortedLengths = slotLengths.keys.toList()..sort();
        for (final len in sortedLengths) {
          final slotCount = slotLengths[len]!;
          final dictCount = dictByLength[len] ?? 0;
          print('     Length $len: $slotCount slots, $dictCount dict words');
        }
      }

      expect(true, isTrue);
    });
  });
}
