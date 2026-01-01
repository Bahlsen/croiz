import 'dart:convert';
// imports cleaned: removed temporary debug imports
import 'package:hive_flutter/hive_flutter.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';
// No SharedPreferences import: migration not required (never deployed).

/// Hive-based implementation of puzzle storage.
///
/// Implements [PuzzleStorageInterface] for use with [PuzzleProgressService].
class HivePuzzleStorage implements PuzzleStorageInterface {
  static const String boxName = 'puzzle_progress';

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<void> openBox() async {
    await Hive.openBox<String>(boxName);
  }

  @override
  Future<Map<String, dynamic>?> load(String id) async {
    final box = Hive.box<String>(boxName);
    final raw = box.get(id);
    if (raw == null) {
      return null;
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> save(String id, Map<String, dynamic> payload) async {
    final box = Hive.box<String>(boxName);
    await box.put(id, jsonEncode(payload));
  }

  @override
  Future<List<String>> getAllKeys() async {
    final box = Hive.box<String>(boxName);
    return box.keys.cast<String>().toList();
  }

  @override
  Stream<void> get onDataChanged {
    final box = Hive.box<String>(boxName);
    return box.watch();
  }
}
