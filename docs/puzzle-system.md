# Système de Puzzles Dynamiques

## Vue d'ensemble

Le système permet de charger des grilles de mots-croisés depuis des fichiers JSON (format canonique) au lieu d'utiliser des prototypes en dur.

## Architecture

### Modèles de données (`lib/data/models/`)

- **`Puzzle`** : modèle principal (id, metadata, rows, cols, cells, entries)
- **`PuzzleCell`** : cellule individuelle (x, y, is_black, solution, rebus, circled, etc.)
- **`PuzzleEntry`** : entrée de mot (number, direction, x, y, length, answer, clue)

Tous utilisent `json_serializable` pour sérialisation automatique.

### Convertisseur (`lib/core/puzzle_converter.dart`)

`PuzzleConverter.puzzleToGameBoard(puzzle, preFillSolutions: false)` transforme un `Puzzle` en `GameBoard` (entité UI).

- Construit les matrices `grid` et `blackCells` depuis `puzzle.cells`
- Extrait les indices depuis `puzzle.entries`
- Optionnellement pré-remplit les solutions (pour tests)

### Providers (`lib/features/game/game_providers.dart`)

- **`puzzleLoaderProvider`** : `FutureProvider` qui charge le puzzle depuis `assets/data/sample_5x5.json`
- **`gameBoardProvider`** : `StateNotifierProvider` qui utilise le puzzle chargé (fallback vers grille vide si erreur)

## Utilisation

### 1. Ajouter un puzzle JSON

Placez vos fichiers JSON dans `assets/data/` (ex: `my_puzzle.json`).

Exemple minimal (3x3) :
```json
{
  "id": "puzzle-001",
  "version": "1.0",
  "metadata": {"title": "Mini", "author": "You", "language": "fr"},
  "rows": 3,
  "cols": 3,
  "cells": [
    {"x": 0, "y": 0, "is_black": false, "solution": "A"},
    {"x": 1, "y": 0, "is_black": false, "solution": "B"},
    {"x": 2, "y": 0, "is_black": true},
    ...
  ],
  "entries": [
    {"number": 1, "direction": "across", "x": 0, "y": 0, "length": 2, "answer": "AB", "clue": "First two"}
  ]
}
```

### 2. Charger depuis un fichier custom

Modifiez `game_providers.dart` :

```dart
final puzzleLoaderProvider = FutureProvider<GameBoard>((ref) async {
  return await loadPuzzleFromAsset('assets/data/my_puzzle.json');
});
```

Ou créez un provider paramétré :

```dart
final puzzleProvider = FutureProvider.family<GameBoard, String>((ref, assetPath) async {
  return await loadPuzzleFromAsset(assetPath);
});

// Usage:
ref.watch(puzzleProvider('assets/data/puzzle_easy_001.json'));
```

### 3. Générer les fichiers `.g.dart`

Si vous modifiez les modèles :

```powershell
cd frontend
flutter pub run build_runner build --delete-conflicting-outputs
```

## Formats supportés

- **JSON canonique** (natif)
- **`.puz`** (via convertisseur Python — à venir)
- **`.ipuz`** (JSON direct, mapping simple)

Voir `docs/puzzle-schema.md` pour spécification complète.

## Tests

```powershell
cd frontend
flutter test test/unit/puzzle_converter_test.dart
```

## Prochaines étapes

- [ ] Ajouter loader de puzzles depuis API REST
- [ ] Implémenter cache local (sqflite/Hive)
- [ ] Support rebus et cases cerclées dans UI
- [ ] Convertisseur `.puz -> JSON` (Python script)
- [ ] Liste de puzzles avec filtrage (difficulté, langue, etc.)
