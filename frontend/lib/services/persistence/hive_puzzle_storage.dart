import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
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
    if (kDebugMode) {
      try {
        developer.log('Hive box open=${box.isOpen} keys=${box.keys}', name: 'HivePuzzleStorage');
      } on Object {
        /* ignore: best-effort logging */
      }
    }
    final raw = box.get(id);
    if (kDebugMode) {
      try {
        developer.log('Hive.box.get($id) -> $raw', name: 'HivePuzzleStorage');
      } on Object {
        /* ignore: best-effort logging */
      }
    }
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
