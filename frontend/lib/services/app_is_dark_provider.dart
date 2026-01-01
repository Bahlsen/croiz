import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for application theme mode.
final appIsDarkProvider = NotifierProvider<AppIsDarkNotifier, bool>(
  AppIsDarkNotifier.new,
);

class AppIsDarkNotifier extends Notifier<bool> {
  @override
  bool build() => false; // light theme by default

  void setIsDark({required bool isDark}) {
    state = isDark;
    _persistIsDark(isDark);
  }

  Future<void> _persistIsDark(bool v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pref_is_dark', v);
    } on Object {
      // ignore
    }
  }

  void toggle() => state = !state;
}
