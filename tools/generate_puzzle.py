#!/usr/bin/env python3
"""
Générateur de puzzles utilisant pycrossword et conversion vers format canonical JSON.

Utilise pleinement les capacités de pycrossword :
- Génération automatique de grilles optimisées
- Génération d'indices via OpenAI (optionnel)
- Support de thèmes et difficultés
- Préparation automatique des mots (normalisation)

Usage:
    python generate_puzzle.py --words WORD1 WORD2 WORD3 --output puzzle.json
    python generate_puzzle.py --words-file words.txt --output puzzle.json --api-token YOUR_KEY
    python generate_puzzle.py --words-file words.txt --theme "animals" --output puzzle.json
"""

import argparse
import json
import sys
import os
from pathlib import Path
from typing import List, Dict, Any, Optional
from pycrossword import (
    generate_crossword,
    prepare_words,
    remove_duplicates,
    OpenAIClient,
    ClueGenerator,
    ClueDifficulty
)


def pycrossword_to_canonical(
    dimensions: tuple,
    placed_words: list,
    puzzle_id: str = "generated",
    metadata: Optional[Dict[str, Any]] = None,
    clues_dict: Optional[Dict[str, List[str]]] = None
) -> Dict[str, Any]:
    """
    Convertit la sortie de pycrossword vers le format canonical JSON.
    
    Args:
        dimensions: (cols, rows) tuple from pycrossword
        placed_words: list of [word, row, col, is_horizontal] from pycrossword
        puzzle_id: identifiant unique du puzzle
        metadata: métadonnées optionnelles (title, author, etc.)
        clues_dict: dictionnaire word -> clues from ClueGenerator (optionnel)
    
    Returns:
        Dict au format canonical JSON
    """
    cols, rows = dimensions
    
    # Initialize cells grid
    cells = []
    grid_state = [[None for _ in range(cols)] for _ in range(rows)]
    
    # Mark all cells as black initially
    for y in range(rows):
        for x in range(cols):
            cells.append({
                "x": x,
                "y": y,
                "is_black": True,
                "solution": None
            })
    
    # Fill in words and mark cells as white
    for word_data in placed_words:
        word, row, col, is_horizontal = word_data
        for i, letter in enumerate(word):
            if is_horizontal:
                x, y = col + i, row
            else:
                x, y = col, row + i
            
            # Update cell
            cell_index = y * cols + x
            cells[cell_index]["is_black"] = False
            cells[cell_index]["solution"] = letter.upper()
            grid_state[y][x] = letter.upper()
    
    # Compute numbering and create entries
    entries = []
    number_map = {}
    current_number = 1
    
    for y in range(rows):
        for x in range(cols):
            if cells[y * cols + x]["is_black"]:
                continue
            
            # Check if this is the start of an across word
            is_start_across = (x == 0 or cells[y * cols + (x - 1)]["is_black"]) and \
                             (x < cols - 1 and not cells[y * cols + (x + 1)]["is_black"])
            
            # Check if this is the start of a down word
            is_start_down = (y == 0 or cells[(y - 1) * cols + x]["is_black"]) and \
                           (y < rows - 1 and not cells[(y + 1) * cols + x]["is_black"])
            
            if is_start_across or is_start_down:
                number_map[f"{y},{x}"] = current_number
                current_number += 1
    
    # Create entries from placed_words with proper numbering
    for word_data in placed_words:
        word, row, col, is_horizontal = word_data
        direction = "across" if is_horizontal else "down"
        number = number_map.get(f"{row},{col}", 0)
        
        # Calculate length
        length = len(word)
        
        # Get clue from generated clues or create placeholder
        clue_text = f"Clue unavailable for {word.upper()}"
        if clues_dict and word in clues_dict:
            # ClueGenerator returns a list of clues, take the first one
            clue_list = clues_dict[word]
            if clue_list and len(clue_list) > 0:
                clue_text = clue_list[0]
        
        entries.append({
            "id": f"{direction[0]}{number}",
            "number": number,
            "direction": direction,
            "x": col,
            "y": row,
            "length": length,
            "answer": word.upper(),
            "clue": clue_text
        })
    
    # Sort entries by number, then by direction (across first)
    entries.sort(key=lambda e: (e["number"], 0 if e["direction"] == "across" else 1))
    
    # Build final puzzle structure
    puzzle = {
        "id": puzzle_id,
        "version": "1.0",
        "metadata": metadata or {
            "title": f"Puzzle {puzzle_id}",
            "author": "pycrossword generator",
            "language": "fr",
            "source_format": "pycrossword"
        },
        "rows": rows,
        "cols": cols,
        "cells": cells,
        "entries": entries
    }
    
    return puzzle


def generate_puzzle_from_words(
    words: List[str],
    max_width: Optional[int] = None,
    max_height: Optional[int] = None,
    seed: Optional[int] = None,
    puzzle_id: str = "generated",
    metadata: Optional[Dict[str, Any]] = None,
    clue_generator: Optional[ClueGenerator] = None
) -> Dict[str, Any]:
    """
    Génère un puzzle à partir d'une liste de mots.
    
    Args:
        words: liste de mots à placer
        max_width: largeur maximale (optionnel)
        max_height: hauteur maximale (optionnel)
        seed: seed pour reproductibilité (optionnel)
        puzzle_id: identifiant du puzzle
        metadata: métadonnées
        clue_generator: générateur d'indices (optionnel, utilise OpenAI)
    
    Returns:
        Dict au format canonical JSON
    """
    # Prepare words using pycrossword utilities
    prepared_words = prepare_words(words, allow_duplicates=False)
    
    # Generate crossword using pycrossword
    dimensions, placed_words = generate_crossword(
        prepared_words,
        x=max_width,
        y=max_height,
        seed=seed
    )
    
    # Generate clues if generator provided
    clues_dict = {}
    if clue_generator:
        placed_word_list = [word_data[0] for word_data in placed_words]
        clues_dict = clue_generator.create(placed_word_list)
    
    # Convert to canonical format
    puzzle = pycrossword_to_canonical(
        dimensions,
        placed_words,
        puzzle_id=puzzle_id,
        metadata=metadata,
        clues_dict=clues_dict
    )
    
    # Add efficiency stats to metadata
    efficiency = (len(placed_words) / len(prepared_words)) * 100
    puzzle["metadata"]["generation_efficiency"] = round(efficiency, 2)
    puzzle["metadata"]["total_words_attempted"] = len(prepared_words)
    puzzle["metadata"]["words_placed"] = len(placed_words)
    
    return puzzle


