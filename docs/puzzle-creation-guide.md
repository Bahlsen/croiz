# Guide : Créer et Charger un Puzzle JSON

## Format JSON Canonical

Structure minimale requise :

```json
{
  "id": "unique-id",
  "version": "1.0",
  "metadata": {
    "title": "Titre du puzzle",
    "author": "Auteur",
    "language": "fr"
  },
  "rows": 5,
  "cols": 5,
  "cells": [
    {"x": 0, "y": 0, "is_black": false, "solution": "S"},
    {"x": 1, "y": 0, "is_black": false, "solution": "O"},
    {"x": 2, "y": 0, "is_black": true},
    ...
  ],
  "entries": [
    {
      "number": 1,
      "direction": "across",
      "x": 0,
      "y": 0,
      "length": 2,
      "answer": "SO",
      "clue": "Note de musique (2)"
    }
  ]
}
```

## Champs détaillés

### `cells` (array, obligatoire)
Chaque cellule doit avoir :
- **`x`** : colonne (0-based)
- **`y`** : ligne (0-based)
- **`is_black`** : true = case noire, false = case blanche
- **`solution`** : lettre(s) de la solution (optionnel, pour validation)

Champs optionnels avancés :
- **`rebus`** : texte multi-caractères (ex: "FL" dans une case)
- **`circled`** : true si case cerclée
- **`shaded`** : true si case ombrée

### `entries` (array, obligatoire)
Chaque entrée (mot horizontal/vertical) doit avoir :
- **`number`** : numéro de l'indice (1-based)
- **`direction`** : `"across"` (horizontal) ou `"down"` (vertical)
- **`x`** : colonne de départ (0-based)
- **`y`** : ligne de départ (0-based)
- **`length`** : nombre de cases
- **`answer`** : solution complète (optionnel)
- **`clue`** : texte de l'indice

## Algorithme de numérotation

La numérotation suit la convention standard :
1. Parcourir la grille de gauche à droite, haut en bas
2. Numéroter une case si elle est **blanche** ET :
   - Elle commence un mot horizontal (case à gauche noire ou bord gauche) **OU**
   - Elle commence un mot vertical (case au-dessus noire ou bord haut)
3. Une case peut avoir deux entrées (across + down) avec le même numéro

Exemple 3x3 :
```
A B #
C # D
E F G
```
- Case (0,0) = numéro 1 (across: AB, down: ACE)
- Case (2,1) = numéro 2 (down: DG)
- Case (0,2) = numéro 3 (across: EFG)
- Case (1,2) = numéro 4 (down: BF)

## Créer un puzzle étape par étape

### 1. Définir la structure
Décidez dimensions (rows x cols) et placement des cases noires.

### 2. Générer les cells
Script Python exemple :
```python
import json

rows, cols = 5, 5
cells = []
for y in range(rows):
    for x in range(cols):
        is_black = (x == 3 and y == 0)  # exemple: une case noire
        solution = "A" if not is_black else None
        cells.append({"x": x, "y": y, "is_black": is_black, "solution": solution})

puzzle = {
    "id": "my-puzzle-001",
    "version": "1.0",
    "metadata": {"title": "Mon Puzzle", "author": "Moi"},
    "rows": rows,
    "cols": cols,
    "cells": cells,
    "entries": []
}

with open("my_puzzle.json", "w") as f:
    json.dump(puzzle, f, indent=2)
```

### 3. Calculer les entrées
Utilisez `PuzzleGenerator.computeEntriesFromCells()` (Dart) ou implémentez en Python.

### 4. Ajouter les indices
Éditez manuellement le JSON pour ajouter les clues :
```json
{
  "number": 1,
  "direction": "across",
  "x": 0,
  "y": 0,
  "length": 3,
  "answer": "SOL",
  "clue": "Astre du jour (3)"
}
```

## Tester votre puzzle

### 1. Placer le fichier
```
frontend/assets/data/my_puzzle.json
```

