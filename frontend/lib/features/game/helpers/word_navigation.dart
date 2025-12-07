import 'package:croiz/domain/entities/game_entities.dart';

/// Computes the adjacent entry given the current entry and delta.
/// - Navigates within current direction, and when overflowing,
///   wraps into the other direction (start or end accordingly).
PuzzleEntryData computeAdjacentEntry(
  List<PuzzleEntryData> entries,
  PuzzleEntryData current,
  int delta,
) {
  if (entries.isEmpty) {
    return current;
  }
  // Direction-first ordering: navigate within current direction by number,
  // wrap into the other direction only when overflowing.
  final across = entries.where((e) => e.direction == 'across').toList()
    ..sort((a, b) => a.number.compareTo(b.number));
  final down = entries.where((e) => e.direction == 'down').toList()
    ..sort((a, b) => a.number.compareTo(b.number));

  final isAcross = current.direction == 'across';
  final currentList = isAcross ? across : down;
  final otherList = isAcross ? down : across;

  final idxInDir = currentList.indexWhere(
    (e) =>
        e.x == current.x &&
        e.y == current.y &&
        e.direction == current.direction,
  );
  if (idxInDir == -1) {
    return current;
  }

  final nextIdx = idxInDir + delta;
  if (nextIdx < 0) {
    return otherList.isNotEmpty ? otherList.last : currentList.last;
  }
  if (nextIdx >= currentList.length) {
    return otherList.isNotEmpty ? otherList.first : currentList.first;
  }
  return currentList[nextIdx];
}
