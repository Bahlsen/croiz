import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/preference_persistence_service.dart';

/// Provider for global dark mode state.
final appIsDarkProvider = NotifierProvider<AppIsDarkNotifier, bool>(
  AppIsDarkNotifier.new,
);

class AppIsDarkNotifier extends Notifier<bool> {
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
