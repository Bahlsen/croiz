import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_puzzles_provider.g.dart';

/// Represents a puzzle currently being generated in the background.
class PendingPuzzle {
  PendingPuzzle({
    required this.tempId,
    required this.topic,
    required this.language,
    required this.difficulty,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  final String tempId;
  final String topic;
  final String language;
  final int difficulty;
  final DateTime startedAt;

  PuzzleDescriptor toDescriptor() => PuzzleDescriptor(
    id: tempId,
    title: topic,
    path: '',
    difficulty: difficulty,
    language: language,
    source: PuzzleSource.local,
  );
}

@riverpod
class PendingPuzzles extends _$PendingPuzzles {
  @override
  List<PendingPuzzle> build() => [];

  void add(PendingPuzzle puzzle) {
    state = [...state, puzzle];
  }

  void remove(String tempId) {
    state = state.where((p) => p.tempId != tempId).toList();
  }
}
