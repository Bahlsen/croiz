import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/preference_persistence_service.dart';

/// Provider for the application locale.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void setLocale(Locale locale) {
    state = locale;
    ref
        .read(preferencePersistenceServiceProvider)
        .setString('pref_locale', locale.languageCode);
  }
}
