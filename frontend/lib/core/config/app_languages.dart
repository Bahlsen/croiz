import 'dart:ui';

/// Configuration for supported languages in the application.
class AppLanguages {
  /// Languages that have full UI localization (ARB files).
  static const Set<String> uiSupported = {'en', 'fr', 'uk'};

  /// Languages supported for puzzle generation (via Gemini).
  /// This can be broader than UI-supported languages.
  static const Set<String> puzzleSupported = {
    'en',
    'fr',
    'uk',
    'es',
    'de',
    'it',
    'pt',
  };

  static const Map<String, ({String name, String flag})> _metadata = {
    'en': (name: 'English', flag: '🇬🇧'),
    'fr': (name: 'Français', flag: '🇫🇷'),
    'uk': (name: 'Українська', flag: '🇺🇦'),
    'es': (name: 'Español', flag: '🇪🇸'),
    'de': (name: 'Deutsch', flag: '🇩🇪'),
    'it': (name: 'Italiano', flag: '🇮🇹'),
    'pt': (name: 'Português', flag: '🇵🇹'),
    'ru': (name: 'Русский', flag: '🇷🇺'),
  };

  /// Returns only the locales that have UI support.
  static List<Locale> get uiLocales => uiSupported.map(Locale.new).toList();

  static String getName(String code) =>
      _metadata[code]?.name ?? code.toUpperCase();

  static String getFlag(String code) => _metadata[code]?.flag ?? '🌐';
}
