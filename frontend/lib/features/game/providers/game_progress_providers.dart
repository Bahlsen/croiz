import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';

/// Holds the set of found word keys (format: "row,col,direction").
class FoundWordsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  /// Replace the authoritative set of found words.
  void setFoundWords(Set<String> v) => state = v;

  /// Add a single found word key.
  void addFound(String key) => state = {...state, key};

  /// Clear all found words.
  void clear() => state = <String>{};
}

final foundWordsProvider = NotifierProvider<FoundWordsNotifier, Set<String>>(
  FoundWordsNotifier.new,
);

/// Holds cells that should flash (for word completion animation).
class FlashingCellsNotifier extends Notifier<Set<CellKey>> {
  @override
  Set<CellKey> build() => <CellKey>{};

  /// Set the flashing cells set.
  void setFlashingCells(Set<CellKey> v) => state = v;
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

  /// Set the cleared flashing cells.
  void setFlashingClearedCells(Set<CellKey> v) => state = v;
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

  /// Replace the locked cells set.
  void setLockedCells(Set<CellKey> v) => state = v;
}

final lockedCellsProvider = NotifierProvider<LockedCellsNotifier, Set<CellKey>>(
  LockedCellsNotifier.new,
);
