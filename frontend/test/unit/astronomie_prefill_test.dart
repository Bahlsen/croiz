import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/core/puzzle_converter.dart';
import 'package:croiz/features/game/services/word_check_service.dart';

void main() {
  test('astronomie puzzle prefill fills expected cells', () {
    final file = File('assets/data/astronomie_puzzle.json');
    final jsonString = file.readAsStringSync();
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final puzzle = Puzzle.fromJson(jsonData);

    final board = PuzzleConverter.puzzleToGameBoard(puzzle, preFillSolutions: true);

    // Check the two cells mentioned by the user: x=6,y=1 and x=6,y=2
    expect(board.grid[1][6], equals('C'));
    expect(board.grid[2][6], equals('I'));

    // Verify a known across entry with answer is complete when prefilled
    final svc = WordCheckService();
    final entries = board.entries;
    expect(entries, isNotNull);
    // Entry 1 across (SOLEIL) should be complete when prefilled
    final e1 = entries!.firstWhere((e) => e.number == 1 && e.direction == 'across');
    expect(svc.isWordComplete(board, e1), isTrue);
  });
}
