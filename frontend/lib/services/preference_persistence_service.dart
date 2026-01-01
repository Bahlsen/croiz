import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for persisting application preferences.
///
/// Centralizes SharedPreferences access to avoid duplication in notifiers.
class PreferencePersistenceService {
  PreferencePersistenceService();

  /// Writes a boolean value to SharedPreferences.
  Future<void> setBool(String key, {required bool value}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } on Object {
      // ignore
    }
  }

  /// Writes an integer value to SharedPreferences.
  Future<void> setInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } on Object {
      // ignore
    }
  }

  /// Writes a string value to SharedPreferences.
  Future<void> setString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } on Object {
      // ignore
    }
  }
}

/// Provider for PreferencePersistenceService.
final preferencePersistenceServiceProvider =
    Provider<PreferencePersistenceService>(
      (ref) => PreferencePersistenceService(),
    );
