import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/core/puzzle_converter.dart';
import 'package:croiz/features/game/services/word_check_service.dart';

void main() {
  test('entry 7 down is incomplete when JSON length crosses black cell', () {
    final file = File('assets/data/astronomie_puzzle.json');
    final jsonString = file.readAsStringSync();
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final puzzle = Puzzle.fromJson(jsonData);

    final board = PuzzleConverter.puzzleToGameBoard(
      puzzle,
      preFillSolutions: true,
    );

    final svc = WordCheckService();
    final entries = board.entries!;
    final e7 = entries.firstWhere(
      (e) => e.number == 7 && e.direction == 'down',
    );

    // After sanitization the effective length should stop before the black
    // cell and the service should report the (cropped) word as complete.
    expect(board.blackCells[e7.y + (e7.length - 1)][e7.x], isFalse);
    expect(svc.isWordComplete(board, e7), isTrue);
  });
}
