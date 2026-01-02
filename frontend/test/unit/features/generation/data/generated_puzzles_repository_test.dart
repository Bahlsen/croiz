import 'package:croiz/features/generation/data/generated_puzzles_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';

class MockBox extends Mock implements Box {}

void main() {
  group('GeneratedPuzzlesRepository', () {
    late GeneratedPuzzlesRepository repository;
    late MockBox mockBox;

    setUp(() {
      mockBox = MockBox();
      repository = GeneratedPuzzlesRepository(box: mockBox);
    });

    test('savePuzzle should store puzzle with source tag', () async {
      final puzzle = {'id': '123', 'title': 'Test'};
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

      await repository.savePuzzle(puzzle);

      verify(
        () => mockBox.put(
          '123',
          any(that: isA<Map>().having((m) => m['source'], 'source', 'local')),
        ),
      ).called(1);
    });

    test('getPuzzle should return map when data exists', () async {
      final puzzle = {'id': '123', 'title': 'Test'};
      when(() => mockBox.get('123')).thenReturn(puzzle);

      final result = await repository.getPuzzle('123');

      expect(result, isNotNull);
      expect(result!['id'], '123');
    });

    test('getPuzzle should return null when data does not exist', () async {
      when(() => mockBox.get('123')).thenReturn(null);

      final result = await repository.getPuzzle('123');

      expect(result, isNull);
    });

    test('deletePuzzle should call box.delete', () async {
      when(() => mockBox.delete(any())).thenAnswer((_) async => {});

      await repository.deletePuzzle('123');

      verify(() => mockBox.delete('123')).called(1);
    });

    test('getAllDescriptors should return list of descriptors', () async {
      final puzzle = {
        'id': '123',
        'metadata': {'title': 'Test Puzzle', 'difficulty': 3, 'language': 'en'},
      };
      when(() => mockBox.keys).thenReturn(['123']);
      when(() => mockBox.get('123')).thenReturn(puzzle);

      final result = await repository.getAllDescriptors();

      expect(result, hasLength(1));
      expect(result[0].id, '123');
      expect(result[0].title, 'Test Puzzle');
      expect(result[0].difficulty, 3);
      expect(result[0].language, 'en');
      expect(result[0].origin, 'generated');
    });

    test('getAllDescriptors should handle missing metadata', () async {
      final puzzle = {'id': '123'};
      when(() => mockBox.keys).thenReturn(['123']);
      when(() => mockBox.get('123')).thenReturn(puzzle);

      final result = await repository.getAllDescriptors();

      expect(result, hasLength(1));
      expect(result[0].title, 'Untitled Puzzle');
      expect(result[0].difficulty, 2);
    });

    test('getAllDescriptors should sort by ID descending', () async {
      final p1 = {'id': 'aaa'};
      final p2 = {'id': 'bbb'};
      when(() => mockBox.keys).thenReturn(['aaa', 'bbb']);
      when(() => mockBox.get('aaa')).thenReturn(p1);
      when(() => mockBox.get('bbb')).thenReturn(p2);

      final result = await repository.getAllDescriptors();

      expect(result, hasLength(2));
      expect(result[0].id, 'bbb');
      expect(result[1].id, 'aaa');
    });
  });
}