def main():
    parser = argparse.ArgumentParser(
        description="Génère des puzzles de mots-croisés au format canonical JSON"
    )
    
    # Input options
    input_group = parser.add_mutually_exclusive_group(required=True)
    input_group.add_argument(
        "--words",
        nargs="+",
        help="Liste de mots à placer"
    )
    input_group.add_argument(
        "--words-file",
        type=Path,
        help="Fichier contenant les mots (un par ligne)"
    )
    
    # Generation options
    parser.add_argument(
        "--width",
        type=int,
        help="Largeur maximale de la grille"
    )
    parser.add_argument(
        "--height",
        type=int,
        help="Hauteur maximale de la grille"
    )
    parser.add_argument(
        "--seed",
        type=int,
        help="Seed pour reproductibilité"
    )
    parser.add_argument(
        "--id",
        default="generated",
        help="Identifiant du puzzle"
    )
    parser.add_argument(
        "--title",
        help="Titre du puzzle"
    )
    parser.add_argument(
        "--author",
        default="pycrossword generator",
        help="Auteur du puzzle"
    )
    parser.add_argument(
        "--language",
        default="fr",
        help="Langue du puzzle"
    )
    
    # Clue generation options (using pycrossword ClueGenerator)
    parser.add_argument(
        "--api-token",
        help="OpenAI API token pour générer les indices automatiquement"
    )
    parser.add_argument(
        "--theme",
        default="common",
        help="Thème pour la génération d'indices (ex: 'animals', 'sports', 'common')"
    )
    parser.add_argument(
        "--clue-difficulty",
        choices=["easy", "medium", "hard"],
        default="medium",
        help="Difficulté des indices générés"
    )
    
    # Output options
    parser.add_argument(
        "--output",
        type=Path,
        required=True,
        help="Fichier de sortie JSON"
    )
    parser.add_argument(
        "--pretty",
        action="store_true",
        help="Formater le JSON avec indentation"
    )
    
    args = parser.parse_args()
    
    # Load words
    if args.words:
        words = [w.strip().upper() for w in args.words]
    else:
        with open(args.words_file, 'r', encoding='utf-8') as f:
            words = [line.strip().upper() for line in f if line.strip()]
    
    if not words:
        print("Erreur: Aucun mot fourni", file=sys.stderr)
        sys.exit(1)
    
    print(f"Génération d'un puzzle avec {len(words)} mots...")
    
    # Setup clue generator if API token provided
    clue_generator = None
    if args.api_token:
        print(f"Configuration de la génération d'indices (thème: {args.theme}, difficulté: {args.clue_difficulty})...")
        api_token = args.api_token
        if api_token.lower() == "env":
            api_token = os.environ.get("OPENAI_API_KEY")
            if not api_token:
                print("Erreur: OPENAI_API_KEY non trouvé dans l'environnement", file=sys.stderr)
                sys.exit(1)
        
        try:
            ai_client = OpenAIClient(api_token)
            # Map string difficulty to ClueDifficulty enum
            difficulty_map = {
                "easy": ClueDifficulty.EASY,
                "medium": ClueDifficulty.MEDIUM,
                "hard": ClueDifficulty.HARD
            }
            clue_generator = ClueGenerator(
                ai_client,
                theme=args.theme,
                difficulty=difficulty_map[args.clue_difficulty]
            )
        except Exception as e:
            print(f"Avertissement: Impossible d'initialiser le générateur d'indices: {e}", file=sys.stderr)
            print("Génération sans indices...", file=sys.stderr)
    
    # Build metadata (requires API token for theme)
    metadata = {
        "title": args.title or f"Puzzle {args.id}",
        "author": args.author,
        "language": args.language,
        "source_format": "pycrossword",
        "theme": args.theme if args.api_token else None
    }
    
    # Generate puzzle
    try:
        puzzle = generate_puzzle_from_words(
            words=words,
            max_width=args.width,
            max_height=args.height,
            seed=args.seed,
            puzzle_id=args.id,
            metadata=metadata,
            clue_generator=clue_generator
        )
    except Exception as e:
        print(f"Erreur lors de la génération: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Save to file
    with open(args.output, 'w', encoding='utf-8') as f:
        if args.pretty:
            json.dump(puzzle, f, indent=2, ensure_ascii=False)
        else:
            json.dump(puzzle, f, ensure_ascii=False)
    
    print(f"✓ Puzzle généré: {puzzle['cols']}x{puzzle['rows']}")
    print(f"✓ {puzzle['metadata']['words_placed']}/{puzzle['metadata']['total_words_attempted']} mots placés ({puzzle['metadata']['generation_efficiency']}%)")
    print(f"✓ Sauvegardé dans: {args.output}")


if __name__ == "__main__":
    main()
