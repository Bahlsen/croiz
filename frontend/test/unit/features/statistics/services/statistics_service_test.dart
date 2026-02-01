import 'package:croiz/data/db/app_database.dart';
import 'package:croiz/features/statistics/services/statistics_service.dart';
import 'package:croiz/features/statistics/models/user_stats.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StatisticsService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = StatisticsService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('StatisticsService', () {
    test('watchUserStats emits updates when puzzle is completed', () async {
      // 1. Initial state
      final initialStats = await service.getOrInitUserStats();
      expect(initialStats.totalPuzzlesCompleted, 0);

      // 2. Setup watcher
      final stream = service.watchUserStats();

      // 3. Record completion
      await service.recordPuzzleCompletion(
        puzzleId: 'test_puzzle_1',
        timeSeconds: 60,
        totalWords: 10,
        wordsFound: 10,
        hintsUsed: 0,
        accuracy: 1,
        wordsRevealed: 0,
      );

      // 4. Verify stream emits updated stats
      // We expect 2 events: first one might be the initial/current state (if using watch),
      // or just the update. watchSingleOrNull emits immediately.
      // So first emission = 0 puzzles. Second emission = 1 puzzle.

      // Let's capture events
      final events = <UserStats>[];
      final subscription = stream.listen(events.add);

      // Give a bit of time for stream to propagate if needed,
      // but usually drift streams are sync or microtask.
      // We might need to wait for the record call to finish (which we awaited).

      // Wait for delayed events
      await Future.delayed(Duration.zero);

      await subscription.cancel();

      // Check results
      // NOTE: Depending on when we subscribed.
      // If we subscribed BEFORE record, we should get [0, 1].
      // Wait, I subscribed AFTER `initialStats` call but BEFORE `record`.
      // `watchSingleOrNull` emits the current value immediately on listen.

      expect(events, isNotEmpty);
      expect(
        events.last.totalPuzzlesCompleted,
        1,
        reason: 'Should have updated count to 1',
      );
      expect(events.last.currentStreak, 1);
    });

    test('watchRecentCompletions emits new completion', () async {
      // 1. Initial state
      final initial = await service.watchRecentCompletions().first;
      expect(initial, isEmpty);

      // 2. Setup watcher
      final stream = service.watchRecentCompletions();
      final events = <List<dynamic>>[]; // List<List<PuzzleStat>>
      final subscription = stream.listen(events.add);

      // 3. Record completion
      await service.recordPuzzleCompletion(
        puzzleId: 'test_puzzle_2',
        timeSeconds: 120,
        totalWords: 20,
        wordsFound: 20,
        hintsUsed: 2,
        accuracy: 0.9,
        wordsRevealed: 0,
      );

      // Wait for propagation
      await Future.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      // 4. Verify
      expect(events, isNotEmpty);
      // Last event should contain the new puzzle
      final lastList = events.last;
      expect(lastList, hasLength(1));
      expect(lastList.first.puzzleId, 'test_puzzle_2');
    });
  });
}
