import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';

part 'game_progress_providers.g.dart';

/// Holds the set of found word keys (format: "row,col,direction").
@Riverpod(keepAlive: true)
class FoundWordsNotifier extends _$FoundWordsNotifier {
  @override
  Set<String> build() => <String>{};

  /// Replace the authoritative set of found words.
  void setFoundWords(Set<String> v) => state = v;

  /// Add a single found word key.
  void addFound(String key) => state = {...state, key};

  /// Clear all found words.
  void clear() => state = <String>{};
}

/// Holds cells that should flash (for word completion animation).
@Riverpod(keepAlive: true)
class FlashingCellsNotifier extends _$FlashingCellsNotifier {
  @override
  Set<CellKey> build() => <CellKey>{};

  /// Set the flashing cells set.
  void setFlashingCells(Set<CellKey> v) => state = v;
}

/// Provider family for whether a specific cell is currently flashing.
/// Optimized: uses select() to only rebuild when this cell's membership changes.
@Riverpod(keepAlive: true)
bool cellFlashing(Ref ref, CellKey key) =>
    ref.watch(flashingCellsProvider.select((set) => set.contains(key)));

/// Holds cells that should flash red because they were cleared by the cleaner.
@Riverpod(keepAlive: true)
class FlashingClearedCellsNotifier extends _$FlashingClearedCellsNotifier {
  @override
  Set<CellKey> build() => <CellKey>{};

  /// Set the cleared flashing cells.
  void setFlashingClearedCells(Set<CellKey> v) => state = v;
}

/// Provider family for whether a specific cell is in the "cleared flash" set.
/// Optimized: uses select() to only rebuild when this cell's membership changes.
@Riverpod(keepAlive: true)
bool cellClearedFlashing(Ref ref, CellKey key) =>
    ref.watch(flashingClearedCellsProvider.select((set) => set.contains(key)));

/// Holds cells that are locked (found words cannot be edited).
@Riverpod(keepAlive: true)
class LockedCellsNotifier extends _$LockedCellsNotifier {
  @override
  Set<CellKey> build() => <CellKey>{};

  /// Replace the locked cells set.
  void setLockedCells(Set<CellKey> v) => state = v;
}

/// Holds cells that should flash for REVEAL animation.
@Riverpod(keepAlive: true)
class FlashingRevealedCellsNotifier extends _$FlashingRevealedCellsNotifier {
  @override
  Set<CellKey> build() => <CellKey>{};

  /// Set the flashing revealed cells set.
  void setFlashingRevealedCells(Set<CellKey> v) => state = v;
}

/// Provider family for whether a specific cell is currently flashing for reveal.
@Riverpod(keepAlive: true)
bool cellRevealedFlashing(Ref ref, CellKey key) =>
    ref.watch(flashingRevealedCellsProvider.select((set) => set.contains(key)));
