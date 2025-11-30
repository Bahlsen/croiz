# Générateur de Puzzles avec pycrossword

Ce dossier contient des outils Python pour générer des grilles de mots-croisés.

## Installation

```powershell
cd tools
pip install -r requirements.txt
```

## Usage

### Générer depuis une liste de mots

```powershell
python generate_puzzle.py --words SOL ANE ROI TIC --output ../frontend/assets/data/puzzle_simple.json --pretty
```

### Générer depuis un fichier

```powershell
python generate_puzzle.py --words-file words_fr.txt --output ../frontend/assets/data/puzzle_advanced.json --pretty --seed 42
```

### Avec contraintes de dimensions

```powershell
python generate_puzzle.py --words-file words_fr.txt --width 15 --height 15 --output puzzle_15x15.json --pretty
```

### Avec métadonnées custom

```powershell
python generate_puzzle.py --words-file words_fr.txt --output puzzle.json --title "Mon Puzzle" --author "Votre Nom" --id "puzzle-001" --pretty
```

## Options

- `--words WORD1 WORD2 ...` : Liste de mots
- `--words-file FILE` : Fichier texte (un mot par ligne)
- `--width N` : Largeur maximale
- `--height N` : Hauteur maximale
- `--seed N` : Seed pour reproductibilité
- `--id ID` : Identifiant du puzzle
- `--title TITLE` : Titre du puzzle
- `--author AUTHOR` : Auteur
- `--language LANG` : Langue (default: fr)
- `--output FILE` : Fichier de sortie (obligatoire)
- `--pretty` : Formater le JSON avec indentation

## Format de sortie

Le script génère un JSON au format canonical compatible avec l'app Flutter :

```json
{
  "id": "puzzle-001",
  "version": "1.0",
  "metadata": {
    "title": "Mon Puzzle",
    "author": "pycrossword generator",
    "language": "fr",
    "source_format": "pycrossword",
    "generation_efficiency": 85.5,
    "total_words_attempted": 20,
    "words_placed": 17
  },
  "rows": 10,
  "cols": 12,
  "cells": [...],
  "entries": [...]
}
```

## Tests

```powershell
python -m pytest test_generate_puzzle.py -v
```
