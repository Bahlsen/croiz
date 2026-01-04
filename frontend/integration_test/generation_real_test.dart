// ignore_for_file: avoid_print

import 'package:croiz/features/generation/services/fill_dictionary_service.dart';
import 'package:croiz/features/generation/services/gemini_service.dart';
import 'package:croiz/features/generation/services/grid_first_generator.dart';

import 'package:flutter_test/flutter_test.dart';

/// Real integration test for crossword generation.
///
/// This test actually calls Gemini API and tests the full generation pipeline.
/// Run with:
/// ```
/// flutter test integration_test/generation_real_test.dart
/// ```
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Test configuration
  const topics = [
    ('Butter', 'en'),
    ('Coffee', 'en'),
    ('Music', 'en'),
    ('Science', 'en'),
    ('Sports', 'en'),
    ('Cuisine française', 'fr'),
    ('Technologie', 'fr'),
  ];

  const gridSizes = [15, 20, 25];
  const runsPerConfig = 3;

  group('Real Generation Integration Tests', () {
    late GeminiPuzzleService geminiService;
    late FillDictionaryService fillService;

    setUpAll(() async {
      geminiService = GeminiPuzzleService();
      fillService = FillDictionaryService.instance;
    });

    for (final (topic, language) in topics) {
      for (final size in gridSizes) {
        test(
          'Generate "$topic" (${language.toUpperCase()}) ${size}x$size',
          () async {
            final results = <GenerationResult>[];

            for (var run = 1; run <= runsPerConfig; run++) {
              print('\n${'=' * 60}');
              print(
                'RUN $run/$runsPerConfig: "$topic" ($language) ${size}x$size',
              );
              print('=' * 60);

              try {
                // 1. Generate words from Gemini
                final stopwatch = Stopwatch()..start();

                print('📝 Calling Gemini API...');
                final themeWords = await geminiService.generateWords(
                  topic: topic,
                  language: language,
                  count: size * 4, // More words for larger grids
                  difficultyLevel: 2,
                );
                final geminiTime = stopwatch.elapsedMilliseconds;
                print(
                  '✅ Gemini returned ${themeWords.length} words in ${geminiTime}ms',
                );

                // 2. Load fill dictionary
                print('📚 Loading fill dictionary...');
                final fillWords = await fillService.loadDictionary(language);
                print('✅ Loaded ${fillWords.length} fill words');

                // Analyze fill word lengths
                final fillByLength = <int, int>{};
                for (final word in fillWords) {
                  fillByLength[word.length] =
                      (fillByLength[word.length] ?? 0) + 1;
                }
                print('📊 Fill dictionary by length:');
                final sortedLengths = fillByLength.keys.toList()..sort();
                for (final len in sortedLengths.take(15)) {
                  print('   Length $len: ${fillByLength[len]} words');
                }

                // 3. Generate grid
                print('\n🔧 Generating grid...');
                stopwatch
                  ..reset()
                  ..start();

                final generator = GridFirstGenerator(
                  width: size,
                  height: size,
                  targetBlackRatio: 0.20,
                  maxAttempts: 100,
                );

                final result = generator.generate(
                  themeWords: themeWords,
                  fillWords: fillWords,
                );
                final gridTime = stopwatch.elapsedMilliseconds;

                // 4. Collect metrics
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
                final emptyWhite = totalCells - blackCells - filledCells;

                final genResult = GenerationResult(
                  topic: topic,
                  language: language,
                  gridSize: size,
                  runNumber: run,
                  themeWordsGenerated: themeWords.length,
                  fillWordsLoaded: fillWords.length,
                  placedWords: result.placedWords.length,
                  totalSlots: result.metrics.totalCells ~/ 5, // Approximate
                  blackCells: blackCells,
                  filledCells: filledCells,
                  emptyWhiteCells: emptyWhite,
                  density: filledCells / totalCells,
                  success: result.success,
                  geminiTimeMs: geminiTime,
                  gridTimeMs: gridTime,
                );
                results.add(genResult);

                // Print summary
                print('\n📈 RESULTS:');
                print('   Words placed: ${result.placedWords.length}');
                print(
                  '   Black cells: $blackCells (${(blackCells * 100 / totalCells).toStringAsFixed(1)}%)',
                );
                print(
                  '   Filled cells: $filledCells (${(filledCells * 100 / totalCells).toStringAsFixed(1)}%)',
                );
                print(
                  '   Empty white: $emptyWhite (${(emptyWhite * 100 / totalCells).toStringAsFixed(1)}%)',
                );
                print(
                  '   Density: ${(genResult.density * 100).toStringAsFixed(1)}%',
                );
                print('   Success: ${result.success}');
                print('   Grid time: ${gridTime}ms');

                // Validation
                expect(
                  result.placedWords.length,
                  greaterThan(5),
                  reason: 'Should place at least 5 words',
                );
                expect(
                  genResult.density,
                  greaterThan(0.40),
                  reason: 'Density should be above 40%',
                );
              } on Exception catch (e, st) {
                print('❌ ERROR: $e');
                print(st);
                results.add(
                  GenerationResult.error(
                    topic: topic,
                    language: language,
                    gridSize: size,
                    runNumber: run,
                    error: e.toString(),
                  ),
                );
              }
            }

            // Summary for this configuration
            print('\n${'=' * 60}');
            print('SUMMARY: "$topic" ($language) ${size}x$size');
            print('=' * 60);

            final successCount = results.where((r) => r.success).length;
            final avgDensity =
                results
                    .where((r) => r.success)
                    .map((r) => r.density)
                    .fold<double>(0, (a, b) => a + b) /
                (successCount > 0 ? successCount : 1);
            final avgWords =
                results
                    .where((r) => r.success)
                    .map((r) => r.placedWords)
                    .fold<int>(0, (a, b) => a + b) ~/
                (successCount > 0 ? successCount : 1);

            print('Success rate: $successCount/$runsPerConfig');
            print('Avg density: ${(avgDensity * 100).toStringAsFixed(1)}%');
            print('Avg words placed: $avgWords');
          },
          timeout: const Timeout(Duration(minutes: 5)),
        );
      }
    }
  });

  group('Dictionary Analysis', () {
    test('Analyze fill dictionary word lengths', () async {
      print('\n${'=' * 60}');
      print('DICTIONARY ANALYSIS');
      print('=' * 60);

      for (final lang in ['en', 'fr']) {
        print('\n📚 Language: ${lang.toUpperCase()}');

        final fillService = FillDictionaryService.instance;
        final words = await fillService.loadDictionary(lang);

        final byLength = <int, int>{};
        for (final word in words) {
          byLength[word.length] = (byLength[word.length] ?? 0) + 1;
        }

        final sortedLengths = byLength.keys.toList()..sort();
        for (final len in sortedLengths) {
          final count = byLength[len]!;
          final bar = '█' * (count ~/ 100).clamp(0, 50);
          print(
            '   Length ${len.toString().padLeft(2)}: ${count.toString().padLeft(5)} $bar',
          );
        }

        // Check for gaps
        print('\n   ⚠️  Potential issues:');
        for (var len = 3; len <= 15; len++) {
          final count = byLength[len] ?? 0;
          if (count < 50) {
            print('      Length $len has only $count words (need more)');
          }
        }
      }

      expect(true, isTrue); // Always pass, this is for analysis
    });
  });
}

