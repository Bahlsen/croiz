// ignore_for_file: sort_constructors_first, sort_unnamed_constructors_first

import 'package:json_annotation/json_annotation.dart';

part 'puzzle_cell.g.dart';

@JsonSerializable(explicitToJson: true)
class PuzzleCell {
  final int x;
  final int y;
  @JsonKey(name: 'is_black')
  final bool isBlack;
  final String? solution;
  final String? state;
  final String? rebus;
  final bool? circled;
  final bool? shaded;
  final bool? barredLeft;
  final bool? barredTop;
  final Map<String, dynamic>? annotations;

  PuzzleCell({
    required this.x,
    required this.y,
    this.isBlack = false,
    this.solution,
    this.state,
    this.rebus,
    this.circled,
    this.shaded,
    this.barredLeft,
    this.barredTop,
    this.annotations,
  });

  factory PuzzleCell.fromJson(Map<String, dynamic> json) =>
      _$PuzzleCellFromJson(json);

  Map<String, dynamic> toJson() => _$PuzzleCellToJson(this);
}
