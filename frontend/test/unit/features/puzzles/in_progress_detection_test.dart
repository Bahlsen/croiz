import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';
import 'package:croiz/services/persistence/storage_provider.dart';
import 'package:croiz/services/persistence/puzzle_progress_provider.dart';
import 'package:croiz/features/puzzles/widgets/continue_playing_section.dart';

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

void main() {
  group('inProgressPuzzles detection', () {
    late MockPuzzleStorage mockStorage;

    setUp(() {
      mockStorage = MockPuzzleStorage();
    });

    test(
      'should include puzzle with typed letters but 0 completed words',
      () async {
        const puzzleId = 'test-puzzle';
        final descriptor = PuzzleDescriptor(
          id: puzzleId,
          title: 'Test Puzzle',
          path: 'test/puzzle.json',
        );

        // Save a grid with some letters but no complete words
        final savedPayload = {
          'grid': [
            ['A', null, null], // Part of 'ABC' word
            [null, null, null],
            [null, null, null],
          ],
          'savedAt': DateTime.now().toIso8601String(),
          'foundWords': <String>[],
          'lockedCells': <String>[],
          'elapsedSeconds': 10,
          'isCompleted': false,
        };
        mockStorage.setData(puzzleId, savedPayload);

        // Puzzle solution and clues
        final puzzleJson = {
          'cols': 3,
          'rows': 3,
          'cells': [
            {'solution': 'A', 'is_black': false},
            {'solution': 'B', 'is_black': false},
            {'solution': 'C', 'is_black': false},
            {'solution': 'D', 'is_black': false},
            {'solution': 'E', 'is_black': false},
            {'solution': 'F', 'is_black': false},
            {'solution': 'G', 'is_black': false},
            {'solution': 'H', 'is_black': false},
            {'solution': 'I', 'is_black': false},
          ],
          'clues': [
            {'direction': 'across', 'x': 0, 'y': 0, 'length': 3},
            {'direction': 'across', 'x': 0, 'y': 1, 'length': 3},
            {'direction': 'across', 'x': 0, 'y': 2, 'length': 3},
          ],
        };

        final container = ProviderContainer(
          overrides: [
            puzzleStorageProvider.overrideWithValue(mockStorage),
            puzzlesProvider.overrideWith((ref) => Future.value([descriptor])),
            puzzleJsonLoaderProvider.overrideWithValue(
              (path) async => puzzleJson,
            ),
            puzzleProgressServiceProvider.overrideWith(
              (ref) => PuzzleProgressService(
                storage: mockStorage,
                assetLoader: (path) async => puzzleJson,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Read inProgressPuzzles
        final inProgress = await container.read(
          inProgressPuzzlesProvider.future,
        );

        // Should be included even if percent is 0
        expect(inProgress, isNotEmpty);
        expect(inProgress.first.descriptor.id, puzzleId);
        expect(inProgress.first.completionPercent, 0);
      },
    );

    test(
      'should NOT include puzzle with NO typed letters and 0 completed words',
      () async {
        const puzzleId = 'empty-puzzle';
        final descriptor = PuzzleDescriptor(
          id: puzzleId,
          title: 'Empty Puzzle',
          path: 'test/empty.json',
        );

        final savedPayload = {
          'grid': [
            [null, null, null],
            [null, null, null],
            [null, null, null],
          ],
          'savedAt': DateTime.now().toIso8601String(),
          'isCompleted': false,
        };
        mockStorage.setData(puzzleId, savedPayload);

        final container = ProviderContainer(
          overrides: [
            puzzleStorageProvider.overrideWithValue(mockStorage),
            puzzlesProvider.overrideWith((ref) => Future.value([descriptor])),
            puzzleJsonLoaderProvider.overrideWithValue(
              (path) async => {
                'cols': 3,
                'rows': 3,
                'cells': List.generate(9, (_) => {'solution': 'A'}),
                'clues': [
                  {'direction': 'across', 'x': 0, 'y': 0, 'length': 3},
                ],
              },
            ),
            puzzleProgressServiceProvider.overrideWith(
              (ref) => PuzzleProgressService(
                storage: mockStorage,
                assetLoader:
                    (path) async => {
                      'cols': 3,
                      'rows': 3,
                      'cells': List.generate(9, (_) => {'solution': 'A'}),
                      'clues': [
                        {'direction': 'across', 'x': 0, 'y': 0, 'length': 3},
                      ],
                    },
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final inProgress = await container.read(
          inProgressPuzzlesProvider.future,
        );
        expect(inProgress, isEmpty);
      },
    );
  });
}
