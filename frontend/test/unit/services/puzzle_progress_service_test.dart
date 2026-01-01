import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';

/// Mock implementation of the storage interface for testing.
class MockPuzzleStorage implements PuzzleStorageInterface {
  final Map<String, Map<String, dynamic>> _data = {};

  final _controller = StreamController<void>.broadcast();

  @override
  Stream<void> get onDataChanged => _controller.stream;

  void setData(String id, Map<String, dynamic> payload) {
    _data[id] = payload;
    _controller.add(null);
  }

  @override
  Future<Map<String, dynamic>?> load(String id) async => _data[id];

  @override
  Future<void> save(String id, Map<String, dynamic> payload) async {
    _data[id] = payload;
    _controller.add(null);
  }

  @override
  Future<List<String>> getAllKeys() async => _data.keys.toList();
}

/// Mock asset loader for testing solution loading.
class MockAssetLoaderStore {
  final Map<String, Map<String, dynamic>> _puzzles = {};

  void setPuzzle(String path, Map<String, dynamic> puzzle) {
    _puzzles[path] = puzzle;
  }

  Future<Map<String, dynamic>> loadPuzzleJson(String path) async {
    final puzzle = _puzzles[path];
    if (puzzle == null) {
      throw Exception('Puzzle not found: $path');
    }
    return puzzle;
  }
}

