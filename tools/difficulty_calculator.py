#!/usr/bin/env python3
"""
Difficulty Calculator for Crossword Puzzles.

Calcule la difficulté d'un puzzle de mots croisés basé sur :
1. Caractéristiques de la grille (taille, densité des cases noires)
2. Caractéristiques linguistiques (longueur moyenne des mots, nombre de mots)
3. Qualité des indices (optionnel - basé sur la longueur/complexité des clues)

Usage:
    from difficulty_calculator import DifficultyCalculator, PuzzleDifficulty
    
    calculator = DifficultyCalculator()
    result = calculator.calculate_from_puzzle(puzzle_dict)
    print(f"Difficulty: {result.difficulty.label} (level {result.difficulty.level})")
"""

from enum import IntEnum
from dataclasses import dataclass
from typing import Dict, Any, List, Optional


class PuzzleDifficulty(IntEnum):
    """Puzzle difficulty levels."""
    EASY = 1
    MEDIUM = 2
    HARD = 3
    EXPERT = 4
    MASTER = 5

    @property
    def label(self) -> str:
        """Returns the English label for the difficulty."""
        labels = {
            PuzzleDifficulty.EASY: "Easy",
            PuzzleDifficulty.MEDIUM: "Medium",
            PuzzleDifficulty.HARD: "Hard",
            PuzzleDifficulty.EXPERT: "Expert",
            PuzzleDifficulty.MASTER: "Master",
        }
        return labels[self]
    
    @property
    def label_fr(self) -> str:
        """Returns the French label for the difficulty."""
        labels = {
            PuzzleDifficulty.EASY: "Facile",
            PuzzleDifficulty.MEDIUM: "Moyen",
            PuzzleDifficulty.HARD: "Difficile",
            PuzzleDifficulty.EXPERT: "Expert",
            PuzzleDifficulty.MASTER: "Maître",
        }
        return labels[self]

    @classmethod
    def from_level(cls, level: int) -> 'PuzzleDifficulty':
        """Create a difficulty from a level (clamped 1-5)."""
        clamped = max(1, min(5, level))
        return cls(clamped)
    
    @classmethod
    def from_score(cls, score: float) -> 'PuzzleDifficulty':
        """Converts a raw score (0-10) to a difficulty level.
        
        Thresholds calibrated so standard 15x15 puzzles (score ~4-5) 
        correspond to "Medium".
        """
        if score <= 2.5:
            return cls.EASY
        elif score <= 4.5:
            return cls.MEDIUM
        elif score <= 6.5:
            return cls.HARD
        elif score <= 8.0:
            return cls.EXPERT
        else:
            return cls.MASTER


@dataclass
class DifficultyMetrics:
    """Metrics used to calculate difficulty."""
    grid_size: int  # max(rows, cols)
    rows: int
    cols: int
    total_cells: int
    black_cell_count: int
    black_cell_ratio: float
    word_count: int
    avg_word_length: float
    max_word_length: int
    min_word_length: int
    avg_clue_length: float  # Longueur moyenne des indices
    crossing_ratio: float  # Ratio de lettres partagées entre mots

    @classmethod
    def from_puzzle(cls, puzzle: Dict[str, Any]) -> 'DifficultyMetrics':
        """Calculate metrics from a puzzle JSON."""
        rows = puzzle.get('rows', 0)
        cols = puzzle.get('cols', 0)
        cells = puzzle.get('cells', [])
        entries = puzzle.get('entries', [])

        total_cells = rows * cols
        black_cell_count = sum(1 for c in cells if c.get('is_black', False))
        black_cell_ratio = black_cell_count / total_cells if total_cells > 0 else 0.0

        # Calculate word statistics
        word_lengths = [e.get('length', 0) for e in entries if e.get('length', 0) > 0]
        word_count = len(word_lengths)
        avg_word_length = sum(word_lengths) / word_count if word_count > 0 else 0.0
        max_word_length = max(word_lengths) if word_lengths else 0
        min_word_length = min(word_lengths) if word_lengths else 0

        # Calculate average clue length
        clue_lengths = [len(e.get('clue', '')) for e in entries if e.get('clue')]
        avg_clue_length = sum(clue_lengths) / len(clue_lengths) if clue_lengths else 0.0

        # Calculate crossing ratio (approximation)
        # More words in a dense grid = more crossings
        white_cells = total_cells - black_cell_count
        total_word_cells = sum(word_lengths)
        crossing_ratio = (total_word_cells - white_cells) / white_cells if white_cells > 0 else 0.0

        return cls(
            grid_size=max(rows, cols),
            rows=rows,
            cols=cols,
            total_cells=total_cells,
            black_cell_count=black_cell_count,
            black_cell_ratio=black_cell_ratio,
            word_count=word_count,
            avg_word_length=avg_word_length,
            max_word_length=max_word_length,
            min_word_length=min_word_length,
            avg_clue_length=avg_clue_length,
            crossing_ratio=crossing_ratio,
        )


