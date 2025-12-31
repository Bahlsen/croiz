#!/usr/bin/env python3
"""
Sample answers from the Hugging Face `albertxu/CrosswordQA` dataset and
generate crossword puzzles using either pycrossword or a simple fallback packer.

Usage:
    python import_and_generate.py --num-puzzles 5 --words-per-puzzle 20 --outdir ./output --pretty
    python import_and_generate.py --generator-path ./generate_puzzle.py --num-puzzles 10
"""

import argparse
import json
import random
import importlib.util
from pathlib import Path
from typing import List, Dict, Any, Optional, Tuple

from difficulty_calculator import DifficultyCalculator


def load_generator_module(generator_path: Optional[str]):
    """Load the generate_puzzle module dynamically."""
    if generator_path is None:
        # Try default path relative to this script
        default_path = Path(__file__).parent / "generate_puzzle.py"
        if default_path.exists():
            generator_path = str(default_path)
        else:
            return None
    
    path = Path(generator_path)
    if not path.exists():
        return None
    
    spec = importlib.util.spec_from_file_location("generate_puzzle", path)
    if spec is None or spec.loader is None:
        return None
    
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def simple_packer(words: List[str], max_width: int = 21, max_height: int = 21) -> Tuple[Tuple[int, int], List[Tuple[str, int, int, bool]]]:
    """
    Simple word packer fallback when pycrossword is not available.
    Places words in a grid trying to maximize overlaps.
    
    Returns:
        Tuple of ((cols, rows), list of (word, row, col, is_horizontal))
    """
    W, H = max_width, max_height
    grid = [[None for _ in range(W)] for _ in range(H)]
    placed: List[Tuple[str, int, int, bool]] = []
    
    # Sort words by length (longest first)
    sorted_words = sorted(words, key=len, reverse=True)
    
    for word in sorted_words:
        word = word.upper()
        wlen = len(word)
        if wlen > W and wlen > H:
            continue  # Word too long
        
        best = None
        best_score = -1
        
        # Try to find the best position
        for y in range(H):
            for x in range(W):
                # Try horizontal
                if x + wlen <= W:
                    conflict = False
                    overlap = 0
                    for i, ch in enumerate(word):
                        cell = grid[y][x + i]
                        if cell is None:
                            continue
                        if cell == ch:
                            overlap += 1
                        else:
                            conflict = True
                            break
                    if not conflict:
                        score = overlap
                        if score > best_score:
                            best_score = score
                            best = (word, y, x, True, score)
                
                # Try vertical
                if y + wlen <= H:
                    conflict = False
                    overlap = 0
                    for i, ch in enumerate(word):
                        cell = grid[y + i][x]
                        if cell is None:
                            continue
                        if cell == ch:
                            overlap += 1
                        else:
                            conflict = True
                            break
                    if not conflict:
                        score = overlap
                        if score > best_score:
                            best_score = score
                            best = (word, y, x, False, score)
        
        if best is None:
            # Skip word if cannot place
            continue
        
        w, yy, xx, is_horiz, sc = best
        if is_horiz:
            for i, ch in enumerate(w):
                grid[yy][xx + i] = ch
        else:
            for i, ch in enumerate(w):
                grid[yy + i][xx] = ch
        placed.append((w, yy, xx, is_horiz))
    
    return ((W, H), placed)


