
import 'package:json_annotation/json_annotation.dart';

part 'puzzle_entry.g.dart';

@JsonSerializable(explicitToJson: true)
class PuzzleEntry {

  PuzzleEntry({
    required this.number,
    required this.direction,
    required this.x,
    required this.y,
    required this.length,
    this.id,
    this.answer,
    this.clue,
    this.enumeration,
    this.rebusMap,
    this.multiSolution,
    this.annotations,
  });

  factory PuzzleEntry.fromJson(Map<String, dynamic> json) =>
      _$PuzzleEntryFromJson(json);
  final String? id;
  final int number;
  final String direction; // 'across' or 'down'
  final int x;
  final int y;
  final int length;
  final String? answer;
  final String? clue;
  final String? enumeration;
  final Map<String, String>? rebusMap;
  final List<String>? multiSolution;
  final Map<String, dynamic>? annotations;

  Map<String, dynamic> toJson() => _$PuzzleEntryToJson(this);
}
