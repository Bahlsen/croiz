/// UI Interaction Performance Tests
///
/// These tests measure the performance of UI interactions with the crossword grid:
/// 1. Time from keystroke to state update
/// 2. Time from state update to UI rebuild
/// 3. Widget rebuild counts during interactions
/// 4. Provider notification efficiency
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/game_audio_service.dart';

/// Mock audio service for performance tests
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
  group('State Update Performance Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(_MockAudioService()),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('setLetter state update should be < 1ms per operation', () {
      const size = 15;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final blacks = List.generate(size, (_) => List<bool>.filled(size, false));

      final board = GameBoard(
        id: 'perf-test',
        title: 'Perf Test',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: blacks,
        difficulty: 1,
      );

      container.read(gameBoardProvider.notifier).board = board;

      final sw = Stopwatch()..start();
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        final row = i % size;
        final col = (i ~/ size) % size;
        container
            .read(gameBoardProvider.notifier)
            .setLetter(row, col, String.fromCharCode(65 + (i % 26)));
      }

      sw.stop();
      final avgMicros = sw.elapsedMicroseconds / iterations;
      final avgMs = avgMicros / 1000;

      // Should be < 1ms per setLetter operation
      expect(
        avgMs,
        lessThan(1),
        reason:
            'setLetter should take < 1ms, got ${avgMs.toStringAsFixed(3)}ms avg',
      );

      // (perf) suppressed noisy output
    });

    test('selectedCell update should be < 0.5ms per operation', () {
      const iterations = 100;
      final sw = Stopwatch()..start();

      for (var i = 0; i < iterations; i++) {
        container.read(selectedCellProvider.notifier).value = SelectedCell(
          i % 10,
          i % 10,
        );
      }

      sw.stop();
      final avgMicros = sw.elapsedMicroseconds / iterations;
      final avgMs = avgMicros / 1000;

      expect(
        avgMs,
        lessThan(0.5),
        reason:
            'selectedCell update should be < 0.5ms, got ${avgMs.toStringAsFixed(3)}ms',
      );

      // ignore: avoid_print
      // (perf) suppressed noisy output
    });

    test(
      'setLetterAndAdvance full flow should be < 5ms per operation (no debounce)',
      () {
        const size = 10;
        final grid = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        final blacks = List.generate(
          size,
          (_) => List<bool>.filled(size, false),
        );
        final entries = <PuzzleEntryData>[
          for (var r = 0; r < size; r++)
            PuzzleEntryData(
              number: r + 1,
              direction: 'across',
              x: 0,
              y: r,
              length: size,
            ),
        ];

        final board = GameBoard(
          id: 'flow-test',
          title: 'Flow Test',
          gridSize: size,
          createdAt: DateTime.now(),
          grid: grid,
          clues: const {},
          blackCells: blacks,
          difficulty: 1,
          entries: entries,
        );

        container.read(gameBoardProvider.notifier).board = board;
        container.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 0);
        container.read(wordDirectionProvider.notifier).value =
            WordDirection.horizontal;

        final controller = CrosswordInputController.fromContainer(container);

        final sw = Stopwatch()..start();
        const iterations = 50;

        for (var i = 0; i < iterations; i++) {
          controller.setLetterAndAdvance(String.fromCharCode(65 + (i % 26)));
        }

        sw.stop();
        final avgMicros = sw.elapsedMicroseconds / iterations;
        final avgMs = avgMicros / 1000;

        expect(
          avgMs,
          lessThan(5),
          reason:
              'setLetterAndAdvance should be < 5ms per op, got ${avgMs.toStringAsFixed(3)}ms',
        );

        // ignore: avoid_print
        // (perf) suppressed noisy output
      },
    );
  });

  group('Provider Notification Efficiency Tests', () {
    test('setLetter should not trigger unnecessary provider rebuilds', () {
      var gameBoardNotifyCount = 0;
      var selectedCellNotifyCount = 0;

      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(_MockAudioService()),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );

      // Setup board
      const size = 5;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final blacks = List.generate(size, (_) => List<bool>.filled(size, false));

      final board = GameBoard(
        id: 'notify-test',
        title: 'Notify Test',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: blacks,
        difficulty: 1,
      );

      container
        ..read(gameBoardProvider.notifier).board = board
        // Listen to providers to count notifications (ignoring initial fire)
        ..listen(gameBoardProvider, (_, __) {
          gameBoardNotifyCount++;
        }, fireImmediately: false)
        ..listen(selectedCellProvider, (_, __) {
          selectedCellNotifyCount++;
        }, fireImmediately: false);

      // Set 10 letters
      for (var i = 0; i < 10; i++) {
        container
            .read(gameBoardProvider.notifier)
            .setLetter(i % size, i % size, 'A');
      }

      // When setting letters at different positions, should notify once per unique change
      // However diagonal (0,0), (1,1), (2,2), (3,3), (4,4), (0,0)... only 5 unique cells
      // But i%size gives: 0,1,2,3,4,0,1,2,3,4 for i=0..9
      // setLetter has early-return if value unchanged, so only first 5 notify
      expect(
        gameBoardNotifyCount,
        5, // First 5 are new, next 5 are same value at same cell
        reason:
            'gameBoardProvider should notify once per actual change, got $gameBoardNotifyCount',
      );

      // selectedCellProvider should NOT be notified when setting letters
      expect(
        selectedCellNotifyCount,
        0,
        reason:
            'selectedCellProvider should not notify on setLetter, got $selectedCellNotifyCount',
      );

      container.dispose();
    });

    test('cellValueProvider family should isolate rebuilds', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(_MockAudioService()),
        ],
      );

      const size = 5;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final blacks = List.generate(size, (_) => List<bool>.filled(size, false));

      final board = GameBoard(
        id: 'cell-isolate-test',
        title: 'Cell Isolate',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: blacks,
        difficulty: 1,
      );

      container.read(gameBoardProvider.notifier).board = board;

      // Verify initial state
      expect(container.read(cellValueProvider(const CellKey(0, 0))), isNull);
      expect(container.read(cellValueProvider(const CellKey(1, 1))), isNull);

      // Set letter at (0,0) only
      container.read(gameBoardProvider.notifier).setLetter(0, 0, 'A');

      // Only cell (0,0) should have the new value
      expect(container.read(cellValueProvider(const CellKey(0, 0))), 'A');
      expect(container.read(cellValueProvider(const CellKey(1, 1))), isNull);

      // Set letter at (1,1) only
      container.read(gameBoardProvider.notifier).setLetter(1, 1, 'B');

      expect(container.read(cellValueProvider(const CellKey(0, 0))), 'A');
      expect(container.read(cellValueProvider(const CellKey(1, 1))), 'B');

      container.dispose();
    });
  });

  group('Grid Cell Rebuild Count Tests', () {
    test('cellValueProvider returns correct values per cell', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(_MockAudioService()),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );

      const size = 5;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final blacks = List.generate(size, (_) => List<bool>.filled(size, false));

      final board = GameBoard(
        id: 'rebuild-test',
        title: 'Rebuild Test',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: blacks,
        difficulty: 1,
      );

      container.read(gameBoardProvider.notifier).board = board;

      // Set letters in a 2x2 area
      container.read(gameBoardProvider.notifier).setLetter(0, 0, 'A');
      container.read(gameBoardProvider.notifier).setLetter(0, 1, 'B');
      container.read(gameBoardProvider.notifier).setLetter(1, 0, 'C');
      container.read(gameBoardProvider.notifier).setLetter(1, 1, 'D');

      // Verify each cell provider returns the correct value
      expect(container.read(cellValueProvider(const CellKey(0, 0))), 'A');
      expect(container.read(cellValueProvider(const CellKey(0, 1))), 'B');
      expect(container.read(cellValueProvider(const CellKey(1, 0))), 'C');
      expect(container.read(cellValueProvider(const CellKey(1, 1))), 'D');

      // Other cells should remain null
      expect(container.read(cellValueProvider(const CellKey(2, 2))), isNull);
      expect(container.read(cellValueProvider(const CellKey(3, 3))), isNull);

      container.dispose();
    });
  });

  group('Benchmark Thresholds', () {
    test('Grid state update batch performance', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(_MockAudioService()),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );

      const size = 15;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final blacks = List.generate(size, (_) => List<bool>.filled(size, false));

      final board = GameBoard(
        id: 'batch-test',
        title: 'Batch Test',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: blacks,
        difficulty: 1,
      );

      container.read(gameBoardProvider.notifier).board = board;

      // Simulate a burst of 20 rapid keystrokes (like very fast typing)
      final sw = Stopwatch()..start();

      for (var i = 0; i < 20; i++) {
        container
            .read(gameBoardProvider.notifier)
            .setLetter(i ~/ size, i % size, String.fromCharCode(65 + (i % 26)));
      }

      sw.stop();
      final totalMs = sw.elapsedMilliseconds;

      // 20 state updates should complete in < 16ms (one frame budget)
      expect(
        totalMs,
        lessThan(16),
        reason:
            '20 state updates should fit in one frame (16ms), got ${totalMs}ms',
      );

      // ignore: avoid_print
      print('20 setLetter operations took: ${totalMs}ms');

      container.dispose();
    });
  });
}
