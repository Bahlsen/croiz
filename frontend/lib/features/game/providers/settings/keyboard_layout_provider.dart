import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/services/persistence/preference_persistence_service.dart';

part 'keyboard_layout_provider.g.dart';

/// Provider for keyboard layout preference.
@Riverpod(keepAlive: true)
class KeyboardLayoutNotifier extends _$KeyboardLayoutNotifier {
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

// Compatibility alias
final gameKeyboardLayoutProvider = keyboardLayoutProvider;
