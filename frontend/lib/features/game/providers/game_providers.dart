// This file re-exports all game providers from the modular structure.
// Prefer importing from providers/ directly.

export 'game_state_providers.dart';
export 'puzzle_loader_provider.dart';
export 'game_board_notifier.dart';
export 'cell_providers.dart';

// Additional providers that haven't been modularized yet
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import '../helpers/board_helpers.dart';

// Re-import for local use
import 'game_state_providers.dart';
import 'game_board_notifier.dart';

/// Set of cells belonging to the currently selected word.
/// Optimized: only depends on selection, direction, and blackCells structure.
final selectedWordCellsProvider = Provider<Set<CellKey>>((ref) {
  final selected = ref.watch(selectedCellProvider);
  final dir = ref.watch(wordDirectionProvider);
  if (selected == null) {
    return const <CellKey>{};
  }
  final black = ref.watch(gameBoardProvider.select((b) => b.blackCells));
  final horizontal = dir == WordDirection.horizontal;
  final bounds = black.wordBounds(
    selected.row,
    selected.col,
    horizontal: horizontal,
  );
  final cells = <CellKey>{};
  if (horizontal) {
    for (var c = bounds[0]; c <= bounds[1]; c++) {
      cells.add(CellKey(selected.row, c));
    }
  } else {
    for (var r = bounds[0]; r <= bounds[1]; r++) {
      cells.add(CellKey(r, selected.col));
    }
  }
  return cells;
});

/// Provider family that answers whether a specific cell is part of the
/// currently selected word.
/// Optimized: uses select() to only rebuild when this cell's membership changes.
final cellInSelectedWordProvider = Provider.family<bool, CellKey>(
  (ref, key) =>
      ref.watch(selectedWordCellsProvider.select((set) => set.contains(key))),
);
