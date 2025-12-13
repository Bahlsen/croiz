import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/game_providers.dart';

void main() {
  test('assetPathForPuzzleId maps id to assets/data/<id>.json', () {
    expect(assetPathForPuzzleId('astronomie_puzzle'),
        'assets/data/astronomie_puzzle.json');
    expect(assetPathForPuzzleId('nyt2005-01-01'),
        'assets/data/nyt2005-01-01.json');
    expect(assetPathForPuzzleId('sample_5x5'), 'assets/data/sample_5x5.json');
  });
}
