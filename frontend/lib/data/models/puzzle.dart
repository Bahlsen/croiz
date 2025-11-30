// ignore_for_file: sort_constructors_first, sort_unnamed_constructors_first

import 'package:json_annotation/json_annotation.dart';
import 'puzzle_cell.dart';
import 'puzzle_entry.dart';

part 'puzzle.g.dart';

@JsonSerializable(explicitToJson: true)
class Puzzle {
  final String id;
  final String? version;
  final Map<String, dynamic>? metadata;
  final int rows;
  final int cols;
  final List<PuzzleCell> cells;
  final List<PuzzleEntry> entries;
  final Map<String, dynamic>? extras;

  Puzzle({
    required this.id,
    required this.rows,
    required this.cols,
    required this.cells,
    required this.entries,
    this.version,
    this.metadata,
    this.extras,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) => _$PuzzleFromJson(json);

  Map<String, dynamic> toJson() => _$PuzzleToJson(this);
}