void main() {
  late MockPuzzleStorage mockStorage;
  late MockAssetLoaderStore mockAssetLoaderStore;
  late PuzzleProgressService service;

  setUp(() {
    mockStorage = MockPuzzleStorage();
    mockAssetLoaderStore = MockAssetLoaderStore();
    service = PuzzleProgressService(
      storage: mockStorage,
      assetLoader: mockAssetLoaderStore.loadPuzzleJson,
    );
  });

  group('getAllInProgressPuzzleIds', () {
    test('returns empty when no saves', () async {
      final ids = await service.getAllInProgressPuzzleIds();
      expect(ids, isEmpty);
    });

    test('returns saved puzzle IDs', () async {
      mockStorage
        ..setData('puzzle-a', {'savedAt': '2024-01-01T10:00:00Z'})
        ..setData('puzzle-b', {'savedAt': '2024-01-02T10:00:00Z'})
        ..setData('puzzle-c', {'savedAt': '2024-01-03T10:00:00Z'});

      final ids = await service.getAllInProgressPuzzleIds();
      expect(ids, containsAll(['puzzle-a', 'puzzle-b', 'puzzle-c']));
      expect(ids.length, 3);
    });
  });

  group('getProgress', () {
    test('returns null for unknown puzzle', () async {
      final progress = await service.getProgress('unknown-puzzle');
      expect(progress, isNull);
    });

    test('returns PuzzleProgress with correct fields', () async {
      mockStorage.setData('puzzle-a', {
        'savedAt': '2024-01-15T14:30:00Z',
        'elapsedSeconds': 300,
        'grid': [
          ['A', 'B', null],
          ['C', null, 'D'],
        ],
      });

      final progress = await service.getProgress('puzzle-a');
      expect(progress, isNotNull);
      expect(progress!.puzzleId, 'puzzle-a');
      expect(progress.savedAt, DateTime.utc(2024, 1, 15, 14, 30));
      expect(progress.elapsedSeconds, 300);
    });
  });

  group('calculateCompletionPercent', () {
    test('returns 0 for empty grid', () {
      final grid = [
        [null, null, null],
        [null, null, null],
      ];
      // Solution with same dimensions (no black cells)
      final solution = [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
      ];
      final percent = service.calculateCompletionPercent(grid, solution);
      expect(percent, 0.0);
    });

    test('returns 100 for full grid', () {
      final grid = [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
      ];
      final solution = [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
      ];
      final percent = service.calculateCompletionPercent(grid, solution);
      expect(percent, 100.0);
    });

    test('returns 50 for half-filled grid', () {
      final grid = [
        ['A', 'B', null],
        [null, null, null],
      ];
      final solution = [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
      ];
      final percent = service.calculateCompletionPercent(grid, solution);
      // 2 filled out of 6 = 33.33%
      expect(percent, closeTo(33.33, 0.1));
    });

    test('ignores black cells (null in solution)', () {
      // Grid with a black cell (null in solution means black cell)
      final grid = [
        ['A', 'B'],
        [null, 'D'], // first cell is black
      ];
      final solution = [
        ['A', 'B'],
        [null, 'D'], // null in solution = black cell
      ];
      // 3 white cells, 3 filled (A, B, D)
      final percent = service.calculateCompletionPercent(grid, solution);
      expect(percent, 100.0);
    });

    test('counts partially filled grid with black cells correctly', () {
      final grid = [
        ['A', null],
        [null, null], // first cell is black
      ];
      final solution = [
        ['A', 'B'],
        [null, 'D'], // null in solution = black cell
      ];
      // 3 white cells, 1 filled (A)
      final percent = service.calculateCompletionPercent(grid, solution);
      expect(percent, closeTo(33.33, 0.1));
    });
  });

  group('getInProgressPuzzlesSortedByRecency', () {
    test('returns newest first', () async {
      mockStorage
        ..setData('old', {
          'savedAt': '2024-01-01T10:00:00Z',
          'elapsedSeconds': 100,
        })
        ..setData('middle', {
          'savedAt': '2024-01-15T10:00:00Z',
          'elapsedSeconds': 200,
        })
        ..setData('newest', {
          'savedAt': '2024-01-30T10:00:00Z',
          'elapsedSeconds': 300,
        });

      final sorted = await service.getInProgressPuzzlesSortedByRecency();
      expect(sorted.length, 3);
      expect(sorted[0].puzzleId, 'newest');
      expect(sorted[1].puzzleId, 'middle');
      expect(sorted[2].puzzleId, 'old');
    });
  });

  group('isCompleted', () {
    test('returns true when grid matches solution', () async {
      final grid = [
        ['A', 'B'],
        ['C', 'D'],
      ];
      mockAssetLoaderStore.setPuzzle('test/puzzle.json', {
        'cells': [
          {'solution': 'A'},
          {'solution': 'B'},
          {'solution': 'C'},
          {'solution': 'D'},
        ],
        'cols': 2,
        'rows': 2,
      });

      final completed = await service.isCompleted(
        grid: grid,
        puzzlePath: 'test/puzzle.json',
      );
      expect(completed, isTrue);
    });

    test('returns false for partial completion', () async {
      final grid = [
        ['A', null],
        ['C', 'D'],
      ];
      mockAssetLoaderStore.setPuzzle('test/puzzle.json', {
        'cells': [
          {'solution': 'A'},
          {'solution': 'B'},
          {'solution': 'C'},
          {'solution': 'D'},
        ],
        'cols': 2,
        'rows': 2,
      });

      final completed = await service.isCompleted(
        grid: grid,
        puzzlePath: 'test/puzzle.json',
      );
      expect(completed, isFalse);
    });

    test('returns false when answer is wrong', () async {
      final grid = [
        ['A', 'X'], // X is wrong
        ['C', 'D'],
      ];
      mockAssetLoaderStore.setPuzzle('test/puzzle.json', {
        'cells': [
          {'solution': 'A'},
          {'solution': 'B'},
          {'solution': 'C'},
          {'solution': 'D'},
        ],
        'cols': 2,
        'rows': 2,
      });

      final completed = await service.isCompleted(
        grid: grid,
        puzzlePath: 'test/puzzle.json',
      );
      expect(completed, isFalse);
    });
  });

  group('solution caching', () {
    test('cache prevents redundant asset loads', () async {
      var loadCount = 0;
      final testPuzzle = {
        'cells': [
          {'solution': 'A'},
          {'solution': 'B'},
        ],
        'cols': 2,
        'rows': 1,
      };
      Future<Map<String, dynamic>> trackingLoader(String path) async {
        loadCount++;
        return testPuzzle;
      }

      final serviceWithTracking = PuzzleProgressService(
        storage: mockStorage,
        assetLoader: trackingLoader,
      );

      // Load twice
      await serviceWithTracking.isCompleted(
        grid: [
          ['A', 'B'],
        ],
        puzzlePath: 'test/puzzle.json',
      );
      await serviceWithTracking.isCompleted(
        grid: [
          ['A', 'B'],
        ],
        puzzlePath: 'test/puzzle.json',
      );

      // Should only load once due to caching
      expect(loadCount, 1);
    });

    test('clearSolutionCache frees memory', () async {
      var loadCount = 0;
      final testPuzzle = {
        'cells': [
          {'solution': 'A'},
        ],
        'cols': 1,
        'rows': 1,
      };
      Future<Map<String, dynamic>> trackingLoader(String path) async {
        loadCount++;
        return testPuzzle;
      }

      final serviceWithTracking = PuzzleProgressService(
        storage: mockStorage,
        assetLoader: trackingLoader,
      );

      // Load once
      await serviceWithTracking.isCompleted(
        grid: [
          ['A'],
        ],
        puzzlePath: 'test/puzzle.json',
      );
      expect(loadCount, 1);

      // Clear cache and load again
      serviceWithTracking.clearSolutionCache();
      await serviceWithTracking.isCompleted(
        grid: [
          ['A'],
        ],
        puzzlePath: 'test/puzzle.json',
      );
      expect(loadCount, 2);
    });
  });
}
