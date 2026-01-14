import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'filtered_puzzles_provider.dart';
import 'puzzles_provider.dart';

part 'random_puzzles_provider.g.dart';

/// Number of random puzzles to display in Quick Play mode.
const int kQuickPlayPuzzleCount = 4;

/// Provider that returns a random selection of puzzles for Quick Play mode.
///
/// Returns up to [kQuickPlayPuzzleCount] puzzles from the filtered list.
/// Use `ref.invalidate(randomPuzzlesProvider)` to get a new random selection.
@Riverpod(dependencies: [filteredPuzzles])
List<PuzzleDescriptor> randomPuzzles(Ref ref) {
  final filtered = ref.watch(filteredPuzzlesProvider);

  if (filtered.isEmpty) {
    return [];
  }

  if (filtered.length <= kQuickPlayPuzzleCount) {
    return filtered;
  }

  // Create a shuffled copy and take the first N
  final shuffled = List<PuzzleDescriptor>.from(filtered)..shuffle(Random());
  return shuffled.take(kQuickPlayPuzzleCount).toList();
}