@dataclass
class DifficultyResult:
    """Result of difficulty calculation."""
    difficulty: PuzzleDifficulty
    level: int
    label: str
    raw_score: float
    metrics: DifficultyMetrics
    breakdown: Dict[str, float]  # Détail des scores par critère


class DifficultyCalculator:
    """
    Difficulty calculator for crossword puzzles.
    
    Difficulty criteria:
    1. Grid size: 5×5 (easy) → 21×21+ (very hard)
    2. Black cell density: more = easier (shorter words)
    3. Average word length: short = easy, long = hard
    4. Word count: fewer = generally easier
    5. Clue complexity: shorter clues = more direct = easier
    6. Crossing ratio: more shared letters = more constraints
    """

    # Poids des différents critères (ajustables)
    WEIGHT_GRID_SIZE = 2.0
    WEIGHT_BLACK_RATIO = 1.5
    WEIGHT_AVG_WORD_LENGTH = 2.0
    WEIGHT_WORD_COUNT = 1.0
    WEIGHT_CLUE_LENGTH = 1.0
    WEIGHT_CROSSING = 1.5

    def calculate_from_puzzle(self, puzzle: Dict[str, Any]) -> DifficultyResult:
        """Calculate difficulty from a puzzle JSON."""
        metrics = DifficultyMetrics.from_puzzle(puzzle)
        return self.calculate_from_metrics(metrics)

    def calculate_from_metrics(self, metrics: DifficultyMetrics) -> DifficultyResult:
        """Calculate difficulty from metrics."""
        breakdown = {}
        
        # 1. Score basé sur la taille de grille (0-10)
        # 5x5 = 0, 11x11 = 3, 15x15 = 5, 21x21 = 10
        # Standard crossword is 15x15, so that should be "medium" baseline
        grid_score = min(10, max(0, (metrics.grid_size - 5) / 1.6))
        breakdown['grid_size'] = grid_score

        # 2. Score basé sur la densité des cases noires (0-10)
        # Plus de cases noires = plus facile (score inversé)
        # Standard 15x15 has ~16-18% black cells
        # ratio 0.25+ = score 0 (very easy), ratio 0.15 = score 5, ratio 0.1 = score 7.5
        black_score = min(10, max(0, (0.25 - metrics.black_cell_ratio) * 40))
        breakdown['black_ratio'] = black_score

        # 3. Score basé sur la longueur moyenne des mots (0-10)
        # avg 3 = 0, avg 4.5 = 3, avg 5.5 = 5, avg 7+ = 8
        word_len_score = min(10, max(0, (metrics.avg_word_length - 3) * 2))
        breakdown['avg_word_length'] = word_len_score

        # 4. Score basé sur le nombre de mots (0-10)
        # Normalisé par rapport à la taille de grille
        # A 15x15 grid typically has 70-80 words
        expected_words = metrics.total_cells * 0.35  # ~79 words for 15x15
        word_ratio = metrics.word_count / expected_words if expected_words > 0 else 1
        # More words relative to expected = harder (more to solve)
        word_count_score = min(10, max(0, word_ratio * 5))
        breakdown['word_count'] = word_count_score

        # 5. Score basé sur la longueur des indices (0-10)
        # Indices plus longs = potentiellement plus complexes/cryptiques
        # avg 20 chars = 0 (simple), avg 40 chars = 4, avg 80+ chars = 10
        clue_score = min(10, max(0, (metrics.avg_clue_length - 15) / 6.5))
        breakdown['clue_complexity'] = clue_score

        # 6. Score basé sur le ratio de croisements (0-10)
        # Plus de croisements = plus de contraintes = plus difficile
        # Typical ratio is around 0.5-1.0
        crossing_score = min(10, max(0, metrics.crossing_ratio * 5))
        breakdown['crossing_ratio'] = crossing_score

        # Calcul du score final pondéré
        total_weight = (
            self.WEIGHT_GRID_SIZE +
            self.WEIGHT_BLACK_RATIO +
            self.WEIGHT_AVG_WORD_LENGTH +
            self.WEIGHT_WORD_COUNT +
            self.WEIGHT_CLUE_LENGTH +
            self.WEIGHT_CROSSING
        )

        raw_score = (
            grid_score * self.WEIGHT_GRID_SIZE +
            black_score * self.WEIGHT_BLACK_RATIO +
            word_len_score * self.WEIGHT_AVG_WORD_LENGTH +
            word_count_score * self.WEIGHT_WORD_COUNT +
            clue_score * self.WEIGHT_CLUE_LENGTH +
            crossing_score * self.WEIGHT_CROSSING
        ) / total_weight

        difficulty = PuzzleDifficulty.from_score(raw_score)

        return DifficultyResult(
            difficulty=difficulty,
            level=difficulty.value,
            label=difficulty.label,
            raw_score=round(raw_score, 2),
            metrics=metrics,
            breakdown=breakdown,
        )


