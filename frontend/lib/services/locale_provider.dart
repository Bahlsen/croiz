import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for application locale.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

/// Notifier for managing application locale state.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  /// Sets the application locale.
  void setLocale(Locale v) => state = v;
}
