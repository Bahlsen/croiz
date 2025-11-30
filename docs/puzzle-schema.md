# Schéma canonical JSON pour puzzles (résumé)

But: format simple et stable pour l'app Flutter.

- `id` : string — identifiant unique.
- `version` : string — version du puzzle/format.
- `metadata` : object — champs typiques: `title`, `author`, `publisher`, `date` (ISO), `language`, `notes`, `source_format`.
- `dimensions` ou `rows`/`cols` : entiers.
- `cells` : liste d'objets cell (idéalement length = rows * cols). Champs par cellule:
  - `x`, `y` (0-based), `is_black` (bool), `solution` (string|null), `state` (string|null), `rebus` (string|null), `circled` (bool), `shaded` (bool), `barredLeft`/`barredTop` (bool), `annotations`.
- `entries` : liste d'entrées (across/down) avec: `id`, `number` (1-based), `direction` ('across'|'down'), `x`, `y`, `length` (cases), `answer` (optionnel), `clue`, `enumeration`, `rebus_map`, `multi_solution`, `annotations`.
- `clues` : facultatif, groupé par `across` et `down` avec champs `number`, `clue`, `entry_id`.
- `extras` : champ libre pour conserver `original_chunks` (.puz) ou layout PDF refs.

Remarques:
- Utiliser `x,y` 0-based en interne (Flutter), exposer 1-based si nécessaire.
- Conserver `cells` explicites facilite le rendu (CustomPainter / GridView).
- Pour rebus: différencier `cells.length` (cases) et `answer.length` (caractères réels).
