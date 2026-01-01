import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_selection_providers.g.dart';

/// Represents a selected cell in the grid.
class SelectedCell {
  const SelectedCell(this.row, this.col);
  final int row;
  final int col;
}

/// Represents word direction: horizontal or vertical.
enum WordDirection { horizontal, vertical }

/// Holds the currently selected cell (or null if none).
@Riverpod(keepAlive: true)
class SelectedCellNotifier extends _$SelectedCellNotifier {
  @override
  SelectedCell? build() => null;

  /// Select or clear the current selected cell.
  void select(SelectedCell? v) => state = v;
}

/// Holds the current word direction (horizontal or vertical).
@Riverpod(keepAlive: true)
class WordDirectionNotifier extends _$WordDirectionNotifier {
  @override
  WordDirection build() => WordDirection.horizontal;

  /// Update current word direction.
  void setDirection(WordDirection v) => state = v;
}