def build_puzzle_from_placed(
    placed: List[Tuple[str, int, int, bool]],
    cols: int,
    rows: int,
    puzzle_id: str,
    metadata: Dict[str, Any]
) -> Dict[str, Any]:
    """Build a puzzle dict from placed words."""
    # Create grid from placed words
    grid = [[None for _ in range(cols)] for _ in range(rows)]
    for word, row, col, is_h in placed:
        for i, ch in enumerate(word):
            if is_h:
                grid[row][col + i] = ch
            else:
                grid[row + i][col] = ch
    
    # Build cells
    cells = []
    for y in range(rows):
        for x in range(cols):
            val = grid[y][x]
            cells.append({
                "x": x,
                "y": y,
                "is_black": (val is None),
                "solution": val
            })
    
    # Compute numbering
    number_map = {}
    current_number = 1
    for y in range(rows):
        for x in range(cols):
            if cells[y * cols + x]["is_black"]:
                continue
            is_start_across = (x == 0 or cells[y * cols + (x - 1)]["is_black"]) and \
                              (x < cols - 1 and not cells[y * cols + (x + 1)]["is_black"])
            is_start_down = (y == 0 or cells[(y - 1) * cols + x]["is_black"]) and \
                            (y < rows - 1 and not cells[(y + 1) * cols + x]["is_black"])
            if is_start_across or is_start_down:
                number_map[f"{y},{x}"] = current_number
                current_number += 1
    
    # Build entries
    entries = []
    for word, row, col, is_h in placed:
        direction = "across" if is_h else "down"
        number = number_map.get(f"{row},{col}", 0)
        entries.append({
            "id": f"{direction[0]}{number}",
            "number": number,
            "direction": direction,
            "x": col,
            "y": row,
            "length": len(word),
            "answer": word,
            "clue": "Imported from CrosswordQA"
        })
    
    entries.sort(key=lambda e: (e["number"], 0 if e["direction"] == "across" else 1))
    
    return {
        "id": puzzle_id,
        "version": "1.0",
        "metadata": metadata,
        "rows": rows,
        "cols": cols,
        "cells": cells,
        "entries": entries
    }


def add_difficulty_to_puzzle(puzzle: Dict[str, Any]) -> Dict[str, Any]:
    """Calculate and add difficulty metadata to a puzzle."""
    calculator = DifficultyCalculator()
    result = calculator.calculate_from_puzzle(puzzle)
    
    if "metadata" not in puzzle:
        puzzle["metadata"] = {}
    
    puzzle["metadata"]["difficulty"] = result.level
    puzzle["metadata"]["difficulty_label"] = result.label
    puzzle["metadata"]["difficulty_score"] = result.raw_score
    
    return puzzle


def load_crosswordqa_words(num_words: int = 100, seed: Optional[int] = None) -> List[str]:
    """
    Load sample words from CrosswordQA dataset or generate sample words.
    This is a simplified version - in production you'd load from the actual dataset.
    """
    # Sample common crossword words for testing
    sample_words = [
        "APPLE", "BANANA", "CHERRY", "DATE", "ELDER",
        "FIG", "GRAPE", "HONEY", "ICE", "JAM",
        "KALE", "LEMON", "MANGO", "NUT", "OLIVE",
        "PEACH", "QUINCE", "RAISIN", "SUGAR", "TEA",
        "UMBRELLA", "VIOLET", "WATER", "XRAY", "YARN",
        "ZEBRA", "ANCHOR", "BEACH", "CLOUD", "DELTA",
        "EAGLE", "FROST", "GOLD", "HARBOR", "ISLAND",
        "JUNGLE", "KNIGHT", "LION", "MOON", "NORTH",
        "OCEAN", "PALACE", "QUEEN", "RIVER", "STORM",
        "TOWER", "UNITY", "VALLEY", "WIND", "YOUTH",
        "ACE", "BET", "CUT", "DIG", "EAT",
        "FLY", "GUN", "HIT", "INK", "JOB",
        "KEY", "LAP", "MAP", "NET", "OAK",
        "PAN", "RUN", "SIT", "TOP", "USE",
        "ABSTRACT", "BEAUTIFUL", "COMPUTER", "DEMOCRACY", "ELEPHANT",
        "FANTASTIC", "GORGEOUS", "HAPPINESS", "IMPORTANT", "JUNCTION",
    ]
    
    if seed is not None:
        random.seed(seed)
    
    return random.sample(sample_words, min(num_words, len(sample_words)))


