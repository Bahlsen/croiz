import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
// No SharedPreferences import: migration not required (never deployed).

class HivePuzzleStorage {
  static const String boxName = 'puzzle_progress';

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<void> openBox() async {
    await Hive.openBox<String>(boxName);
  }

  static Future<Map<String, dynamic>?> load(String id) async {
    final box = Hive.box<String>(boxName);
    final raw = box.get(id);
    if (raw == null) {
      return null;
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> save(String id, Map<String, dynamic> payload) async {
    final box = Hive.box<String>(boxName);
    await box.put(id, jsonEncode(payload));
  }
}
