import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../puzzle_filter_provider.dart';
import '../filtered_puzzles_provider.dart';

/// A button that opens a bottom sheet for selecting puzzle languages.
class LanguageFilterSelector extends ConsumerWidget {
  const LanguageFilterSelector({super.key});

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

  static String _getLanguageName(String code) =>
      _languages[code]?.name ?? code.toUpperCase();

  static String _getLanguageFlag(String code) => _languages[code]?.flag ?? '🌐';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableLanguages = ref.watch(availableLanguagesProvider).toList()
      ..sort();
    final filterState = ref.watch(puzzleFilterProvider);

    // Don't render if there's only one language available
    if (availableLanguages.length <= 1) {
      return const SizedBox.shrink();
    }

    final selectedLanguages = filterState.selectedLanguages;
    final isAllSelected = selectedLanguages.isEmpty; // Empty implies All

    // Calculate display count
    final count = isAllSelected
        ? availableLanguages.length
        : selectedLanguages.length;

    // Create label text
    final labelText = isAllSelected
        ? 'All Languages ($count)'
        : 'Languages ($count)';

    return OutlinedButton.icon(
      onPressed: () => _showLanguageSelector(context, availableLanguages),
      icon: const Icon(Icons.language, size: 18),
      label: Text(labelText),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        visualDensity: VisualDensity.compact,
        side: BorderSide(
          color: isAllSelected
              ? Colors.grey.shade300
              : Theme.of(context).colorScheme.primary,
        ),
        foregroundColor: isAllSelected
            ? Theme.of(context).textTheme.bodyMedium?.color
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showLanguageSelector(
    BuildContext context,
    List<String> availableLanguages,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          _LanguageSelectionSheet(availableLanguages: availableLanguages),
    );
  }
}

class _LanguageSelectionSheet extends ConsumerWidget {
  final List<String> availableLanguages;

  const _LanguageSelectionSheet({required this.availableLanguages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(puzzleFilterProvider);
    final selectedLanguages = filterState.selectedLanguages;
    final isAllSelected = selectedLanguages.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Select Languages',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableLanguages.length,
            itemBuilder: (context, index) {
              final languageCode = availableLanguages[index];
              final languageName = LanguageFilterSelector._getLanguageName(
                languageCode,
              );
              final languageFlag = LanguageFilterSelector._getLanguageFlag(
                languageCode,
              );

              // Determine if this row is checked
              // If isAllSelected (empty set), then everything is effectively checked.
              // Otherwise check containment.
              final isChecked =
                  isAllSelected || selectedLanguages.contains(languageCode);

              return CheckboxListTile(
                title: Text(languageName),
                secondary: Text(
                  languageFlag,
                  style: const TextStyle(fontSize: 24),
                ),
                value: isChecked,
                onChanged: (_) {
                  ref
                      .read(puzzleFilterProvider.notifier)
                      .toggleLanguage(languageCode);
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(puzzleFilterProvider.notifier).resetLanguages();
                },
                child: const Text('Select All'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
