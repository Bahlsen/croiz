import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GridGenerator Large Grids', () {
    test('should generate 25x25 grid reasonably fast', () {
      final generator = GridGenerator(width: 25, height: 25);
      // Use realistic words with common letters for intersections
      final words = [
        const GeneratedWord(answer: 'WATER', clue: 'H2O'),
        const GeneratedWord(answer: 'EARTH', clue: 'Planet'),
        const GeneratedWord(answer: 'HEART', clue: 'Organ'),
        const GeneratedWord(answer: 'GREAT', clue: 'Big'),
        const GeneratedWord(answer: 'TREAT', clue: 'Snack'),
        const GeneratedWord(answer: 'BREAD', clue: 'Food'),
        const GeneratedWord(answer: 'DREAM', clue: 'Sleep vision'),
        const GeneratedWord(answer: 'STEAM', clue: 'Hot vapor'),
        const GeneratedWord(answer: 'CREAM', clue: 'Dairy'),
        const GeneratedWord(answer: 'CLEAR', clue: 'Transparent'),
        const GeneratedWord(answer: 'LEARN', clue: 'Study'),
        const GeneratedWord(answer: 'EARLY', clue: 'Not late'),
        const GeneratedWord(answer: 'READY', clue: 'Prepared'),
        const GeneratedWord(answer: 'STEADY', clue: 'Stable'),
        const GeneratedWord(answer: 'THREAD', clue: 'Sewing material'),
        const GeneratedWord(answer: 'SPREAD', clue: 'Distribute'),
        const GeneratedWord(answer: 'STREAM', clue: 'River'),
        const GeneratedWord(answer: 'MASTER', clue: 'Expert'),
        const GeneratedWord(answer: 'FASTER', clue: 'Quicker'),
        const GeneratedWord(answer: 'EASTER', clue: 'Holiday'),
        const GeneratedWord(answer: 'READER', clue: 'Book lover'),
        const GeneratedWord(answer: 'LEADER', clue: 'Boss'),
        const GeneratedWord(answer: 'DEALER', clue: 'Seller'),
        const GeneratedWord(answer: 'HEALER', clue: 'Doctor'),
        const GeneratedWord(answer: 'SEALER', clue: 'Closer'),
        const GeneratedWord(answer: 'REVEAL', clue: 'Show'),
        const GeneratedWord(answer: 'REPEAT', clue: 'Do again'),
        const GeneratedWord(answer: 'DEFEAT', clue: 'Beat'),
        const GeneratedWord(answer: 'CREATE', clue: 'Make'),
        const GeneratedWord(answer: 'RELATE', clue: 'Connect'),
        const GeneratedWord(answer: 'DEBATE', clue: 'Argue'),
        const GeneratedWord(answer: 'ESTATE', clue: 'Property'),
        const GeneratedWord(answer: 'BREATH', clue: 'Air intake'),
        const GeneratedWord(answer: 'WREATH', clue: 'Decoration'),
        const GeneratedWord(answer: 'SHEATH', clue: 'Cover'),
        const GeneratedWord(answer: 'HEALTH', clue: 'Wellness'),
        const GeneratedWord(answer: 'WEALTH', clue: 'Riches'),
        const GeneratedWord(answer: 'STEALTH', clue: 'Sneaky'),
        const GeneratedWord(answer: 'THEATER', clue: 'Cinema'),
        const GeneratedWord(answer: 'SWEATER', clue: 'Clothing'),
        const GeneratedWord(answer: 'WEATHER', clue: 'Climate'),
        const GeneratedWord(answer: 'LEATHER', clue: 'Material'),
        const GeneratedWord(answer: 'FEATHER', clue: 'Bird part'),
        const GeneratedWord(answer: 'HEATHER', clue: 'Plant'),
        const GeneratedWord(answer: 'BREATHE', clue: 'Inhale'),
        const GeneratedWord(answer: 'BENEATH', clue: 'Under'),
        const GeneratedWord(answer: 'BEQUEATH', clue: 'Leave in will'),
        const GeneratedWord(answer: 'RETREAT', clue: 'Withdraw'),
        const GeneratedWord(answer: 'ENTREAT', clue: 'Beg'),
        const GeneratedWord(answer: 'MISTREAT', clue: 'Abuse'),
      ];

      final stopwatch = Stopwatch()..start();
      final result = generator.generate(
        words,
        attempts: 10,
      ); // More attempts for better results
      stopwatch.stop();

      // print('25x25 Generation took: ${stopwatch.elapsedMilliseconds}ms');

      expect(result, isNotEmpty);
      expect(
        result.length,
        greaterThan(3),
      ); // Should place at least a few words

      // Verify bounds
      for (final placed in result) {
        expect(placed.startX, greaterThanOrEqualTo(0));
        expect(placed.startY, greaterThanOrEqualTo(0));
        if (placed.isHorizontal) {
          expect(
            placed.startX + placed.word.answer.length,
            lessThanOrEqualTo(25),
          );
        } else {
          expect(
            placed.startY + placed.word.answer.length,
            lessThanOrEqualTo(25),
          );
        }
      }
    });

    test('should generate 20x20 grid', () {
      final generator = GridGenerator(width: 20, height: 20);
      final words = [
        const GeneratedWord(answer: 'WATER', clue: 'H2O'),
        const GeneratedWord(answer: 'EARTH', clue: 'Planet'),
        const GeneratedWord(answer: 'HEART', clue: 'Organ'),
        const GeneratedWord(answer: 'GREAT', clue: 'Big'),
        const GeneratedWord(answer: 'TREAT', clue: 'Snack'),
        const GeneratedWord(answer: 'BREAD', clue: 'Food'),
        const GeneratedWord(answer: 'DREAM', clue: 'Sleep vision'),
        const GeneratedWord(answer: 'STEAM', clue: 'Hot vapor'),
        const GeneratedWord(answer: 'CREAM', clue: 'Dairy'),
        const GeneratedWord(answer: 'CLEAR', clue: 'Transparent'),
        const GeneratedWord(answer: 'LEARN', clue: 'Study'),
        const GeneratedWord(answer: 'EARLY', clue: 'Not late'),
        const GeneratedWord(answer: 'READY', clue: 'Prepared'),
        const GeneratedWord(answer: 'STEADY', clue: 'Stable'),
        const GeneratedWord(answer: 'THREAD', clue: 'Sewing material'),
        const GeneratedWord(answer: 'SPREAD', clue: 'Distribute'),
        const GeneratedWord(answer: 'STREAM', clue: 'River'),
        const GeneratedWord(answer: 'MASTER', clue: 'Expert'),
        const GeneratedWord(answer: 'FASTER', clue: 'Quicker'),
        const GeneratedWord(answer: 'EASTER', clue: 'Holiday'),
        const GeneratedWord(answer: 'READER', clue: 'Book lover'),
        const GeneratedWord(answer: 'LEADER', clue: 'Boss'),
        const GeneratedWord(answer: 'DEALER', clue: 'Seller'),
        const GeneratedWord(answer: 'HEALER', clue: 'Doctor'),
        const GeneratedWord(answer: 'SEALER', clue: 'Closer'),
        const GeneratedWord(answer: 'REVEAL', clue: 'Show'),
        const GeneratedWord(answer: 'REPEAT', clue: 'Do again'),
        const GeneratedWord(answer: 'DEFEAT', clue: 'Beat'),
        const GeneratedWord(answer: 'CREATE', clue: 'Make'),
        const GeneratedWord(answer: 'RELATE', clue: 'Connect'),
        const GeneratedWord(answer: 'DEBATE', clue: 'Argue'),
        const GeneratedWord(answer: 'ESTATE', clue: 'Property'),
        const GeneratedWord(answer: 'BREATH', clue: 'Air intake'),
        const GeneratedWord(answer: 'WREATH', clue: 'Decoration'),
        const GeneratedWord(answer: 'SHEATH', clue: 'Cover'),
        const GeneratedWord(answer: 'HEALTH', clue: 'Wellness'),
        const GeneratedWord(answer: 'WEALTH', clue: 'Riches'),
        const GeneratedWord(answer: 'STEALTH', clue: 'Sneaky'),
        const GeneratedWord(answer: 'THEATER', clue: 'Cinema'),
        const GeneratedWord(answer: 'SWEATER', clue: 'Clothing'),
      ];

      final result = generator.generate(words, attempts: 10);

      expect(result, isNotEmpty);
      expect(result.length, greaterThan(3));
    });
  });
}
