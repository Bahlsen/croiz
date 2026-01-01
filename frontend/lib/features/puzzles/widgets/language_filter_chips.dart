import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../puzzle_filter_provider.dart';
import '../filtered_puzzles_provider.dart';

/// A row of filter chips for selecting puzzle languages.
///
/// Only shows when there are multiple languages available.
class LanguageFilterChips extends ConsumerWidget {
  const LanguageFilterChips({super.key});

  /// Language configuration: code, native name, and flag emoji.
  static const Map<String, ({String name, String flag})> _languages = {
    'en': (name: 'English', flag: '🇬🇧'),
    'fr': (name: 'Français', flag: '🇫🇷'),
    'uk': (name: 'Українська', flag: '🇺🇦'),
    'es': (name: 'Español', flag: '🇪🇸'),
    'de': (name: 'Deutsch', flag: '🇩🇪'),
    'it': (name: 'Italiano', flag: '🇮🇹'),
    'pt': (name: 'Português', flag: '🇵🇹'),
    'ru': (name: 'Русский', flag: '🇷🇺'),
  };

  /// Get the display name for a language code.
  static String _getLanguageName(String code) =>
      _languages[code]?.name ?? code.toUpperCase();

  /// Get the flag emoji for a language code.
  static String _getLanguageFlag(String code) => _languages[code]?.flag ?? '🌐';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(puzzleFilterProvider);
    // Use the derived provider for available languages
    final availableLanguages = ref.watch(availableLanguagesProvider).toList()
      ..sort();

    // Don't render if there's only one language available
    if (availableLanguages.length <= 1) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: availableLanguages.map((languageCode) {
        final isSelected = filterState.selectedLanguages.contains(languageCode);
        final languageName = _getLanguageName(languageCode);
        final languageFlag = _getLanguageFlag(languageCode);

        return FilterChip(
          avatar: Text(languageFlag),
          label: Text(languageName),
          selected: isSelected,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
          onSelected: (_) {
            ref
                .read(puzzleFilterProvider.notifier)
                .toggleLanguage(languageCode);
          },
        );
      }).toList(),
    );
  }
}
