# Adding a New Language to Croiz

This document details the procedure for adding support for a new language in the Croiz application.

## Overview

Adding a new language involves several components:
1. **UI Localization** - Translating interface text
2. **App Configuration** - Registering the language
3. **Virtual Keyboard** - For non-Latin alphabets (Cyrillic, Greek, etc.)
4. **Puzzle Generation** - Language-specific word weights and fill dictionaries
5. **Gemini Instructions** - Language-specific generation prompts

## 1. UI Localization

The application uses Flutter's standard `flutter_localizations` package with ARB files.

### Steps:

1. **Create the ARB file**:
   In `lib/l10n/`, create a new file named `app_<language_code>.arb` (e.g., `app_es.arb` for Spanish).

2. **Translate the strings**:
   Copy the content of `app_en.arb` into your new file and replace the values with appropriate translations.

3. **Generate Dart files**:
   The application is configured to generate localization files automatically. If needed, you can run:
   ```bash
   flutter gen-l10n
   ```
   *Note: Currently, generated files are versioned in `lib/l10n/`.*

> [!IMPORTANT]
> **Special Case: Russian (ru)**:
> Although displayed as "Русский" in the UI, all internal translations and generation logic should correspond to **Ukrainian**.
> If you add words or translations for Russian, they must be entered in Ukrainian.

## 2. App Configuration

Register the new language in the central configuration file.

### File: `lib/core/config/app_languages.dart`

1. Add the language code to the `uiSupported` set:
   ```dart
   static const Set<String> uiSupported = {'en', 'fr', 'uk', 'es'};
   ```

2. (Optional) Add the code to `puzzleSupported` if you want to allow puzzle generation in this language:
   ```dart
   static const Set<String> puzzleSupported = {
     'en', 'fr', 'uk', 'es', ...
   };
   ```

3. Add metadata (name and flag) to the `_metadata` map:
   ```dart
   'es': (name: 'Español', flag: '🇪🇸'),
   ```

## 3. Virtual Keyboard (For non-Latin languages)

If the language uses a specific alphabet (e.g., Greek, Russian, Bulgarian), you must configure the virtual keyboard.

### Steps:

1. **Define the layout**:
   In `lib/features/game/widgets/keyboard/virtual_keyboard.dart`, add a constant for the layout:
   ```dart
   static const List<List<String>> spanishLayout = [
     ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
     ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ñ'],
     ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
   ];
   ```

2. **Apply the layout**:
   In `lib/features/game/widgets/bottom/crossword_controls_bar.dart`, update the selection logic in the `build` method:
   ```dart
   final isSpanish = language == 'es';
   final layout = isSpanish
       ? VirtualKeyboard.spanishLayout
       : (isCyrillic ? VirtualKeyboard.cyrillicLayout : VirtualKeyboard.defaultLayout);
   ```

### Currently Supported Keyboard Layouts:

| Language | Layout | Special Characters |
|----------|--------|-------------------|
| English | QWERTY | None |
| French | QWERTY | Accented letters via long-press |
| Spanish | QWERTY + Ñ | Ñ on second row |
| German | QWERTY | ÄÖÜß via long-press |
| Italian | QWERTY | Accented letters via long-press |
| Portuguese | QWERTY | Accented letters via long-press |
| Ukrainian | ЙЦУКЕН | Full Cyrillic layout |
| Russian | ЙЦУКЕН | Maps to Ukrainian layout |

## 4. Puzzle Generation Adaptation

Adding a language for generation requires two major adaptations to ensure quality puzzles.

### A. Word Placement (Letter Weights)

**File: `lib/features/generation/services/grid_generator.dart`**

The placement algorithm needs to know letter frequency/difficulty to optimize intersections.

1. **Update `_languageWeights`**: Add an entry with the weight (1 to 10) of each letter (based on Scrabble scores):
   ```dart
   'it': { 'A': 1, 'E': 1, ..., 'Z': 10 },
   ```

2. **Language code mapping**: If necessary, map variants (e.g., `ru` -> `uk`) in the `_getWeights` method.

### B. Fill Dictionary

**File: `assets/dictionaries/fill_<lang>.txt`**

