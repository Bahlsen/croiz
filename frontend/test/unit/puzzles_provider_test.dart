import 'package:flutter_test/flutter_test.dart';

import 'package:croiz/features/puzzles/puzzles_provider.dart';

void main() {
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
}