def calculate_difficulty(puzzle: Dict[str, Any]) -> int:
    """
    Simple utility function to get the difficulty level.
    
    Returns:
        int: Difficulty level (1-5)
    """
    calculator = DifficultyCalculator()
    result = calculator.calculate_from_puzzle(puzzle)
    return result.level


def calculate_difficulty_label(puzzle: Dict[str, Any]) -> str:
    """
    Utility function to get the difficulty label.
    
    Returns:
        str: English difficulty label
    """
    calculator = DifficultyCalculator()
    result = calculator.calculate_from_puzzle(puzzle)
    return result.label


# Compatibilité avec les imports existants
__all__ = [
    'PuzzleDifficulty',
    'DifficultyMetrics',
    'DifficultyResult',
    'DifficultyCalculator',
    'calculate_difficulty',
    'calculate_difficulty_label',
]


if __name__ == '__main__':
    # Test avec un puzzle exemple
    import sys
    import json
    
    if len(sys.argv) > 1:
        puzzle_path = sys.argv[1]
        with open(puzzle_path, 'r', encoding='utf-8') as f:
            puzzle = json.load(f)
        
        calculator = DifficultyCalculator()
        result = calculator.calculate_from_puzzle(puzzle)
        
        print(f"Puzzle: {puzzle.get('id', 'unknown')}")
        print(f"Grid: {result.metrics.rows}x{result.metrics.cols}")
        print(f"Words: {result.metrics.word_count}")
        print(f"Avg word length: {result.metrics.avg_word_length:.1f}")
        print(f"Black cell ratio: {result.metrics.black_cell_ratio:.1%}")
        print(f"")
        print(f"Raw score: {result.raw_score}/10")
        print(f"Difficulty: {result.label} (level {result.level})")
        print(f"")
        print("Score breakdown:")
        for key, value in result.breakdown.items():
            print(f"  {key}: {value:.1f}/10")
    else:
        print("Usage: python difficulty_calculator.py <puzzle.json>")
        print("")
        print("Test with sample data:")
        
        # Créer un puzzle test simple
        test_puzzle = {
            "id": "test",
            "rows": 15,
            "cols": 15,
            "cells": [
                {"x": x, "y": y, "is_black": (x + y) % 7 == 0}
                for y in range(15) for x in range(15)
            ],
            "entries": [
                {"number": i, "direction": "across" if i % 2 == 0 else "down",
                 "x": 0, "y": i % 15, "length": 5 + (i % 4), "clue": f"Clue number {i} with some text"}
                for i in range(1, 31)
            ]
        }
        
        calculator = DifficultyCalculator()
        result = calculator.calculate_from_puzzle(test_puzzle)
        
        print(f"Grid: {result.metrics.rows}x{result.metrics.cols}")
        print(f"Raw score: {result.raw_score}/10")
        print(f"Difficulty: {result.label} (level {result.level})")
