import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for virtual keyboard layout preference.
final gameKeyboardLayoutProvider =
    NotifierProvider<KeyboardLayoutNotifier, bool>(KeyboardLayoutNotifier.new);

class KeyboardLayoutNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false = QWERTY by default

  void setIsAzerty({required bool isAzerty}) {
    state = isAzerty;
    _persistIsAzerty(isAzerty);
  }

  Future<void> _persistIsAzerty(bool v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pref_keyboard_azerty', v);
    } on Object {
      // ignore persistence errors
    }
  }

  void toggle() => state = !state;
}
