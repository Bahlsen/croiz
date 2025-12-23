import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/game_providers.dart';

/// Finds the entry containing [row], [col] in the given direction.
/// Uses [index] for fast lookup, falling back to linear search.
PuzzleEntryData? findContainingEntry({
  required int row,
  required int col,
  required bool wantAcross,
  required List<PuzzleEntryData>? entries,
  Map<CellKey, List<PuzzleEntryData>>? index,
}) {
  // Try fast indexed lookup first
  if (index != null) {
    final list = index[CellKey(row, col)];
    if (list != null && list.isNotEmpty) {
      final dir = wantAcross ? EntryDirection.across : EntryDirection.down;
      for (final e in list) {
        if (e.directionEnum == dir) {
          return e;
        }
      }
    }
  }

  // Fallback to linear search
  if (entries == null || entries.isEmpty) {
    return null;
  }
  for (final e in entries) {
    if (wantAcross && e.directionEnum != EntryDirection.across) {
      continue;
    }
    if (!wantAcross && e.directionEnum != EntryDirection.down) {
      continue;
    }
    final contains = wantAcross
        ? (row == e.y && col >= e.x && col < e.x + e.length)
        : (col == e.x && row >= e.y && row < e.y + e.length);
    if (contains) {
      return e;
    }
  }
  return null;
}

/// Finds the first empty cell in an entry.
/// If [skipLocked] is true, locked cells are skipped.
SelectedCell? firstEmptyInEntry(
  PuzzleEntryData entry,
  GameBoard board, {
  Set<CellKey> lockedCells = const {},
  bool skipLocked = false,
}) {
  if (entry.directionEnum == EntryDirection.across) {
    for (var cc = entry.x; cc < entry.x + entry.length; cc++) {
      final key = CellKey(entry.y, cc);
      if (skipLocked && lockedCells.contains(key)) {
        continue;
      }
      final val = board.grid[entry.y][cc];
      if (val == null || val.isEmpty) {
        return SelectedCell(entry.y, cc);
      }
    }
  } else {
    for (var rr = entry.y; rr < entry.y + entry.length; rr++) {
      final key = CellKey(rr, entry.x);
      if (skipLocked && lockedCells.contains(key)) {
        continue;
      }
      final val = board.grid[rr][entry.x];
      if (val == null || val.isEmpty) {
        return SelectedCell(rr, entry.x);
      }
    }
  }
  return null;
}

/// Finds the next empty cell starting from [containing] entry.
/// Searches same direction first, then opposite direction.
SelectedCell? findNextEmptyFromEntry({
  required PuzzleEntryData containing,
  required bool wantAcross,
  required GameBoard board,
  required List<PuzzleEntryData>? entries,
  Set<CellKey> lockedCells = const {},
  bool skipLocked = true,
}) {
  if (entries == null || entries.isEmpty) {
    return null;
  }

  final sameDir =
      entries
          .where(
            (e) =>
                (wantAcross && e.directionEnum == EntryDirection.across) ||
                (!wantAcross && e.directionEnum == EntryDirection.down),
          )
          .toList()
        ..sort((a, b) => a.number.compareTo(b.number));

  final idx = sameDir.indexWhere((e) => e.number == containing.number);
  if (idx != -1) {
    // Search entries after current
    for (var j = idx + 1; j < sameDir.length; j++) {
      final candidate = sameDir[j];
      final ff = firstEmptyInEntry(
        candidate,
        board,
        lockedCells: lockedCells,
        skipLocked: skipLocked,
      );
      if (ff != null) {
        return ff;
      }
    }
    // Wrap around to entries before current
    for (var j = 0; j < idx; j++) {
      final candidate = sameDir[j];
      final ff = firstEmptyInEntry(
        candidate,
        board,
        lockedCells: lockedCells,
        skipLocked: skipLocked,
      );
      if (ff != null) {
        return ff;
      }
    }
  }

  // Try entries in opposite direction
  final otherDir =
      entries
          .where(
            (e) =>
                (wantAcross && e.directionEnum == EntryDirection.down) ||
                (!wantAcross && e.directionEnum == EntryDirection.across),
          )
          .toList()
        ..sort((a, b) => a.number.compareTo(b.number));

  for (final candidate in otherDir) {
    final ff = firstEmptyInEntry(
      candidate,
      board,
      lockedCells: lockedCells,
      skipLocked: skipLocked,
    );
    if (ff != null) {
      return ff;
    }
  }
  return null;
}