### 2. Mettre à jour le provider
Dans `game_providers.dart` :
```dart
final puzzleLoaderProvider = FutureProvider<GameBoard>((ref) async {
  return await loadPuzzleFromAsset('assets/data/my_puzzle.json');
});
```

### 3. Lancer l'app
```powershell
cd frontend
flutter run -d windows
```

### 4. Pré-remplir pour tests (optionnel)
Dans `puzzle_converter.dart`, appelez avec flag :
```dart
PuzzleConverter.puzzleToGameBoard(puzzle, preFillSolutions: true)
```

## Outils recommandés

### Validation JSON
```powershell
# Vérifier syntaxe JSON
Get-Content assets/data/my_puzzle.json | ConvertFrom-Json
```

### Tests unitaires
```dart
test('my puzzle loads correctly', () {
  final puzzle = Puzzle.fromJson(jsonDecode(myPuzzleString));
  expect(puzzle.rows, 5);
  expect(puzzle.cells.length, 25);
});
```

## Formats avancés

### Rebus (multi-caractères)
```json
{"x": 2, "y": 3, "is_black": false, "solution": "FL", "rebus": "FL"}
```

### Cases cerclées (thème)
```json
{"x": 1, "y": 1, "is_black": false, "solution": "A", "circled": true}
```

### Énumération (longueur affichée)
```json
{
  "number": 5,
  "direction": "across",
  "x": 0,
  "y": 2,
  "length": 2,
  "answer": "RE",
  "clue": "Note musicale (2)",
  "enumeration": "(2)"
}
```

## Importation en masse de fichiers .xd

Vous pouvez importer un dossier d'exports XD (.xd) et convertir/valider automatiquement
les puzzles au format canonical JSON en utilisant le script `tools/bulk_import_xd.py`.

Exemple d'utilisation :

```powershell
cd tools
python bulk_import_xd.py --src "C:/Users/frede/Downloads/xd-puzzles/gxd" --dest ../frontend/assets/data --group-by source-folder --recursive --pretty --report ../import_report.json
```

- **--src** : dossier source contenant les fichiers `.xd`.
- **--dest** : dossier de destination (par défaut `../frontend/assets/data`).
- **--group-by source-folder** : préserve la hiérarchie des sous-dossiers source dans `assets/data`.
- **--recursive** : cherche récursivement les `.xd`.
- **--pretty** : sauvegarde le JSON avec indentation.
 - **--report** : écrit un fichier JSON récapitulatif des importations et validations.
 - **--stop-on-failure** : arrête l'import à la première erreur (utile pour debugging).
 - **--move-original** : déplace les `.xd` traités dans un sous-dossier `imported` ou `failed` selon le résultat.

Le script utilise `tools/xd_to_canonical.py` pour la conversion et `tools/validate_xd_json.py` pour la vérification.
En cas d'échec, le script retourne une erreur et imprime les différences de validation. Utilisez `--stop-on-failure` pour interrompre au premier problème et `--move-original` pour séparer les fichiers valides/invalides.

Le fichier de rapport JSON contient un tableau d'objets avec au minimum les clés :
- `xd`: chemin du fichier source `.xd`.
- `json`: chemin du fichier `.json` créé.
- `ok`: booléen indiquant si la validation a réussi.
- `log`: sortie textuelle du validateur ou message d'erreur.
- `details`: objet comprenant `parsed`, `parse_error`, `validator_returncode`, `validator_stdout`, `validator_stderr`.


## Dépannage

### Erreur "Target of URI hasn't been generated"
Lancez build_runner :
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### Puzzle ne se charge pas
Vérifiez les logs :
```dart
final puzzleAsync = ref.watch(puzzleLoaderProvider);
puzzleAsync.when(
  data: (board) => print('Loaded: ${board.title}'),
  loading: () => print('Loading...'),
  error: (e, st) => print('Error: $e'),
);
```

### Cases mal numérotées
Validez votre JSON avec le helper :
```dart
final entries = PuzzleGenerator.computeEntriesFromCells(puzzle);
print('Expected ${entries.length} entries');
```
