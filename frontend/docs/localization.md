# Ajout d'une nouvelle langue dans Croiz

Ce document détaille la procédure pour ajouter le support d'une nouvelle langue dans l'application Croiz.

## 1. Localisation de l'interface (UI)

L'application utilise le package standard Flutter `flutter_localizations` basé sur des fichiers ARB.

### Étapes :
1.  **Créer le fichier ARB** :
    Dans `lib/l10n/`, créez un nouveau fichier nommé `app_<code_langue>.arb` (ex: `app_es.arb` pour l'espagnol).
2.  **Traduire les chaînes** :
    Copiez le contenu de `app_en.arb` dans votre nouveau fichier et remplacez les valeurs par les traductions appropriées.
3.  **Générer les fichiers Dart** :
    L'application est configurée pour générer les fichiers de localisation automatiquement. Si ce n'est pas le cas, vous pouvez lancer :
    ```bash
    flutter gen-l10n
    ```
    *Note : Actuellement, les fichiers générés sont versionnés dans `lib/l10n/`.*

> [!IMPORTANT]
> **Cas particulier du Russe (ru)** : 
> Bien que la langue soit affichée comme "Русский" dans l'UI, toutes les traductions internes et la logique de génération doivent correspondre à l'**Ukrainien**. 
> Si vous ajoutez des mots ou des traductions pour le Russe, ils doivent être saisis en Ukrainien.

## 2. Configuration de l'application

Il est nécessaire d'enregistrer la nouvelle langue dans le fichier de configuration central.

### Fichier : `lib/core/config/app_languages.dart`

1.  Ajoutez le code de la langue à l'ensemble `uiSupported` :
    ```dart
    static const Set<String> uiSupported = {'en', 'fr', 'uk', 'es'};
    ```
2.  (Optionnel) Ajoutez le code à `puzzleSupported` si vous souhaitez autoriser la génération de puzzles dans cette langue :
    ```dart
    static const Set<String> puzzleSupported = {
      'en', 'fr', 'uk', 'es', ...
    };
    ```
3.  Ajoutez les métadonnées (nom et drapeau) dans la map `_metadata` :
    ```dart
    'es': (name: 'Español', flag: '🇪🇸'),
    ```

## 3. Clavier Virtuel (Pour les langues non-latines)

Si la langue utilise un alphabet spécifique (ex: Grec, Russe, Bulgare), vous devez configurer le clavier virtuel.

### Étapes :
1.  **Définir le layout** :
    Dans `lib/features/game/widgets/keyboard/virtual_keyboard.dart`, ajoutez une constante pour le layout (ex: `static const List<List<String>> spanishLayout = ...`).
2.  **Appliquer le layout** :
    Dans `lib/features/game/widgets/bottom/crossword_controls_bar.dart`, mettez à jour la logique de sélection dans la méthode `build` :
    ```dart
    final isSpanish = language == 'es';
    final layout = isSpanish 
        ? VirtualKeyboard.spanishLayout 
        : (isCyrillic ? ...);
    ```

## 4. Adaptation de l'algorithme de génération

L'ajout d'une langue pour la génération nécessite deux adaptations majeures pour s'assurer que les puzzles sont de qualité.

### A. Placement des mots (Poids des lettres)
**Fichier : `lib/features/generation/services/grid_generator.dart`**

L'algorithme de placement doit connaître la fréquence/difficulté des lettres pour optimiser les intersections.
1.  **Mettre à jour `_languageWeights`** : Ajoutez une entrée avec le poids (1 à 10) de chaque lettre (basé sur le score Scrabble).
    ```dart
    'it': { 'A': 1, 'E': 1, ..., 'Z': 10 },
    ```
2.  **Mapping du code langue** : Si nécessaire, mappez les variantes (ex: `ru` -> `uk`) dans la méthode `_getWeights`.

### B. Instructions de génération (Gemini)
**Fichier : `lib/features/generation/services/gemini_service.dart`**

Le service doit savoir comment demander à l'IA de générer des mots valides.
1.  **Nom de la langue** : Mappez le code ISO au nom complet dans `langNames`.
2.  **Contraintes de normalisation** : Définissez dans `langConstraints` comment l'IA doit formater les mots (ex: suppression des accents, conservation de lettres spéciales comme le `Ñ`, conversion des Umlauts).
3.  **Mapping spécifique** : Pour le Russe, assurez-vous de mapper `ru` vers `uk` avant de sélectionner le nom et les contraintes.

## 5. Données des Puzzles (Facultatif)

Si vous souhaitez ajouter des grilles "officielles" (fixes) pour cette langue :
1.  Créez un dossier dans `assets/data/<source>/`.
2.  Ajoutez vos fichiers JSON de puzzles.
3.  Référencez le dossier dans la section `assets` du `pubspec.yaml`.
4.  Mettez à jour `lib/features/game/providers/puzzle_loader_provider.dart` pour inclure cette nouvelle source.

## Impacts potentiels

- **Police d'écriture** : L'interface utilise Google Fonts. Pour certaines langues (ex: Arabe, Thaï), il faudra peut-être ajuster la police dans `lib/core/theme.dart` pour garantir le support des glyphes.
- **Accessibilité** : N'oubliez pas de vérifier les descriptions sémantiques (ex: `letterLabel`) dans les fichiers ARB pour la lecture d'écran.
