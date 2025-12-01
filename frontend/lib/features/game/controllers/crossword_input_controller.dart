import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/board_helpers.dart';

typedef Reader = T Function<T>(ProviderListenable<T> provider);

/// Handles keyboard input for the crossword grid, decoupled from UI.
class CrosswordInputController {
  CrosswordInputController._(this._read);

  factory CrosswordInputController.fromRef(WidgetRef ref) =>
      CrosswordInputController._(ref.read);
  factory CrosswordInputController.fromContainer(ProviderContainer container) =>
      CrosswordInputController._(container.read);

  final Reader _read;

  void handleKey(KeyEvent event, int size) {
    if (event is! KeyDownEvent) {
      return;
    }

    final sel = _read(selectedCellProvider);
    final row = sel?.row ?? 0;
    final col = sel?.col ?? 0;
    final black = _read(gameBoardProvider).blackCells;
    if (sel != null && black.isDisabled(sel.row, sel.col)) {
      return;
    }

    final keyLabel = event.logicalKey.keyLabel;

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _move(row, col, 0, 1);
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _move(row, col, 0, -1);
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _move(row, col, 1, 0);
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _move(row, col, -1, 0);
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace ||
        event.logicalKey == LogicalKeyboardKey.delete) {
      _read(gameBoardProvider.notifier).setLetter(row, col, '');
      return;
    }

    if (keyLabel.length == 1) {
      final char = keyLabel.toUpperCase();
      if (RegExp(r'[A-ZÀ-ÖØ-Ý]', unicode: true).hasMatch(char)) {
        _read(gameBoardProvider.notifier).setLetter(row, col, char);
        _advance(row, col);
      }
    }
  }

  void _move(int row, int col, int dr, int dc) {
    final black = _read(gameBoardProvider).blackCells;
    final next = black.nextSelectableFrom(row, col, dr, dc, wrap: true);
    if (next != null) {
      _read(selectedCellProvider.notifier).state = SelectedCell(next[0], next[1]);
    }
  }

  void _advance(int row, int col) {
    final black = _read(gameBoardProvider).blackCells;
    final dir = _read(wordDirectionProvider);
    final dr = dir == WordDirection.vertical ? 1 : 0;
    final dc = dir == WordDirection.vertical ? 0 : 1;
    final next = black.nextSelectableFrom(row, col, dr, dc, wrap: true);
    if (next != null) {
      _read(selectedCellProvider.notifier).state = SelectedCell(next[0], next[1]);
    }
  }
}
