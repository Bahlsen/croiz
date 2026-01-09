import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/services/persistence/preference_persistence_service.dart';

part 'keyboard_size_provider.g.dart';

/// Available sizes for the virtual keyboard.
enum KeyboardSize { small, medium, large }

/// Provider for keyboard size preference.
@Riverpod(keepAlive: true, dependencies: [preferencePersistenceService])
class KeyboardSizeNotifier extends _$KeyboardSizeNotifier {
  @override
  KeyboardSize build() => KeyboardSize.medium;

  void setSize(KeyboardSize size) {
    state = size;
    ref
        .read(preferencePersistenceServiceProvider)
        .setString('pref_keyboard_size', size.name);
  }
}

// Compatibility alias
final gameKeyboardSizeProvider = keyboardSizeProvider;
