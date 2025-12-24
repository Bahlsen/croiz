/// Croiz performance benchmarks.
///
/// Run benchmarks: flutter test test/perf/benchmarks.dart
/// Save baseline: flutter test test/perf/benchmarks.dart --dart-define=SAVE_BASELINE=true
/// Compare to baseline: flutter test test/perf/benchmarks.dart --dart-define=COMPARE=true
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/services/game_audio_service.dart';

import 'benchmark_framework.dart';

// =============================================================================
// Test doubles
// =============================================================================

class NoopWordCheckService extends WordCheckService {
  @override
  bool isWordComplete(GameBoard board, PuzzleEntryData entry) => false;
}

class MockGameAudioService implements GameAudioService {
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

// =============================================================================
// Benchmark utilities
// =============================================================================

GameBoard _createTestBoard({int size = 12, int entriesCount = 8}) {
  final entries = <PuzzleEntryData>[];
  for (var r = 0; r < entriesCount; r++) {
    entries.add(
      PuzzleEntryData(
        number: r + 1,
        direction: 'across',
        x: 0,
        y: r,
        length: size - 2,
      ),
    );
  }

  return GameBoard(
    id: 'bench-board',
    title: 'benchmark',
    gridSize: size,
    createdAt: DateTime.now(),
    grid: List.generate(size, (_) => List<String?>.filled(size, null)),
    clues: const {},
    blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
    difficulty: 1,
    entries: entries,
  );
}

ProviderContainer _createContainer() => ProviderContainer(
  overrides: [
    wordCheckServiceProvider.overrideWithValue(NoopWordCheckService()),
    gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
    flashClearDelayProvider.overrideWithValue(Duration.zero),
    wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
  ],
);

// =============================================================================
// Benchmarks
// =============================================================================

/// Benchmark: Fast typing simulation (200 keystrokes).
class FastTypingBenchmark extends BenchmarkBase {
  FastTypingBenchmark() : super('FastTyping_200chars');

  late ProviderContainer _container;
  late CrosswordInputController _controller;

  @override
  void setup() {
    _container = _createContainer();
    final board = _createTestBoard();
    _container.read(gameBoardProvider.notifier).board = board;
    _container.read(selectedCellProvider.notifier).value = const SelectedCell(
      0,
      0,
    );
    _container.read(wordDirectionProvider.notifier).value =
        WordDirection.horizontal;
    _controller = CrosswordInputController.fromContainer(_container);
  }

  @override
  void teardown() {
    _container.dispose();
  }

  @override
  void run() {
    // Reset board state for each run.
    final board = _createTestBoard();
    _container.read(gameBoardProvider.notifier).board = board;
    _container.read(selectedCellProvider.notifier).value = const SelectedCell(
      0,
      0,
    );

    // Simulate typing 200 characters.
    for (var i = 0; i < 200; i++) {
      final ch = String.fromCharCode(65 + (i % 26));
      _controller.setLetterAndAdvance(ch);
    }
  }

  @override
  void exercise() => run(); // Report per single run, not per 10.
}

/// Benchmark: Setting letters on the board directly.
class SetLetterBenchmark extends BenchmarkBase {
  SetLetterBenchmark() : super('SetLetter_1000ops');

  late ProviderContainer _container;

  @override
  void setup() {
    _container = _createContainer();
    final board = _createTestBoard(size: 15);
    _container.read(gameBoardProvider.notifier).board = board;
  }

  @override
  void teardown() {
    _container.dispose();
  }

  @override
  void run() {
    final notifier = _container.read(gameBoardProvider.notifier);
    // Set 1000 letters across the grid.
    for (var i = 0; i < 1000; i++) {
      final row = i % 15;
      final col = (i ~/ 15) % 15;
      final ch = String.fromCharCode(65 + (i % 26));
      notifier.setLetter(row, col, ch);
    }
  }

  @override
  void exercise() => run();
}

/// Benchmark: Board state reads (provider access).
class BoardReadBenchmark extends BenchmarkBase {
  BoardReadBenchmark() : super('BoardRead_10000reads');

  late ProviderContainer _container;

  @override
  void setup() {
    _container = _createContainer();
    final board = _createTestBoard(size: 15);
    _container.read(gameBoardProvider.notifier).board = board;
    _container.read(selectedCellProvider.notifier).value = const SelectedCell(
      5,
      5,
    );
    _container.read(wordDirectionProvider.notifier).value =
        WordDirection.horizontal;
  }

  @override
  void teardown() {
    _container.dispose();
  }

  @override
  void run() {
    // Read various providers 10000 times total.
    for (var i = 0; i < 2500; i++) {
      _container
        ..read(gameBoardProvider)
        ..read(selectedCellProvider)
        ..read(wordDirectionProvider)
        ..read(lockedCellsProvider);
    }
  }

  @override
  void exercise() => run();
}

/// Benchmark: CellKey hashCode and equality (used heavily in Sets).
class CellKeyHashBenchmark extends BenchmarkBase {
  CellKeyHashBenchmark() : super('CellKeyHash_100000ops');

  late Set<CellKey> _set;
  late List<CellKey> _keys;

  @override
  void setup() {
    _set = <CellKey>{};
    _keys = [
      for (var r = 0; r < 100; r++)
        for (var c = 0; c < 100; c++) CellKey(r, c),
    ];
  }

  @override
  void run() {
    _set
      ..clear()
      // Add and check 10000 keys.
      ..addAll(_keys);
    // Check contains.
    _keys.forEach(_set.contains);
  }

