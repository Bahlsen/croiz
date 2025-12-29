import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/data/models/puzzle.dart';
import 'package:croiz/core/puzzle_converter.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';

/// Holds the currently selected puzzle id.
///
/// IMPORTANT: null means "no puzzle selected" (there is no default puzzle).
class SelectedPuzzleIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  /// Set the selected puzzle id (persisted).
  void setSelected(String? v) {
    state = v;
    _persistSelected(v);
  }

  Future<void> _persistSelected(String? v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (v == null) {
        await prefs.remove('last_selected_puzzle');
      } else {
        await prefs.setString('last_selected_puzzle', v);
      }
    } on Object {
      // ignore
    }
  }
}

final selectedPuzzleIdProvider =
    NotifierProvider<SelectedPuzzleIdNotifier, String?>(
      SelectedPuzzleIdNotifier.new,
    );

/// Provider to load the puzzle asynchronously from JSON.
///
/// IMPORTANT: this does **not** load any default puzzle. A puzzle id must be
/// selected via `selectedPuzzleIdProvider` (or tests must override this
/// provider). This guarantees we never silently load the same puzzle.
final puzzleLoaderProvider = FutureProvider<GameBoard>((ref) async {
  final selected = ref.watch(selectedPuzzleIdProvider);
  if (selected == null || selected.isEmpty) {
    throw StateError('No puzzle selected');
  }

  // Strict behaviour: resolve the selected id by looking it up in the
  // precomputed index. If the id is not present in the index we fail
  // loudly instead of attempting heuristic fallbacks.
  final index = await ref.watch(puzzlesProvider.future);
  final match = index.firstWhere(
    (p) => p.id == selected,
    orElse: () =>
        throw StateError('Selected puzzle id not found in index: $selected'),
  );
  // Use the indexed path (normalized by providers) and build a proper
  // asset key for `rootBundle` by prefixing `data/`.
  final assetPath = 'assets/data/${match.path}';
  final loader = ref.read(puzzleAssetLoaderProvider);
  return loader(assetPath);
});

/// Load a puzzle from a JSON asset file and convert to GameBoard.
Future<GameBoard> loadPuzzleFromAsset(String assetPath) async {
  // Load JSON from assets and parse
  final jsonString = await rootBundle.loadString(assetPath);
  final jsonData = json.decode(jsonString) as Map<String, dynamic>;
  final puzzle = Puzzle.fromJson(jsonData);

  if (kDebugMode) {
    developer.log(
      'loadPuzzleFromAsset: loaded puzzle id=${puzzle.id} '
      'declared rows=${puzzle.rows} cols=${puzzle.cols}',
      name: 'GameProviders',
    );
  }

  // Control prefill via a Dart define: `--dart-define=PREFILL_PUZZLE=true`
  const prefillEnv = bool.fromEnvironment(
    'PREFILL_PUZZLE',
    defaultValue: false,
  );
  const shouldPrefill = kDebugMode && prefillEnv;

  var board = PuzzleConverter.puzzleToGameBoard(
    puzzle,
    preFillSolutions: shouldPrefill,
  );

  if (kDebugMode) {
    developer.log(
      'loadPuzzleFromAsset: converted board id=${board.id} '
      'gridSize=${board.gridSize} rows=${board.grid.length} '
      'cols=${board.grid.isEmpty ? 0 : board.grid[0].length}',
      name: 'GameProviders',
    );
  }

  // If prefill is active, clear exactly one non-black cell to leave a single
  // missing letter for quick manual completion during testing.
  if (shouldPrefill) {
    board = _prefillExceptOne(board);
  }

  return board;
}

/// Resolve a puzzle id to a strict asset path under `assets/data/`.
String assetPathForPuzzleId(String id) => 'assets/data/$id.json';

/// Provider for the loader function so tests can override loading behavior.
final puzzleAssetLoaderProvider = Provider<Future<GameBoard> Function(String)>(
  (ref) => loadPuzzleFromAsset,
);

GameBoard _prefillExceptOne(GameBoard board) {
  // Prefer clearing the center cell to make the prefill deterministic and
  // easy to find during manual testing. If center is black or not prefilled,
  // fall back to the first available prefilled cell.
  final coords = <MapEntry<int, int>>[];
  for (var r = 0; r < board.gridSize; r++) {
    for (var c = 0; c < board.gridSize; c++) {
      if (!board.blackCells[r][c] && (board.grid[r][c] != null)) {
        coords.add(MapEntry(r, c));
      }
    }
  }
  if (coords.isEmpty) {
    return board;
  }

  final centerR = board.gridSize ~/ 2;
  final centerC = board.gridSize ~/ 2;
  MapEntry<int, int>? pick;
  if (centerR >= 0 &&
      centerR < board.gridSize &&
      centerC >= 0 &&
      centerC < board.gridSize &&
      !board.blackCells[centerR][centerC] &&
      board.grid[centerR][centerC] != null) {
    pick = MapEntry(centerR, centerC);
  } else {
    pick = coords.first;
  }

  final newGrid = List<List<String?>>.from(board.grid.map(List<String?>.from));
  newGrid[pick.key][pick.value] = null;
  return board.copyWith(grid: newGrid);
}
