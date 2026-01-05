import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart'
    show PuzzleStorageInterface;
import 'package:croiz/services/persistence/storage_provider.dart';

/// Service responsible for persisting puzzle progress.
///
/// Extracted from GameBoardNotifier to follow Single Responsibility Principle.
/// Handles debounced persistence of game state including grid, found words,
/// locked cells, and elapsed time.
class GamePersistenceService {
  GamePersistenceService(this._storage);

  final PuzzleStorageInterface _storage;
  Timer? _persistTimer;
  static const Duration _persistDebounce = Duration(milliseconds: 200);

  /// Cancel any pending persist timer.
  void cancelTimer() {
    try {
      _persistTimer?.cancel();
    } on Object {
      // ignore
    }
  }

  /// Dispose resources (call on notifier dispose).
  void dispose() {
    cancelTimer();
  }

  /// Schedule a debounced persist operation.
  void schedulePersist({
    required String puzzleId,
    required List<List<String?>> grid,
    required Set<String> foundWords,
    required Set<CellKey> lockedCells,
    required int elapsedSeconds,
    required bool isCompleted,
  }) {
    cancelTimer();
    _persistTimer = Timer(_persistDebounce, () {
      _persistProgress(
        puzzleId: puzzleId,
        grid: grid,
        foundWords: foundWords,
        lockedCells: lockedCells,
        elapsedSeconds: elapsedSeconds,
        isCompleted: isCompleted,
      );
    });
  }

  /// Persist progress immediately (no debounce).
  Future<void> persistNow({
    required String puzzleId,
    required List<List<String?>> grid,
    required Set<String> foundWords,
    required Set<CellKey> lockedCells,
    required int elapsedSeconds,
    required bool isCompleted,
  }) => _persistProgress(
    puzzleId: puzzleId,
    grid: grid,
    foundWords: foundWords,
    lockedCells: lockedCells,
    elapsedSeconds: elapsedSeconds,
    isCompleted: isCompleted,
  );

  /// Persist the previous puzzle's state when switching puzzles.
  /// This is an async fire-and-forget operation.
  void persistPreviousPuzzle({
    required String puzzleId,
    required List<List<String?>> grid,
    required List<String> foundWords,
    required List<String> lockedCells,
    bool isCompleted = false,
  }) {
    cancelTimer();
    () async {
      try {
        final payload = {
          'schemaVersion': 1,
          'grid': grid,
          'savedAt': DateTime.now().toIso8601String(),
          'foundWords': foundWords,
          'lockedCells': lockedCells,
          'isCompleted': isCompleted,
        };
        await _storage.save(
          puzzleId,
          jsonDecode(jsonEncode(payload)) as Map<String, dynamic>,
        );
      } on Object catch (e, st) {
        if (kDebugMode) {
          developer.log(
            'Failed to persist previous puzzle before switch: $e',
            stackTrace: st,
          );
        }
      }
    }();
  }

  Future<void> _persistProgress({
    required String puzzleId,
    required List<List<String?>> grid,
    required Set<String> foundWords,
    required Set<CellKey> lockedCells,
    required int elapsedSeconds,
    required bool isCompleted,
  }) async {
    try {
      final payload = {
        'schemaVersion': 1,
        'grid': grid,
        'savedAt': DateTime.now().toIso8601String(),
        'foundWords': foundWords.toList(),
        'lockedCells': lockedCells.map((c) => '${c.row},${c.col}').toList(),
        'elapsedSeconds': elapsedSeconds,
        'isCompleted': isCompleted,
      };
      await _storage.save(
        puzzleId,
        jsonDecode(jsonEncode(payload)) as Map<String, dynamic>,
      );
    } on Object catch (e, st) {
      if (kDebugMode) {
        developer.log('Failed to persist puzzle progress: $e', stackTrace: st);
      }
    }
  }
}

/// Provider for the persistence service.
final gamePersistenceServiceProvider = Provider<GamePersistenceService>((ref) {
  final storage = ref.watch(puzzleStorageProvider);
  return GamePersistenceService(storage);
});
