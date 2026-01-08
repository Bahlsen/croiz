import 'dart:async';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';

/// A fake implementation of PuzzleStorageInterface for testing.
/// Stores data in-memory.
class FakePuzzleStorage implements PuzzleStorageInterface {
  final Map<String, Map<String, dynamic>> _data = {};
  final _controller = StreamController<void>.broadcast();

  Map<String, Map<String, dynamic>> get data => _data;

  @override
  Future<List<String>> getAllKeys() async => _data.keys.toList();

  @override
  Future<Map<String, dynamic>?> load(String id) async {
    print('FakePuzzleStorage: loading $id');
    final entry = _data[id];
    if (entry == null) {
      print('FakePuzzleStorage: $id not found');
      return null;
    }
    // Return a copy to prevent mutation of stored data
    print('FakePuzzleStorage: $id found, data length: ${entry.length}');
    return Map<String, dynamic>.from(entry);
  }

  @override
  Stream<void> get onDataChanged => _controller.stream;

  @override
  Future<void> save(String id, Map<String, dynamic> payload) async {
    print('FakePuzzleStorage: saving $id, keys: ${payload.keys.toList()}');
    _data[id] = payload;
    _controller.add(null);
  }
}