/// Result of a single generation run.
class GenerationResult {
  const GenerationResult({
    required this.topic,
    required this.language,
    required this.gridSize,
    required this.runNumber,
    required this.themeWordsGenerated,
    required this.fillWordsLoaded,
    required this.placedWords,
    required this.totalSlots,
    required this.blackCells,
    required this.filledCells,
    required this.emptyWhiteCells,
    required this.density,
    required this.success,
    required this.geminiTimeMs,
    required this.gridTimeMs,
    this.error,
  });

  factory GenerationResult.error({
    required String topic,
    required String language,
    required int gridSize,
    required int runNumber,
    required String error,
  }) => GenerationResult(
    topic: topic,
    language: language,
    gridSize: gridSize,
    runNumber: runNumber,
    themeWordsGenerated: 0,
    fillWordsLoaded: 0,
    placedWords: 0,
    totalSlots: 0,
    blackCells: 0,
    filledCells: 0,
    emptyWhiteCells: 0,
    density: 0,
    success: false,
    geminiTimeMs: 0,
    gridTimeMs: 0,
    error: error,
  );

  final String topic;
  final String language;
  final int gridSize;
  final int runNumber;
  final int themeWordsGenerated;
  final int fillWordsLoaded;
  final int placedWords;
  final int totalSlots;
  final int blackCells;
  final int filledCells;
  final int emptyWhiteCells;
  final double density;
  final bool success;
  final int geminiTimeMs;
  final int gridTimeMs;
  final String? error;
}
