import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/services/persistence/preference_persistence_service.dart';

part 'locale_provider.g.dart';

/// Provider for the application locale.
@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() => const Locale('en');

  void setLocale(Locale locale) {
    state = locale;
    ref
        .read(preferencePersistenceServiceProvider)
        .setString('pref_locale', locale.languageCode);
  }
}
