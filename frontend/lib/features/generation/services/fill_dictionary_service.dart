import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for loading fill dictionaries based on language.
///
/// Fill dictionaries contain common words for a specific language
/// that are used to fill remaining slots in crossword puzzles
/// after theme words have been placed.
class FillDictionaryService {
  FillDictionaryService._();

  static final FillDictionaryService instance = FillDictionaryService._();

  final Map<String, List<String>> _cache = {};

  /// Supported languages with fill dictionaries.
  /// Maps language code to actual dictionary file code (for ru -> uk mapping).
  static const Map<String, String> _languageMapping = {
    'en': 'en',
    'fr': 'fr',
    'es': 'es',
    'de': 'de',
    'it': 'it',
    'pt': 'pt',
    'uk': 'uk',
    'ru': 'ru', // Russian uses its own dictionary now
  };

  /// Load fill dictionary for a specific language.
  ///
  /// Returns a list of words (3+ letters) that can be used to fill
  /// crossword slots. Results are cached for performance.
  Future<List<String>> loadDictionary(String language) async {
    // Map language to dictionary file
    final dictLanguage = _languageMapping[language] ?? 'en';

    // Return cached if available
    if (_cache.containsKey(dictLanguage)) {
      return _cache[dictLanguage]!;
    }

    try {
      final path = 'assets/dictionaries/fill_$dictLanguage.txt';
      final content = await rootBundle.loadString(path);

      final words =
          content
              .split('\n')
              .map((line) {
                var normalized = line.trim().toUpperCase();
                // Normalize: remove spaces, hyphens, apostrophes for multi-word expressions
                // e.g., "ARC-EN-CIEL" -> "ARCENCIEL"
                normalized = normalized.replaceAll(RegExp(r"[\s\-']"), '');
                return normalized;
              })
              .where((word) {
                // Skip empty lines and comments (checking original line isn't needed if word is empty)
                if (word.isEmpty ||
                    word.startsWith('#') ||
                    word.startsWith('*')) {
                  return false;
                }
                // Only include valid words (2+ letters)
                if (word.length < 2) {
                  return false;
                }
                // Validate characters based on language
                return _isValidWord(word, dictLanguage);
              })
              .toSet()
              .toList();

      _cache[dictLanguage] = words;
      return words;
    } on Exception {
      // Return empty list if file not found
      return [];
    }
  }

  /// Validate word characters based on language alphabet.
  bool _isValidWord(String word, String language) {
    // Cyrillic languages
    if (language == 'uk') {
      return word.runes.every(_isCyrillicLetter);
    }

    // Latin-based languages
    return word.runes.every(_isLatinOrAccentedLetter);
  }

  /// Check if rune is a Cyrillic letter (Ukrainian/Russian alphabet).
  bool _isCyrillicLetter(int r) =>
      // Cyrillic uppercase: А-Я (1040-1071)
      // Cyrillic lowercase: а-я (1072-1103)
      // Ukrainian specific: Є, І, Ї, Ґ
      (r >= 0x0410 && r <= 0x042F) || // А-Я
      (r >= 0x0430 && r <= 0x044F) || // а-я
      r == 0x0404 || // Є
      r == 0x0406 || // І
      r == 0x0407 || // Ї
      r == 0x0490 || // Ґ
      r == 0x0454 || // є
      r == 0x0456 || // і
      r == 0x0457 || // ї
      r == 0x0491; // ґ

  /// Check if rune is a Latin letter or accented character.
  bool _isLatinOrAccentedLetter(int r) {
    // Basic Latin uppercase: A-Z (65-90)
    if (r >= 65 && r <= 90) {
      return true;
    }
    // Basic Latin lowercase: a-z (97-122)
    if (r >= 97 && r <= 122) {
      return true;
    }

    // French/Spanish/Portuguese/Italian/German accented letters
    // À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö Ø Ù Ú Û Ü Ý
    if (r >= 0x00C0 && r <= 0x00DD) {
      return true;
    }
    // à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ø ù ú û ü ý ÿ
    if (r >= 0x00E0 && r <= 0x00FF) {
      return true;
    }

    // German ß (Eszett)
    if (r == 0x00DF) {
      return true;
    }

    return false;
  }

  /// Get fill words by length for efficient slot matching.
  Future<Map<int, List<String>>> loadDictionaryByLength(String language) async {
    final words = await loadDictionary(language);
    final byLength = <int, List<String>>{};

    for (final word in words) {
      byLength.putIfAbsent(word.length, () => []).add(word);
    }

    return byLength;
  }

  /// Check if a language has a fill dictionary available.
  static bool hasDictionary(String language) =>
      _languageMapping.containsKey(language);

  /// Get all supported languages.
  static Set<String> get supportedLanguages => _languageMapping.keys.toSet();

  /// Clear cached dictionaries.
  void clearCache() {
    _cache.clear();
  }
}

final fillDictionaryServiceProvider = Provider<FillDictionaryService>(
  (ref) => FillDictionaryService.instance,
  dependencies: [],
);
