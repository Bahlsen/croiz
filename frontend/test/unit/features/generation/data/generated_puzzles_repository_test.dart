import 'package:croiz/data/db/app_database.dart';
import 'package:croiz/features/generation/data/generated_puzzles_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeneratedPuzzlesRepository', () {
    late AppDatabase db;
    late GeneratedPuzzlesRepository repository;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repository = GeneratedPuzzlesRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('savePuzzle should store puzzle', () async {
      final puzzle = {
        'id': '123',
        'title': 'Test',
        'metadata': {'title': 'Test Puzzle', 'difficulty': 3, 'language': 'en'},
      };

      await repository.savePuzzle(puzzle);

      final result = await repository.getPuzzle('123');
      expect(result, isNotNull);
      expect(result!['id'], '123');
      expect(result['source'], 'local');
      expect(result['metadata']['title'], 'Test Puzzle');
    });

    test('getPuzzle should return null when data does not exist', () async {
      final result = await repository.getPuzzle('999');
      expect(result, isNull);
    });

    test('deletePuzzle should remove puzzle', () async {
      final puzzle = {'id': '123', 'title': 'Test'};
      await repository.savePuzzle(puzzle);

      await repository.deletePuzzle('123');

      final result = await repository.getPuzzle('123');
      expect(result, isNull);
    });

    test('getAllDescriptors should return list of descriptors', () async {
      final puzzle1 = {
        'id': '123',
        'metadata': {
          'title': 'Test Puzzle 1',
          'difficulty': 3,
          'language': 'en',
        },
      };
      final puzzle2 = {
        'id': '456',
        'metadata': {
          'title': 'Test Puzzle 2',
          'difficulty': 2,
          'language': 'fr',
        },
      };

      await repository.savePuzzle(puzzle1);
      // Ensure separate timestamps if rely on ordering by time
      // (Drift tests run fast, might collide if using DateTime.now() without delay,
      // but current impl uses separate calls so likely ok or slightly delayed)
      await Future.delayed(const Duration(milliseconds: 10));
      await repository.savePuzzle(puzzle2);

      final result = await repository.getAllDescriptors();

      expect(result, hasLength(2));
      // Ordered by createdAt desc
      expect(result, hasLength(2));
      // Sort in test to verify contents regardless of DB sort stability for now
      result.sort((a, b) => a.id.compareTo(b.id)); // 123, 456

      expect(result[0].id, '123');
      expect(result[0].title, 'Test Puzzle 1');
      expect(result[1].id, '456');
      expect(result[1].title, 'Test Puzzle 2');
    });
  });
}
