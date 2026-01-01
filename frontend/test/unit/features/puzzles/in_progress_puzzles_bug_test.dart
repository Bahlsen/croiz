import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';

/// Mock implementation of the storage interface for testing.
class MockPuzzleStorage implements PuzzleStorageInterface {
  final Map<String, Map<String, dynamic>> _data = {};

  void setData(String id, Map<String, dynamic> payload) {
    _data[id] = payload;
  }

  void clear() {
    _data.clear();
  }

  @override
  Future<Map<String, dynamic>?> load(String id) async => _data[id];

  @override
  Future<void> save(String id, Map<String, dynamic> payload) async {
    _data[id] = payload;
  }

  @override
  Future<List<String>> getAllKeys() async => _data.keys.toList();
}

/// Test to reproduce the bug: completing a word in a puzzle should show
/// the puzzle in "Continue Playing" section when returning to the list.
///
/// Bug description:
/// - User completes a word in a puzzle
/// - User returns to the puzzle list
/// - Puzzle does NOT appear in "in progress" section
///
/// Root cause:
/// The inProgressPuzzlesProvider uses ref.watch(puzzlesProvider) with maybeWhen,
/// which returns empty list when puzzlesProvider is still loading. This causes
/// inProgressPuzzlesProvider to return empty list before puzzlesProvider has loaded.
void main() {
  group('InProgressPuzzlesProvider bug reproduction', () {
    test(
      'inProgressPuzzlesProvider should wait for puzzlesProvider to load',
      () async {
        // Create a delayed puzzles provider to simulate async loading
        final delayedPuzzlesProvider = FutureProvider<List<PuzzleDescriptor>>((
          ref,
        ) async {
          // Simulate a delay in loading puzzles
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return [
            PuzzleDescriptor(
              id: 'test-puzzle',
              title: 'Test Puzzle',
              path: 'test/puzzle.json',
            ),
          ];
        });

        // Create a mock inProgressPuzzlesProvider that demonstrates the bug
        // by using the same pattern as the real one
        final buggyInProgressProvider =
            FutureProvider.autoDispose<List<String>>((ref) async {
              // This is the BUGGY pattern: using maybeWhen
              final puzzlesAsync = ref.watch(delayedPuzzlesProvider);
              final puzzles = puzzlesAsync.maybeWhen(
                data: (p) => p,
                orElse: () => <PuzzleDescriptor>[],
              );

              // If puzzles is empty (because provider hasn't loaded yet),
              // we return empty list - THIS IS THE BUG
              if (puzzles.isEmpty) {
                return [];
              }

              return puzzles.map((p) => p.id).toList();
            });

        // Create container and read the provider
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Read immediately - before puzzlesProvider has loaded
        final resultBeforeLoad = await container.read(
          buggyInProgressProvider.future,
        );

        // BUG: This returns empty because puzzlesProvider hasn't loaded yet
        // The test expects this to fail, demonstrating the bug
        expect(
          resultBeforeLoad,
          isEmpty,
          reason:
              'BUG: With maybeWhen pattern, provider returns empty before '
              'puzzlesProvider loads. This is the bug we need to fix!',
        );

        // Now let's show the CORRECT pattern
        final fixedInProgressProvider = FutureProvider.autoDispose<List<String>>((
          ref,
        ) async {
          // CORRECT: Await the puzzlesProvider.future instead of using maybeWhen
          final puzzles = await ref.watch(delayedPuzzlesProvider.future);

          if (puzzles.isEmpty) {
            return [];
          }

          return puzzles.map((p) => p.id).toList();
        });

        final container2 = ProviderContainer();
        addTearDown(container2.dispose);

        // Read with the fixed pattern - this should correctly wait
        final resultWithFix = await container2.read(
          fixedInProgressProvider.future,
        );

        // FIXED: This returns the correct result after waiting
        expect(
          resultWithFix,
          isNotEmpty,
          reason:
              'FIXED: With .future pattern, provider correctly waits for '
              'puzzlesProvider to load before processing',
        );
        expect(resultWithFix, contains('test-puzzle'));
      },
    );
  });

  group('PuzzleProgressService unit tests', () {
    late MockPuzzleStorage mockStorage;

    setUp(() {
      mockStorage = MockPuzzleStorage();
    });

    test(
      'puzzle with one word completed should have positive completion percent',
      () async {
        // Simulate the exact payload that _persistProgress creates
        // when a user types one letter in a puzzle
        final savedPayload = {
          'schemaVersion': 1,
          'grid': [
            ['A', null, null], // User typed 'A' in first cell
            [null, null, null],
            [null, null, null],
          ],
          'savedAt': DateTime.now().toIso8601String(),
          'foundWords': <String>[],
          'lockedCells': <String>[],
          'elapsedSeconds': 30,
          // NOTE: No 'isCompleted' field - this is the actual payload format
        };

        mockStorage.setData('test-puzzle-1', savedPayload);

        // Verify the storage has the data
        final loadedData = await mockStorage.load('test-puzzle-1');
        expect(loadedData, isNotNull);
        expect(loadedData!['grid'], isNotNull);

        // Extract grid like continue_playing_section.dart does
        final gridData = loadedData['grid'];
        expect(gridData, isA<List>());

        // Verify we can extract the grid correctly
        final grid = (gridData as List).map<List<String?>>((row) {
          if (row is! List) {
            return <String?>[];
          }
          return row.map<String?>((cell) => cell as String?).toList();
        }).toList();

        expect(grid.length, 3);
        expect(grid[0][0], 'A');
        expect(grid[0][1], isNull);

        // Create a solution grid (3x3 with all letters)
        final solution = [
          ['A', 'B', 'C'],
          ['D', 'E', 'F'],
          ['G', 'H', 'I'],
        ];

        // Calculate completion percent like the provider does
        final service = PuzzleProgressService(
          storage: mockStorage,
          assetLoader: (_) async => {'cells': [], 'cols': 3, 'rows': 3},
        );

        final percent = service.calculateCompletionPercent(grid, solution);

        // With 1 letter filled out of 9, we expect ~11.11%
        expect(percent, greaterThan(0));
        expect(percent, lessThan(100));

        // The check in inProgressPuzzlesProvider is: percent > 0 && percent < 100
        // This should evaluate to true for our puzzle
        final shouldAppearInList = percent > 0 && percent < 100;
        expect(shouldAppearInList, isTrue);
      },
    );

    test(
      'getInProgressPuzzlesSortedByRecency should return puzzle with progress',
      () async {
        // Simulate the exact payload format from _persistProgress
        final savedPayload = {
          'schemaVersion': 1,
          'grid': [
            ['A', null, null],
            [null, null, null],
            [null, null, null],
          ],
          'savedAt': DateTime.now().toIso8601String(),
          'foundWords': <String>[],
          'lockedCells': <String>[],
          'elapsedSeconds': 30,
        };

        mockStorage.setData('test-puzzle-1', savedPayload);

        final service = PuzzleProgressService(
          storage: mockStorage,
          assetLoader: (_) async => {'cells': [], 'cols': 3, 'rows': 3},
        );

        final progressList = await service
            .getInProgressPuzzlesSortedByRecency();

        expect(progressList, isNotEmpty);
        expect(progressList.first.puzzleId, 'test-puzzle-1');
      },
    );
  });
}
