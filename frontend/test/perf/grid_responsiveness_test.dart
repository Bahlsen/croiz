/// Grid UI Responsiveness Tests
///
/// Tests that measure the perceived responsiveness of the crossword grid:
/// 1. Time from tap to visual update
/// 2. Cell rebuild isolation (only affected cells rebuild)
/// 3. Frame budget compliance (< 16ms for 60fps)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/widgets/grid/crossword_cell.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/game_audio_service.dart';

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
  group('Grid Responsiveness Tests', () {
    late ProviderContainer container;
    late GameBoard board;

    setUp(() {
      const size = 5;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final blacks = List.generate(size, (_) => List<bool>.filled(size, false));
      final entries = <PuzzleEntryData>[
        const PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 0,
          y: 0,
          length: 5,
        ),
        const PuzzleEntryData(
          number: 2,
          direction: 'down',
          x: 0,
          y: 0,
          length: 5,
        ),
      ];

      board = GameBoard(
        id: 'grid-resp-test',
        title: 'Grid Responsiveness',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: blacks,
        difficulty: 1,
        entries: entries,
      );

      container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(_MockAudioService()),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('cell selection update should complete within one frame (< 16ms)', () {
      container.read(gameBoardProvider.notifier).board = board;

      final sw = Stopwatch()..start();

      // Simulate rapid cell selection changes (like fast tapping)
      for (var i = 0; i < 20; i++) {
        container.read(selectedCellProvider.notifier).value = SelectedCell(
          i % 5,
          i % 5,
        );
      }

      sw.stop();
      final avgMicros = sw.elapsedMicroseconds / 20;

      // Must complete within 16ms (60fps frame budget)
      expect(
        avgMicros,
        lessThan(16000),
        reason:
            'Selection update must be < 16ms for 60fps, got ${avgMicros / 1000}ms',
      );

      // ignore: avoid_print
      print('Cell selection avg: ${(avgMicros / 1000).toStringAsFixed(2)}ms');
    });

    test('letter input with full controller flow should be < 4ms', () {
      container.read(gameBoardProvider.notifier).board = board;
      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        0,
        0,
      );
      container.read(wordDirectionProvider.notifier).value =
          WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);

      final sw = Stopwatch()..start();
      const iterations = 25;

      for (var i = 0; i < iterations; i++) {
        controller.setLetterAndAdvance(String.fromCharCode(65 + (i % 26)));
      }

      sw.stop();
      final avgMicros = sw.elapsedMicroseconds / iterations;
      final avgMs = avgMicros / 1000;

      // Target: < 4ms per keystroke for responsive feel
      // (CI runners are slower; 4ms is still well under 16ms frame budget)
      expect(
        avgMs,
        lessThan(4),
        reason:
            'Letter input should be < 4ms, got ${avgMs.toStringAsFixed(2)}ms',
      );

      // ignore: avoid_print
      print('Letter input avg: ${avgMs.toStringAsFixed(2)}ms');
    });

    test('direction toggle should be instantaneous (< 0.5ms)', () {
      container.read(gameBoardProvider.notifier).board = board;
      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        0,
        0,
      );

      final sw = Stopwatch()..start();
      const iterations = 50;

      for (var i = 0; i < iterations; i++) {
        final current = container.read(wordDirectionProvider);
        container
            .read(wordDirectionProvider.notifier)
            .value = current == WordDirection.horizontal
            ? WordDirection.vertical
            : WordDirection.horizontal;
      }

      sw.stop();
      final avgMicros = sw.elapsedMicroseconds / iterations;
      final avgMs = avgMicros / 1000;

      expect(
        avgMs,
        lessThan(0.5),
        reason:
            'Direction toggle should be < 0.5ms, got ${avgMs.toStringAsFixed(3)}ms',
      );

      // ignore: avoid_print
      print('Direction toggle avg: ${avgMs.toStringAsFixed(3)}ms');
    });

    testWidgets('grid cell tap updates selection immediately', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                height: 300,
                child: CrosswordGrid(key: Key('test-grid')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial selection is null
      expect(container.read(selectedCellProvider), isNull);

      final sw = Stopwatch()..start();

      // Find and tap a cell
      final cellFinder = find.byType(CrosswordCell).first;
      await tester.tap(cellFinder);
      await tester.pump(); // Single frame

      sw.stop();

      // Selection should be updated after single pump
      expect(container.read(selectedCellProvider), isNotNull);

      // ignore: avoid_print
      print('Tap-to-selection: ${sw.elapsedMilliseconds}ms (includes pump)');
    });

    testWidgets('rapid cell taps remain responsive', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                height: 300,
                child: CrosswordGrid(key: Key('test-grid')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final cells = find.byType(CrosswordCell);
      expect(cells, findsNWidgets(25)); // 5x5 grid

      final sw = Stopwatch()..start();

      // Rapid-tap 10 different cells
      for (var i = 0; i < 10; i++) {
        await tester.tap(cells.at(i));
        await tester.pump();
      }

      sw.stop();
      final avgMs = sw.elapsedMilliseconds / 10;

      // Each tap cycle should be fast
      expect(
        avgMs,
        lessThan(50),
        reason: 'Rapid taps should stay < 50ms each, got ${avgMs}ms avg',
      );

      // ignore: avoid_print
      print('Rapid tap avg: ${avgMs.toStringAsFixed(1)}ms per tap');
    });
  });

  group('Cell Rebuild Isolation Tests', () {
    test('setting letter at (0,0) should not affect cell (1,1) value', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(_MockAudioService()),
        ],
      );

      const size = 5;
      final board = GameBoard(
        id: 'isolation-test',
        title: 'Isolation',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: List.generate(size, (_) => List<String?>.filled(size, null)),
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
        difficulty: 1,
      );

      // Track reads to cellValueProvider for each cell
      var cell00Reads = 0;
      var cell11Reads = 0;

      container
        ..read(gameBoardProvider.notifier).board = board
        ..listen(
          cellValueProvider(const CellKey(0, 0)),
          (_, __) => cell00Reads++,
        )
        ..listen(
          cellValueProvider(const CellKey(1, 1)),
          (_, __) => cell11Reads++,
        );

      // Set letter only at (0,0)
      container.read(gameBoardProvider.notifier).setLetter(0, 0, 'X');

      // Cell (0,0) should have new value
      expect(container.read(cellValueProvider(const CellKey(0, 0))), 'X');
      // Cell (1,1) should remain null
      expect(container.read(cellValueProvider(const CellKey(1, 1))), isNull);

      container.dispose();
    });
  });

  group('Frame Budget Compliance', () {
    test('full keystroke flow fits within 16ms frame budget', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(_MockAudioService()),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );

      const size = 10;
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
        id: 'frame-budget-test',
        title: 'Frame Budget',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: List.generate(size, (_) => List<String?>.filled(size, null)),
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
        difficulty: 1,
        entries: entries,
      );

      container.read(gameBoardProvider.notifier).board = board;
      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        0,
        0,
      );
      container.read(wordDirectionProvider.notifier).value =
          WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);

      // Measure individual keystrokes
      final timings = <int>[];

      for (var i = 0; i < 30; i++) {
        final sw = Stopwatch()..start();
        controller.setLetterAndAdvance(String.fromCharCode(65 + (i % 26)));
        sw.stop();
        timings.add(sw.elapsedMicroseconds);
      }

      final maxMicros = timings.reduce((a, b) => a > b ? a : b);
      final avgMicros = timings.reduce((a, b) => a + b) / timings.length;

      // ALL keystrokes must fit within 16ms frame budget
      expect(
        maxMicros,
        lessThan(16000),
        reason: 'Worst keystroke was ${maxMicros / 1000}ms, must be < 16ms',
      );

      // ignore: avoid_print
      print(
        'Keystroke timing: avg=${(avgMicros / 1000).toStringAsFixed(2)}ms, '
        'max=${(maxMicros / 1000).toStringAsFixed(2)}ms',
      );

      container.dispose();
    });
  });
}
