import 'package:croiz/features/generation/models/generated_word.dart';

/// Represents a word placed on the grid.
class PlacedWord {
  PlacedWord({
    required this.word,
    required this.startX,
    required this.startY,
    required this.isHorizontal,
  });

  final GeneratedWord word;
  final int startX;
  final int startY;
  final bool isHorizontal;
}
