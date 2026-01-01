import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/services/preference_persistence_service.dart';

part 'app_is_dark_provider.g.dart';

/// Provider for global dark mode state.
@Riverpod(keepAlive: true)
class AppIsDarkNotifier extends _$AppIsDarkNotifier {
  @override
  bool build() => false; // light by default

  void setIsDark({required bool isDark}) {
    state = isDark;
    ref
        .read(preferencePersistenceServiceProvider)
        .setBool('pref_is_dark', value: isDark);
  }

  void toggle() => setIsDark(isDark: !state);
}
