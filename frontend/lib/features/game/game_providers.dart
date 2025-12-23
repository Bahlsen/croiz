// This file re-exports all game providers from the modular structure.
// Backward compatibility layer - prefer importing from providers/ directly.

export 'providers/game_state_providers.dart';
export 'providers/puzzle_loader_provider.dart';
export 'providers/game_board_provider.dart';
export 'providers/cell_providers.dart';

// Additional providers that haven't been modularized yet
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';
import 'board_helpers.dart';

// Re-import for local use
import 'providers/game_state_providers.dart';
import 'providers/game_board_provider.dart';

/// Provider family exposing whether a specific entry is considered found/complete.
final entryFoundProvider = Provider.family<bool, PuzzleEntryData>((ref, entry) {
  final key = ref.watch(wordCheckServiceProvider).getWordKey(entry);
  final found = ref.watch(foundWordsProvider);
  if (found.contains(key)) {
    return true;
  }
  try {
    final svc = ref.read(wordCheckServiceProvider);
    final board = ref.read(gameBoardProvider);
    return svc.isWordComplete(board, entry);
  } on Object {
    return false;
  }
});

/// Provider family exposing whether a cell is locked.
final cellLockedProvider = Provider.family<bool, CellKey>(
  (ref, key) => ref.watch(lockedCellsProvider).contains(key),
);

/// Set of cells belonging to the currently selected word.
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
final cellInSelectedWordProvider = Provider.family<bool, CellKey>((ref, key) {
  final set = ref.watch(selectedWordCellsProvider);
  return set.contains(key);
});