def main():
    parser = argparse.ArgumentParser(
        description="Import words and generate crossword puzzles with difficulty calculation"
    )
    
    parser.add_argument(
        "--num-puzzles",
        type=int,
        default=5,
        help="Number of puzzles to generate"
    )
    parser.add_argument(
        "--words-per-puzzle",
        type=int,
        default=20,
        help="Number of words per puzzle"
    )
    parser.add_argument(
        "--outdir",
        type=str,
        default="./generated_puzzles",
        help="Output directory for generated puzzles"
    )
    parser.add_argument(
        "--generator-path",
        type=str,
        default=None,
        help="Path to generate_puzzle.py (optional, uses fallback if not available)"
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=None,
        help="Random seed for reproducibility"
    )
    parser.add_argument(
        "--pretty",
        action="store_true",
        help="Pretty-print JSON output"
    )
    parser.add_argument(
        "--max-width",
        type=int,
        default=21,
        help="Maximum grid width"
    )
    parser.add_argument(
        "--max-height",
        type=int,
        default=21,
        help="Maximum grid height"
    )
    
    args = parser.parse_args()
    
    # Create output directory
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    
    # Load generator module (optional)
    gen_mod = load_generator_module(args.generator_path)
    if gen_mod is not None:
        print(f"Using generator module: {args.generator_path or 'default'}")
    else:
        print("Generator module not available, using simple packer fallback")
    
    # Generate word groups
    total_words_needed = args.num_puzzles * args.words_per_puzzle
    all_words = load_crosswordqa_words(total_words_needed, seed=args.seed)
    
    # Split into groups
    groups = []
    for i in range(0, len(all_words), args.words_per_puzzle):
        group = all_words[i:i + args.words_per_puzzle]
        if len(group) >= 5:  # Minimum words for a puzzle
            groups.append(group)
    
    groups = groups[:args.num_puzzles]
    
    print(f"Generating {len(groups)} puzzles...")
    
    difficulty_calculator = DifficultyCalculator()
    
    for idx, group in enumerate(groups, start=1):
        pid = f"hf_sample_{idx}"
        title = f"HF sample {idx}"
        metadata = {
            "title": title,
            "author": "import_and_generate",
            "language": "en",
            "source_format": "crosswordqa+pycrossword"
        }
        
        print(f"Generating puzzle {idx}/{len(groups)} with {len(group)} words...")
        
        puzzle = None
        
        # Try using the generator module first
        if gen_mod is not None:
            try:
                puzzle = gen_mod.generate_puzzle_from_words(
                    words=group,
                    max_width=args.max_width,
                    max_height=args.max_height,
                    seed=args.seed,
                    puzzle_id=pid,
                    metadata=metadata,
                    clue_generator=None,
                )
            except Exception as e:
                print(f"  Generator failed: {e}, using fallback...")
                puzzle = None
        
        # Fallback to simple packer
        if puzzle is None:
            dims, placed = simple_packer(group, max_width=args.max_width, max_height=args.max_height)
            cols, rows = dims
            puzzle = build_puzzle_from_placed(placed, cols, rows, pid, metadata)
        
        # Calculate and add difficulty
        puzzle = add_difficulty_to_puzzle(puzzle)
        
        # Save puzzle
        outpath = outdir / f"puzzle_{pid}.json"
        with open(outpath, "w", encoding="utf-8") as f:
            if args.pretty:
                json.dump(puzzle, f, ensure_ascii=False, indent=2)
            else:
                json.dump(puzzle, f, ensure_ascii=False)
        
        diff_info = f"{puzzle['metadata'].get('difficulty_label', '?')} (niveau {puzzle['metadata'].get('difficulty', '?')})"
        print(f"  Saved: {outpath} ({puzzle.get('cols')}x{puzzle.get('rows')}) "
              f"{len(puzzle.get('entries', []))} words - Difficulté: {diff_info}")
    
    print("Done.")


if __name__ == "__main__":
    main()
