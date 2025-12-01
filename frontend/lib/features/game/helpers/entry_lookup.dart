import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/features/game/game_providers.dart';

class EntryContext {
  const EntryContext({
    required this.horizontal,
    required this.entry,
    required this.entries,
  });
  final bool horizontal;
  final PuzzleEntryData entry;
  final List<PuzzleEntryData> entries;
}

EntryContext? computeCurrentEntry(
  GameBoard board,
  SelectedCell selected,
  WordDirection dir,
) {
  final entries = board.entries;
  if (entries == null || entries.isEmpty) {
    return null;
  }

  final horizontal = dir == WordDirection.horizontal;
  final bounds = board.blackCells.wordBounds(
    selected.row,
    selected.col,
    horizontal: horizontal,
  );
  final startX = horizontal ? bounds[0] : selected.col;
  final startY = horizontal ? selected.row : bounds[0];

  final dirStr = horizontal ? 'across' : 'down';
  final entry = entries.firstWhere(
    (e) => e.x == startX && e.y == startY && e.direction == dirStr,
    orElse: () => const PuzzleEntryData(
      number: -1,
      direction: 'across',
      x: -1,
      y: -1,
      length: 0,
      clue: null,
    ),
  );
  if (entry.number == -1) {
    return null;
  }

  return EntryContext(horizontal: horizontal, entry: entry, entries: entries);
}
