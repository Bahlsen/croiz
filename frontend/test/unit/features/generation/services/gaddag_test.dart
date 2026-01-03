import 'package:croiz/features/generation/services/gaddag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gaddag', () {
    late Gaddag gaddag;

    setUp(() {
      gaddag = Gaddag();
    });

    group('build and containsWord', () {
      test('should build from word list', () {
        gaddag.build(['CAT', 'DOG', 'BIRD']);

        expect(gaddag.wordCount, 3);
        expect(gaddag.containsWord('CAT'), true);
        expect(gaddag.containsWord('DOG'), true);
        expect(gaddag.containsWord('BIRD'), true);
      });

      test('should be case insensitive', () {
        final gaddag = Gaddag()..build(['Hello', 'WORLD', 'test']);

        expect(gaddag.containsWord('HELLO'), true);
        expect(gaddag.containsWord('hello'), true);
        expect(gaddag.containsWord('HeLLo'), true);
      });

      test('should handle empty words', () {
        gaddag.build(['', 'CAT', '']);

        expect(gaddag.wordCount, 1);
        expect(gaddag.containsWord('CAT'), true);
      });

      test('should handle duplicate words', () {
        gaddag.build(['CAT', 'CAT', 'cat', 'CAT']);

        expect(gaddag.wordCount, 1);
      });
    });

    group('addWord', () {
      test('should add single word', () {
        gaddag.addWord('TEST');

        expect(gaddag.containsWord('TEST'), true);
        expect(gaddag.wordCount, 1);
      });

      test('should not add duplicate', () {
        gaddag
          ..addWord('TEST')
          ..addWord('TEST')
          ..addWord('test');

        expect(gaddag.wordCount, 1);
      });
    });

    group('findWordsByLength', () {
      test('should find words by length', () {
        gaddag.build(['CAT', 'DOG', 'BIRD', 'FISH', 'ELEPHANT']);

        final threeLetters = gaddag.findWordsByLength(3);
        final fourLetters = gaddag.findWordsByLength(4);
        final eightLetters = gaddag.findWordsByLength(8);

        expect(threeLetters.length, 2);
        expect(threeLetters, containsAll(['CAT', 'DOG']));
        expect(fourLetters.length, 2);
        expect(fourLetters, containsAll(['BIRD', 'FISH']));
        expect(eightLetters.length, 1);
        expect(eightLetters, contains('ELEPHANT'));
      });

      test('should return empty set for unknown length', () {
        gaddag.build(['CAT', 'DOG']);

        expect(gaddag.findWordsByLength(10), isEmpty);
      });
    });

    group('findMatches', () {
      test('should match pattern with wildcards', () {
        gaddag.build(['CAT', 'BAT', 'HAT', 'RAT', 'SAT', 'DOG']);

        final matches = gaddag.findMatches('_AT');

        expect(matches.length, 5);
        expect(matches, containsAll(['CAT', 'BAT', 'HAT', 'RAT', 'SAT']));
        expect(matches, isNot(contains('DOG')));
      });

      test('should match pattern with known letters at start', () {
        gaddag.build(['PAPER', 'WATER', 'TABLE', 'MAKER', 'TAKER']);

        final matches = gaddag.findMatches('_A_ER');

        expect(matches, containsAll(['PAPER', 'WATER', 'MAKER', 'TAKER']));
        expect(matches, isNot(contains('TABLE')));
      });

      test('should match pattern with internal constraints', () {
        gaddag.build(['APPLE', 'AMPLE', 'ANKLE']);

        final matches = gaddag.findMatches('A__LE');

        expect(matches.length, 3);
        expect(matches, containsAll(['APPLE', 'AMPLE', 'ANKLE']));
      });

      test('should match exact word (no wildcards)', () {
        gaddag.build(['CAT', 'DOG', 'BIRD']);

        final matches = gaddag.findMatches('CAT');

        expect(matches.length, 1);
        expect(matches, contains('CAT'));
      });

      test('should return empty for no matches', () {
        gaddag.build(['CAT', 'DOG']);

        final matches = gaddag.findMatches('XYZ');

        expect(matches, isEmpty);
      });

      test('should return empty for wrong length pattern', () {
        gaddag.build(['CAT', 'DOG']);

        final matches = gaddag.findMatches(
          '____',
        ); // 4 chars, no 4-letter words

        expect(matches, isEmpty);
      });

      test('should be case insensitive for patterns', () {
        gaddag.build(['CAT', 'BAT']);

        final matches = gaddag.findMatches('_at');

        expect(matches, containsAll(['CAT', 'BAT']));
      });
    });

    group('findWordsWithConstraints', () {
      test('should find words with position constraints', () {
        gaddag.build(['PAPER', 'WATER', 'TABLE', 'MAKER']);

        final matches = gaddag.findWordsWithConstraints(5, {1: 'A'});

        expect(matches, containsAll(['PAPER', 'WATER', 'TABLE', 'MAKER']));
      });

      test('should find words with multiple constraints', () {
        gaddag.build(['PAPER', 'WATER', 'TABLE', 'PALER']);

        final matches = gaddag.findWordsWithConstraints(5, {0: 'P', 4: 'R'});

        expect(matches.length, 2);
        expect(matches, containsAll(['PAPER', 'PALER']));
      });

      test('should return empty for impossible constraints', () {
        gaddag.build(['CAT', 'DOG']);

        final matches = gaddag.findWordsWithConstraints(3, {0: 'X'});

        expect(matches, isEmpty);
      });
    });

    group('getAvailableLettersAtPosition', () {
      test('should get available first letters', () {
        gaddag.build(['CAT', 'BAT', 'HAT', 'DOG']);

        final letters = gaddag.getAvailableLettersAtPosition(3, 0, {});

        expect(letters, containsAll(['C', 'B', 'H', 'D']));
      });

      test('should get available letters with constraints', () {
        gaddag.build(['CAT', 'BAT', 'HAT', 'DOG']);

        final letters = gaddag.getAvailableLettersAtPosition(3, 0, {2: 'T'});

        expect(letters, containsAll(['C', 'B', 'H']));
        expect(letters, isNot(contains('D'))); // DOG doesn't end with T
      });
    });

    group('statistics', () {
      test('should return statistics', () {
        gaddag.build(['CAT', 'DOG', 'BIRD', 'FISH']);

        final stats = gaddag.statistics;

        expect(stats['wordCount'], 4);
        expect(stats['nodeCount'], greaterThan(0));
        expect(stats['terminalCount'], greaterThan(0));
        expect(stats['lengthDistribution'], isA<Map>());
      });
    });

    group('allWords', () {
      test('should return all words', () {
        gaddag.build(['CAT', 'DOG', 'BIRD']);

        final words = gaddag.allWords;

        expect(words.length, 3);
        expect(words, containsAll(['CAT', 'DOG', 'BIRD']));
      });

      test('allWords should be unmodifiable', () {
        gaddag.build(['CAT', 'DOG']);

        final words = gaddag.allWords;

        expect(() => (words as Set).add('BIRD'), throwsUnsupportedError);
      });
    });

    group('performance', () {
      test('should handle large word list', () {
        // Generate 1000 random words
        final words = List.generate(
          1000,
          (i) => 'WORD${i.toString().padLeft(4, '0')}',
        );

        final stopwatch = Stopwatch()..start();
        gaddag.build(words);
        stopwatch.stop();

        expect(gaddag.wordCount, 1000);
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('should lookup pattern quickly', () {
        final gaddag =
            Gaddag()..build(
              List.generate(1000, (i) => 'WORD${i.toString().padLeft(4, '0')}'),
            );

        final stopwatch = Stopwatch()..start();
        for (var i = 0; i < 100; i++) {
          gaddag.findMatches('WORD____');
        }
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });

  group('GaddagNode', () {
    test('should initialize with empty children', () {
      final node = GaddagNode();

      expect(node.children, isEmpty);
      expect(node.isTerminal, false);
      expect(node.wordAtTerminal, isNull);
    });

    test('should allow adding children', () {
      final node = GaddagNode();
      node.children['A'] = GaddagNode();
      node.children['B'] = GaddagNode();

      expect(node.children.length, 2);
    });

    test('should allow marking as terminal', () {
      final node =
          GaddagNode()
            ..isTerminal = true
            ..wordAtTerminal = 'TEST';

      expect(node.isTerminal, true);
      expect(node.wordAtTerminal, 'TEST');
    });
  });
}
