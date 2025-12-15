import 'package:croiz/domain/entities/game_entities.dart';

GameBoard makeEmptyBoard({int size = 5}) {
  final grid = List<List<String?>>.generate(
    size,
    (_) => List<String?>.filled(size, null),
  );
  final blacks = List<List<bool>>.generate(
    size,
    (_) => List<bool>.filled(size, false),
  );
  return GameBoard(
    id: '<test-empty>',
    title: '<test-empty>',
    gridSize: size,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    grid: grid,
    clues: const {},
    blackCells: blacks,
    difficulty: 1,
  );
}
