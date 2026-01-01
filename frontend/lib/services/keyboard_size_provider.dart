import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available sizes for the virtual keyboard.
enum KeyboardSize { small, medium, large }

/// Provider for keyboard size preference.
final gameKeyboardSizeProvider =
    NotifierProvider<KeyboardSizeNotifier, KeyboardSize>(
      KeyboardSizeNotifier.new,
    );

class KeyboardSizeNotifier extends Notifier<KeyboardSize> {
  @override
  KeyboardSize build() => KeyboardSize.medium;

  void setSize(KeyboardSize v) {
    state = v;
    _persistSize(v);
  }

  Future<void> _persistSize(KeyboardSize v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_keyboard_size', v.name);
    } on Object {
      // ignore
    }
  }
}
