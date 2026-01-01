/// Configuration for supported languages in the application.
class AppLanguages {
  static const Map<String, ({String name, String flag})> supported = {
    'en': (name: 'English', flag: '🇬🇧'),
    'fr': (name: 'Français', flag: '🇫🇷'),
    'uk': (name: 'Українська', flag: '🇺🇦'),
    'es': (name: 'Español', flag: '🇪🇸'),
    'de': (name: 'Deutsch', flag: '🇩🇪'),
    'it': (name: 'Italiano', flag: '🇮🇹'),
    'pt': (name: 'Português', flag: '🇵🇹'),
    'ru': (name: 'Русский', flag: '🇷🇺'),
  };

  static String getName(String code) =>
      supported[code]?.name ?? code.toUpperCase();

  static String getFlag(String code) => supported[code]?.flag ?? '🌐';
}
