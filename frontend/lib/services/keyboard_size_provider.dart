import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/preference_persistence_service.dart';

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

  void setSize(KeyboardSize size) {
    state = size;
    ref
        .read(preferencePersistenceServiceProvider)
        .setString('pref_keyboard_size', size.name);
  }
}
