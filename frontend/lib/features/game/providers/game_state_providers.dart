import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';

/// Represents a selected cell in the grid.
class SelectedCell {
  const SelectedCell(this.row, this.col);
  final int row;
  final int col;
}

/// Represents word direction: horizontal or vertical.
enum WordDirection { horizontal, vertical }

/// Holds the currently selected cell (or null if none).
class SelectedCellNotifier extends Notifier<SelectedCell?> {
  @override
  SelectedCell? build() => null;
  SelectedCell? get value => state;
  set value(SelectedCell? v) => state = v;
}

final selectedCellProvider =
    NotifierProvider<SelectedCellNotifier, SelectedCell?>(
      SelectedCellNotifier.new,
    );

/// Holds the current word direction (horizontal or vertical).
class WordDirectionNotifier extends Notifier<WordDirection> {
  @override
  WordDirection build() => WordDirection.horizontal;
  WordDirection get value => state;
  set value(WordDirection v) => state = v;
}

final wordDirectionProvider =
    NotifierProvider<WordDirectionNotifier, WordDirection>(
      WordDirectionNotifier.new,
    );

/// Holds the set of found word keys (format: "row,col,direction").
class FoundWordsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};
  Set<String> get value => state;
  set value(Set<String> v) => state = v;
}

final foundWordsProvider = NotifierProvider<FoundWordsNotifier, Set<String>>(
  FoundWordsNotifier.new,
);

/// Holds cells that should flash (for word completion animation).
class FlashingCellsNotifier extends Notifier<Set<CellKey>> {
  @override
  Set<CellKey> build() => <CellKey>{};
  Set<CellKey> get value => state;
  set value(Set<CellKey> v) => state = v;
}

final flashingCellsProvider =
    NotifierProvider<FlashingCellsNotifier, Set<CellKey>>(
      FlashingCellsNotifier.new,
    );

/// Provider family for whether a specific cell is currently flashing.
/// Optimized: uses select() to only rebuild when this cell's membership changes.
final cellFlashingProvider = Provider.family<bool, CellKey>(
  (ref, key) =>
      ref.watch(flashingCellsProvider.select((set) => set.contains(key))),
);

/// Holds cells that should flash red because they were cleared by the cleaner.
class FlashingClearedCellsNotifier extends Notifier<Set<CellKey>> {
  @override
  Set<CellKey> build() => <CellKey>{};
  Set<CellKey> get value => state;
  set value(Set<CellKey> v) => state = v;
}

final flashingClearedCellsProvider =
    NotifierProvider<FlashingClearedCellsNotifier, Set<CellKey>>(
      FlashingClearedCellsNotifier.new,
    );

/// Provider family for whether a specific cell is in the "cleared flash" set.
/// Optimized: uses select() to only rebuild when this cell's membership changes.
final cellClearedFlashingProvider = Provider.family<bool, CellKey>(
  (ref, key) => ref.watch(
    flashingClearedCellsProvider.select((set) => set.contains(key)),
  ),
);

/// Holds cells that are locked (found words cannot be edited).
class LockedCellsNotifier extends Notifier<Set<CellKey>> {
  @override
  Set<CellKey> build() => <CellKey>{};
  Set<CellKey> get value => state;
  set value(Set<CellKey> v) => state = v;
}

final lockedCellsProvider = NotifierProvider<LockedCellsNotifier, Set<CellKey>>(
  LockedCellsNotifier.new,
);
