import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/preference_persistence_service.dart';

/// Provider for keyboard layout preference.
final gameKeyboardLayoutProvider =
    NotifierProvider<KeyboardLayoutNotifier, bool>(KeyboardLayoutNotifier.new);

class KeyboardLayoutNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false = QWERTY by default

  void setIsAzerty({required bool isAzerty}) {
    state = isAzerty;
    ref
        .read(preferencePersistenceServiceProvider)
        .setBool('pref_keyboard_azerty', value: isAzerty);
  }

  void toggle() => setIsAzerty(isAzerty: !state);
}