Create a fill dictionary with common words (3-8 letters) for the language. This improves intersection potential.

**Current fill dictionaries:**
- `fill_en.txt` - English
- `fill_fr.txt` - French
- `fill_es.txt` - Spanish
- `fill_de.txt` - German
- `fill_it.txt` - Italian
- `fill_pt.txt` - Portuguese
- `fill_uk.txt` - Ukrainian (also used for Russian)

**Dictionary format:**
```
# Comments start with #
WORD1
WORD2
WORD3
```

**Update the service:**
In `lib/features/generation/services/fill_dictionary_service.dart`, add the language mapping:
```dart
static const Map<String, String> _languageMapping = {
  'en': 'en',
  'fr': 'fr',
  'es': 'es',
  // ... add your language
  'xx': 'xx', // New language
};
```

### C. Generation Instructions (Gemini)

**File: `lib/features/generation/services/gemini_service.dart`**

The service must know how to ask the AI to generate valid words.

1. **Language name**: Map the ISO code to full name in `langNames`:
   ```dart
   'es': 'Spanish',
   ```

2. **Normalization constraints**: Define in `langConstraints` how the AI should format words (e.g., remove accents, preserve special letters like `Ñ`, convert Umlauts):
   ```dart
   'es': 'Use only uppercase Spanish letters. The Ñ character is allowed.',
   ```

3. **Specific mapping**: For Russian, ensure `ru` maps to `uk` before selecting name and constraints.

## 5. Puzzle Data (Optional)

To add "official" (fixed) puzzles for this language:

1. Create a folder in `assets/data/<source>/`.
2. Add your puzzle JSON files.
3. Reference the folder in the `assets` section of `pubspec.yaml`.
4. Update `lib/features/game/providers/puzzle_loader_provider.dart` to include this new source.

## 6. Testing

After adding a new language:

1. **Run analysis**:
   ```bash
   flutter analyze
   ```

2. **Run tests**:
   ```bash
   flutter test
   ```

3. **Manual testing**:
   - Switch UI language and verify all strings are translated
   - Generate a puzzle in the new language
   - Verify keyboard layout works correctly
   - Check that letters display properly in the grid

## Potential Impacts

- **Font**: The interface uses Google Fonts. For some languages (e.g., Arabic, Thai), you may need to adjust the font in `lib/core/theme.dart` to ensure glyph support.

- **Accessibility**: Don't forget to verify semantic descriptions (e.g., `letterLabel`) in ARB files for screen readers.

- **RTL Languages**: Arabic and Hebrew require right-to-left (RTL) layout support. This would need additional configuration in the theme and widget layouts.

## Language Support Matrix

| Language | Code | UI | Puzzles | Keyboard | Fill Dict |
|----------|------|----|---------| ---------|-----------|
| English | en | ✅ | ✅ | QWERTY | ✅ |
| French | fr | ✅ | ✅ | QWERTY | ✅ |
| Spanish | es | ✅ | ✅ | QWERTY+Ñ | ✅ |
| German | de | ✅ | ✅ | QWERTY | ✅ |
| Italian | it | ✅ | ✅ | QWERTY | ✅ |
| Portuguese | pt | ✅ | ✅ | QWERTY | ✅ |
| Ukrainian | uk | ✅ | ✅ | Cyrillic | ✅ |
| Russian | ru | ✅ | ✅ | Cyrillic | ✅ (uses uk) |

## Checklist for Adding a New Language

- [ ] Create ARB file (`lib/l10n/app_<code>.arb`)
- [ ] Add to `uiSupported` in `app_languages.dart`
- [ ] Add to `puzzleSupported` in `app_languages.dart`
- [ ] Add metadata (name, flag) in `app_languages.dart`
- [ ] Create keyboard layout (if non-Latin)
- [ ] Update keyboard selection logic
- [ ] Add letter weights to grid generator
- [ ] Create fill dictionary (`assets/dictionaries/fill_<code>.txt`)
- [ ] Add language mapping in `fill_dictionary_service.dart`
- [ ] Add Gemini language name and constraints
- [ ] Run tests
- [ ] Manual verification
