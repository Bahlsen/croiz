import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/utils/clue_numbering.dart';
import 'game_board_provider.dart';

/// Index of entries by cell for fast lookups.
/// Maps a CellKey to the list of entries (across/down) that include it.
final cellEntriesIndexProvider = Provider<Map<CellKey, List<PuzzleEntryData>>>((
  ref,
) {
  // Recompute index only when entries change (grid changes do not matter).
  final entries = ref.watch(gameBoardProvider.select((b) => b.entries));
  if (entries == null || entries.isEmpty) {
    return const {};
  }
  final map = <CellKey, List<PuzzleEntryData>>{};
  for (final e in entries) {
    final isAcross = e.directionEnum == EntryDirection.across;
    for (var i = 0; i < e.length; i++) {
      final r = isAcross ? e.y : e.y + i;
      final c = isAcross ? e.x + i : e.x;
      final key = CellKey(r, c);
      map.putIfAbsent(key, () => <PuzzleEntryData>[]).add(e);
    }
  }
  return map;
});

/// Pre-sorted across entries for fast navigation.
/// Computed once when entries change, not on every keystroke.
final sortedAcrossEntriesProvider = Provider<List<PuzzleEntryData>>((ref) {
  final entries = ref.watch(gameBoardProvider.select((b) => b.entries));
  if (entries == null || entries.isEmpty) {
    return const [];
  }
  return entries.where((e) => e.directionEnum == EntryDirection.across).toList()
    ..sort((a, b) => a.number.compareTo(b.number));
});

/// Pre-sorted down entries for fast navigation.
/// Computed once when entries change, not on every keystroke.
final sortedDownEntriesProvider = Provider<List<PuzzleEntryData>>((ref) {
  final entries = ref.watch(gameBoardProvider.select((b) => b.entries));
  if (entries == null || entries.isEmpty) {
    return const [];
  }
  return entries.where((e) => e.directionEnum == EntryDirection.down).toList()
    ..sort((a, b) => a.number.compareTo(b.number));
});

/// Precomputed clue numbers map for quick per-cell lookup.
/// Uses CellKey for efficient hashability.
final clueNumbersProvider = Provider<Map<CellKey, int>>((ref) {
  // Only depend on gridSize and entries, which are sufficient for numbering.
  final size = ref.watch(gameBoardProvider.select((b) => b.gridSize));
  final entries = ref.watch(gameBoardProvider.select((b) => b.entries));
  return ClueNumbering.numbersFrom(size, entries);
});

/// Provider family exposing a single cell's value. Widgets should watch
/// `cellValueProvider(CellKey(r, c))` to rebuild only when that cell's letter
/// changes, avoiding large grid rebuilds.
/// Uses CellKey for efficient hashability (unlike List<int>).
final cellValueProvider = Provider.family<String?, CellKey>(
  (ref, key) =>
      ref.watch(gameBoardProvider.select((b) => b.grid[key.row][key.col])),
);
