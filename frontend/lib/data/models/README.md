Modèles de données pour les puzzles (mots-croisés).

Fichiers créés:
- `puzzle.dart` — modèle principal `Puzzle`.
- `puzzle_cell.dart` — modèle `PuzzleCell`.
- `puzzle_entry.dart` — modèle `PuzzleEntry`.

Génération des sérializers (code généré):

Exécuter dans le dossier `frontend`:

```powershell
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Notes:
- Les fichiers `.g.dart` seront créés par `build_runner`.
- Le design utilise `json_annotation`/`json_serializable` ; si vous préférez `freezed`, je peux convertir.
