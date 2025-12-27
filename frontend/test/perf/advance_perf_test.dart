/// Performance test for _advanceToNextEmptyFrom
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/controllers/entry_helpers.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/game_audio_service.dart';
import 'perf_logger.dart';

class _MockAudioService implements GameAudioService {
  @override
  Future<void> playType() async {}
  @override
  Future<void> playDelete() async {}
  @override
  Future<void> playSuccess() async {}
  @override
  Future<void> playVictory() async {}
  @override
  Future<void> get ready => Future<void>.value();
  @override
  Future<void> dispose() async {}
}

void main() {
  group('Advance Performance Tests', () {
    test('findNextEmptyFromEntry on large grid with many entries', () {
      // Simulate a 15x15 crossword with many entries
      const size = 15;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final blacks = List.generate(size, (_) => List<bool>.filled(size, false));

      // Create many entries (like a real crossword)
      final entries = <PuzzleEntryData>[];
      var entryNum = 1;
      for (var row = 0; row < size; row += 2) {
        entries.add(
          PuzzleEntryData(
            number: entryNum++,
            direction: 'across',
            x: 0,
            y: row,
            length: size,
          ),
        );
      }
      for (var col = 0; col < size; col += 2) {
        entries.add(
          PuzzleEntryData(
            number: entryNum++,
            direction: 'down',
            x: col,
            y: 0,
            length: size,
          ),
        );
      }

      final board = GameBoard(
        id: 'perf-test',
        title: 'Perf Test',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: blacks,
        difficulty: 1,
        entries: entries,
      );

      final sw = Stopwatch()..start();
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        findNextEmptyFromEntry(
          containing: entries[i % entries.length],
          wantAcross: i.isEven,
          board: board,
          entries: entries,
          lockedCells: const {},
          skipLocked: true,
        );
      }

      sw.stop();
      final avgMicros = sw.elapsedMicroseconds / iterations;
      perfPrint(
        'findNextEmptyFromEntry avg: ${avgMicros.toStringAsFixed(2)}µs',
      );
      expect(avgMicros, lessThan(500)); // Should be < 0.5ms
    });

    test('setLetterAndAdvance on large grid', () {
      const size = 15;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final blacks = List.generate(size, (_) => List<bool>.filled(size, false));

      final entries = <PuzzleEntryData>[];
      var entryNum = 1;
      for (var row = 0; row < size; row += 2) {
        entries.add(
          PuzzleEntryData(
            number: entryNum++,
            direction: 'across',
            x: 0,
            y: row,
            length: size,
          ),
        );
      }
      for (var col = 0; col < size; col += 2) {
        entries.add(
          PuzzleEntryData(
            number: entryNum++,
            direction: 'down',
            x: col,
            y: 0,
            length: size,
          ),
        );
      }

      final board = GameBoard(
        id: 'perf-test',
        title: 'Perf Test',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: blacks,
        difficulty: 1,
        entries: entries,
      );

      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(_MockAudioService()),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);

      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        0,
        0,
      );

      final controller = CrosswordInputController.fromContainer(container);

      final sw = Stopwatch()..start();
      const iterations = 50;

      for (var i = 0; i < iterations; i++) {
        controller.setLetterAndAdvance(String.fromCharCode(65 + (i % 26)));
      }

      sw.stop();
      final avgMicros = sw.elapsedMicroseconds / iterations;
      final avgMs = avgMicros / 1000;
      perfPrint(
        'setLetterAndAdvance (large grid) avg: ${avgMicros.toStringAsFixed(2)}µs (${avgMs.toStringAsFixed(3)}ms)',
      );
      expect(avgMs, lessThan(5)); // Should be < 5ms
    });
  });
}
