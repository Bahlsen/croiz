import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PuzzleDescriptor', () {
    test('parses difficulty from JSON', () {
      final descriptor = PuzzleDescriptor.fromJson({
        'id': 'test1',
        'title': 'Test Puzzle',
        'path': 'test/test1.json',
        'difficulty': 3,
        'difficulty_label': 'Hard',
      });
      expect(descriptor.difficulty, 3);
    });

    test('parses difficultyLabel from JSON', () {
      final descriptor = PuzzleDescriptor.fromJson({
        'id': 'test1',
        'title': 'Test Puzzle',
        'path': 'test/test1.json',
        'difficulty': 3,
        'difficulty_label': 'Hard',
      });
      expect(descriptor.difficultyLabel, 'Hard');
    });

    test('defaults difficulty to 2 (Medium) when missing', () {
      final descriptor = PuzzleDescriptor.fromJson({
        'id': 'test1',
        'title': 'Test Puzzle',
        'path': 'test/test1.json',
      });
      expect(descriptor.difficulty, 2);
      expect(descriptor.difficultyLabel, 'Medium');
    });

    test('parses language from JSON', () {
      final descriptor = PuzzleDescriptor.fromJson({
        'id': 'test1',
        'title': 'Test Puzzle',
        'path': 'test/test1.json',
        'language': 'fr',
      });
      expect(descriptor.language, 'fr');
    });

    test('defaults language to "en" when missing', () {
      final descriptor = PuzzleDescriptor.fromJson({
        'id': 'test1',
        'title': 'Test Puzzle',
        'path': 'test/test1.json',
      });
      expect(descriptor.language, 'en');
    });

    test('copyWith preserves all fields', () {
      final original = PuzzleDescriptor(
        id: 'test1',
        title: 'Test Puzzle',
        path: 'test/test1.json',
        subtitle: 'A subtitle',
        origin: 'nyt',
        year: '2024',
        difficulty: 3,
        difficultyLabel: 'Hard',
        language: 'fr',
      );
      final copy = original.copyWith(title: 'New Title');
      expect(copy.id, 'test1');
      expect(copy.title, 'New Title');
      expect(copy.path, 'test/test1.json');
      expect(copy.subtitle, 'A subtitle');
      expect(copy.origin, 'nyt');
      expect(copy.year, '2024');
      expect(copy.difficulty, 3);
      expect(copy.difficultyLabel, 'Hard');
      expect(copy.language, 'fr');
    });

    test('copyWith can update difficulty', () {
      final original = PuzzleDescriptor(
        id: 'test1',
        title: 'Test Puzzle',
        path: 'test/test1.json',
      );
      final copy = original.copyWith(difficulty: 5, difficultyLabel: 'Master');
      expect(copy.difficulty, 5);
      expect(copy.difficultyLabel, 'Master');
    });
  });

  group('puzzleTokenFromAssetPath', () {
    test('uses basename without .json extension', () {
      expect(
        puzzleTokenFromAssetPath('assets/data/nyt2005-01-01.json'),
        'nyt2005-01-01',
      );
    });

    test('returns basename as-is when no .json', () {
      expect(puzzleTokenFromAssetPath('assets/data/foo'), 'foo');
    });

    test('does not depend on JSON id/title', () {
      // Regression guard: JSON `id` can be a long human title and must not
      // be used as the routing token.
      const assetPath = 'assets/data/nyt2005-01-01.json';
      const jsonId = 'New York Times, Saturday, January 1, 2005';
      expect(puzzleTokenFromAssetPath(assetPath), isNot(jsonId));
    });
  });

  group('puzzleTitleFromJson', () {
    test('prefers top-level title', () {
      final data = <String, dynamic>{
        'title': 'My Puzzle',
        'metadata': <String, dynamic>{'title': 'Ignored'},
      };
      expect(puzzleTitleFromJson(data, fallback: 'fallback'), 'My Puzzle');
    });

    test('supports canonical metadata.title', () {
      final data = <String, dynamic>{
        'metadata': <String, dynamic>{'title': 'NYT 2005-01-01'},
      };
      expect(puzzleTitleFromJson(data, fallback: 'fallback'), 'NYT 2005-01-01');
    });

    test('supports legacy meta.title', () {
      final data = <String, dynamic>{
        'meta': <String, dynamic>{'title': 'Legacy'},
      };
      expect(puzzleTitleFromJson(data, fallback: 'fallback'), 'Legacy');
    });

    test('falls back when no title fields present', () {
      final data = <String, dynamic>{'id': 'Not used for title by this helper'};
      expect(puzzleTitleFromJson(data, fallback: 'fallback'), 'fallback');
    });
  });

  group('strict providers (no fallbacks)', () {
    testWidgets('originIndexProvider loads per-origin compact index', (
      tester,
    ) async {
      // Mock assets for this test to avoid relying on full bundle.
      // originIndexProvider reads from the main puzzles_index.json
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (message) async {
          final key = const StringCodec().decodeMessage(message);
          if (key == 'assets/data/puzzles_index.json') {
            const json = '''
{"items":[{"id":"cs2000-04-12","title":"Apr 12, 2000","subtitle":"","path":"crossynergy/2000/cs2000-04-12.json","origin":"crossynergy","year":"2000"}],"origins":["crossynergy"]}
''';
            final bytes = Uint8List.fromList(json.codeUnits);
            return ByteData.view(bytes.buffer);
          }
          return null;
        },
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final list = await container.read(
        originIndexProvider('crossynergy').future,
      );
      expect(list, isNotEmpty);
      // All paths must be relative (no leading assets/ or data/)
      expect(
        list.every(
          (e) => !e.path.startsWith('assets/') && !e.path.startsWith('data/'),
        ),
        isTrue,
      );
      // contains a known entry from 2000
      expect(
        list.any((e) => e.path.endsWith('2000/cs2000-04-12.json')),
        isTrue,
      );

      // Restore handler
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        null,
      );
    });
  });
}