  @override
  void exercise() => run();
}

/// Benchmark: GameBoard.copyWith (shallow copy performance).
class BoardCopyBenchmark extends BenchmarkBase {
  BoardCopyBenchmark() : super('BoardCopyWith_1000copies');

  late GameBoard _board;

  @override
  void setup() {
    _board = _createTestBoard(size: 15);
  }

  @override
  void run() {
    for (var i = 0; i < 1000; i++) {
      // Simulate what setLetter does: shallow copy grid, copy one row.
      final newGrid = List<List<String?>>.of(_board.grid);
      final rowCopy = List<String?>.of(newGrid[i % 15]);
      rowCopy[i % 15] = 'X';
      newGrid[i % 15] = rowCopy;
      _board = _board.copyWith(grid: newGrid);
    }
  }

  @override
  void exercise() => run();
}

// =============================================================================
// Test entry point
// =============================================================================

/// Performance thresholds in microseconds (us).
/// These are generous to avoid CI flakiness but will detect gross regressions.
const Map<String, double> _thresholdsUs = {
  'FastTyping_200chars': 50000, // 50ms
  'SetLetter_1000ops': 100000, // 100ms
  'BoardRead_10000reads': 50000, // 50ms
  'CellKeyHash_100000ops': 20000, // 20ms
  'BoardCopyWith_1000copies': 50000, // 50ms
};

void main() {
  group('Performance benchmarks', () {
    late List<BenchmarkBase> benchmarks;

    setUpAll(() {
      benchmarks = <BenchmarkBase>[
        FastTypingBenchmark(),
        SetLetterBenchmark(),
        BoardReadBenchmark(),
        CellKeyHashBenchmark(),
        BoardCopyBenchmark(),
      ];
    });

    test('FastTyping_200chars within threshold', () {
      final benchmark = FastTypingBenchmark();
      final result = benchmark.reportAndCapture();
      final threshold = _thresholdsUs[result.name]!;

      // ignore: avoid_print
      print(
        '${result.name}: ${result.runtimeUs.toStringAsFixed(2)} us '
        '(threshold: ${threshold.toStringAsFixed(0)} us)',
      );

      expect(
        result.runtimeUs,
        lessThan(threshold),
        reason:
            '${result.name} exceeded threshold: '
            '${result.runtimeUs.toStringAsFixed(2)} us > $threshold us',
      );
    });

    test('SetLetter_1000ops within threshold', () {
      final benchmark = SetLetterBenchmark();
      final result = benchmark.reportAndCapture();
      final threshold = _thresholdsUs[result.name]!;

      // ignore: avoid_print
      print(
        '${result.name}: ${result.runtimeUs.toStringAsFixed(2)} us '
        '(threshold: ${threshold.toStringAsFixed(0)} us)',
      );

      expect(
        result.runtimeUs,
        lessThan(threshold),
        reason:
            '${result.name} exceeded threshold: '
            '${result.runtimeUs.toStringAsFixed(2)} us > $threshold us',
      );
    });

    test('BoardRead_10000reads within threshold', () {
      final benchmark = BoardReadBenchmark();
      final result = benchmark.reportAndCapture();
      final threshold = _thresholdsUs[result.name]!;

      // ignore: avoid_print
      print(
        '${result.name}: ${result.runtimeUs.toStringAsFixed(2)} us '
        '(threshold: ${threshold.toStringAsFixed(0)} us)',
      );

      expect(
        result.runtimeUs,
        lessThan(threshold),
        reason:
            '${result.name} exceeded threshold: '
            '${result.runtimeUs.toStringAsFixed(2)} us > $threshold us',
      );
    });

    test('CellKeyHash_100000ops within threshold', () {
      final benchmark = CellKeyHashBenchmark();
      final result = benchmark.reportAndCapture();
      final threshold = _thresholdsUs[result.name]!;

      // ignore: avoid_print
      print(
        '${result.name}: ${result.runtimeUs.toStringAsFixed(2)} us '
        '(threshold: ${threshold.toStringAsFixed(0)} us)',
      );

      expect(
        result.runtimeUs,
        lessThan(threshold),
        reason:
            '${result.name} exceeded threshold: '
            '${result.runtimeUs.toStringAsFixed(2)} us > $threshold us',
      );
    });

    test('BoardCopyWith_1000copies within threshold', () {
      final benchmark = BoardCopyBenchmark();
      final result = benchmark.reportAndCapture();
      final threshold = _thresholdsUs[result.name]!;

      // ignore: avoid_print
      print(
        '${result.name}: ${result.runtimeUs.toStringAsFixed(2)} us '
        '(threshold: ${threshold.toStringAsFixed(0)} us)',
      );

      expect(
        result.runtimeUs,
        lessThan(threshold),
        reason:
            '${result.name} exceeded threshold: '
            '${result.runtimeUs.toStringAsFixed(2)} us > $threshold us',
      );
    });

    test('all benchmarks summary', () {
      // ignore: avoid_print
      print('\n=== Performance Benchmarks Summary ===');
      final results = runBenchmarks(benchmarks);

      var allPassed = true;
      for (final result in results) {
        final threshold = _thresholdsUs[result.name];
        if (threshold != null && result.runtimeUs > threshold) {
          allPassed = false;
          // ignore: avoid_print
          print(
            '❌ ${result.name}: FAILED '
            '(${result.runtimeUs.toStringAsFixed(2)} us > $threshold us)',
          );
        } else {
          // ignore: avoid_print
          print('✅ ${result.name}: ${result.runtimeUs.toStringAsFixed(2)} us');
        }
      }

      expect(
        allPassed,
        isTrue,
        reason: 'One or more benchmarks exceeded threshold',
      );
    });
  });
}
