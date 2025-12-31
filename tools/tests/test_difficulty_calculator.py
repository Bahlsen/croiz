#!/usr/bin/env python3
"""
Tests for difficulty_calculator.py
"""
import unittest
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from difficulty_calculator import (
    PuzzleDifficulty,
    DifficultyMetrics,
    DifficultyResult,
    DifficultyCalculator,
    calculate_difficulty,
    calculate_difficulty_label,
)


class TestPuzzleDifficulty(unittest.TestCase):
    def test_levels(self):
        self.assertEqual(PuzzleDifficulty.EASY.value, 1)
        self.assertEqual(PuzzleDifficulty.MEDIUM.value, 2)
        self.assertEqual(PuzzleDifficulty.HARD.value, 3)
        self.assertEqual(PuzzleDifficulty.EXPERT.value, 4)
        self.assertEqual(PuzzleDifficulty.MASTER.value, 5)

    def test_labels(self):
        self.assertEqual(PuzzleDifficulty.EASY.label, "Easy")
        self.assertEqual(PuzzleDifficulty.MEDIUM.label, "Medium")
        self.assertEqual(PuzzleDifficulty.HARD.label, "Hard")
        self.assertEqual(PuzzleDifficulty.EXPERT.label, "Expert")
        self.assertEqual(PuzzleDifficulty.MASTER.label, "Master")

    def test_from_level(self):
        self.assertEqual(PuzzleDifficulty.from_level(1), PuzzleDifficulty.EASY)
        self.assertEqual(PuzzleDifficulty.from_level(2), PuzzleDifficulty.MEDIUM)
        self.assertEqual(PuzzleDifficulty.from_level(3), PuzzleDifficulty.HARD)
        self.assertEqual(PuzzleDifficulty.from_level(4), PuzzleDifficulty.EXPERT)
        self.assertEqual(PuzzleDifficulty.from_level(5), PuzzleDifficulty.MASTER)

    def test_from_level_clamps(self):
        self.assertEqual(PuzzleDifficulty.from_level(0), PuzzleDifficulty.EASY)
        self.assertEqual(PuzzleDifficulty.from_level(-1), PuzzleDifficulty.EASY)
        self.assertEqual(PuzzleDifficulty.from_level(6), PuzzleDifficulty.MASTER)
        self.assertEqual(PuzzleDifficulty.from_level(100), PuzzleDifficulty.MASTER)

    def test_from_score(self):
        self.assertEqual(PuzzleDifficulty.from_score(0), PuzzleDifficulty.EASY)
        self.assertEqual(PuzzleDifficulty.from_score(2.0), PuzzleDifficulty.EASY)
        self.assertEqual(PuzzleDifficulty.from_score(3.0), PuzzleDifficulty.MEDIUM)
        self.assertEqual(PuzzleDifficulty.from_score(5.0), PuzzleDifficulty.HARD)
        self.assertEqual(PuzzleDifficulty.from_score(7.0), PuzzleDifficulty.EXPERT)
        self.assertEqual(PuzzleDifficulty.from_score(9.0), PuzzleDifficulty.MASTER)


class TestDifficultyMetrics(unittest.TestCase):
    def test_from_puzzle_basic(self):
        puzzle = {
            "rows": 5,
            "cols": 5,
            "cells": [
                {"x": x, "y": y, "is_black": (x == 2 and y == 2)}
                for y in range(5) for x in range(5)
            ],
            "entries": [
                {"number": 1, "direction": "across", "length": 5, "clue": "Test clue one"},
                {"number": 2, "direction": "down", "length": 3, "clue": "Short"},
            ]
        }
        metrics = DifficultyMetrics.from_puzzle(puzzle)
        
        self.assertEqual(metrics.rows, 5)
        self.assertEqual(metrics.cols, 5)
        self.assertEqual(metrics.grid_size, 5)
        self.assertEqual(metrics.total_cells, 25)
        self.assertEqual(metrics.black_cell_count, 1)
        self.assertEqual(metrics.word_count, 2)
        self.assertEqual(metrics.avg_word_length, 4.0)

    def test_from_puzzle_empty_entries(self):
        puzzle = {
            "rows": 3,
            "cols": 3,
            "cells": [],
            "entries": []
        }
        metrics = DifficultyMetrics.from_puzzle(puzzle)
        
        self.assertEqual(metrics.word_count, 0)
        self.assertEqual(metrics.avg_word_length, 0.0)


class TestDifficultyCalculator(unittest.TestCase):
    def setUp(self):
        self.calculator = DifficultyCalculator()

    def test_small_grid_is_easy_or_medium(self):
        puzzle = self._create_puzzle(5, 5, black_ratio=0.2, word_count=6, avg_length=3)
        result = self.calculator.calculate_from_puzzle(puzzle)
        self.assertIn(result.difficulty, [PuzzleDifficulty.EASY, PuzzleDifficulty.MEDIUM])

    def test_medium_grid_is_easy_or_medium(self):
        puzzle = self._create_puzzle(10, 10, black_ratio=0.18, word_count=30, avg_length=4.5)
        result = self.calculator.calculate_from_puzzle(puzzle)
        self.assertIn(result.difficulty, [PuzzleDifficulty.EASY, PuzzleDifficulty.MEDIUM])

    def test_standard_15x15_is_medium(self):
        # Standard newspaper puzzle
        puzzle = self._create_puzzle(15, 15, black_ratio=0.17, word_count=76, avg_length=5)
        result = self.calculator.calculate_from_puzzle(puzzle)
        self.assertEqual(result.difficulty, PuzzleDifficulty.MEDIUM)

    def test_hard_puzzle_characteristics(self):
        # Less black cells, longer words
        puzzle = self._create_puzzle(15, 15, black_ratio=0.12, word_count=70, avg_length=6)
        result = self.calculator.calculate_from_puzzle(puzzle)
        self.assertIn(result.difficulty, [PuzzleDifficulty.MEDIUM, PuzzleDifficulty.HARD])

    def test_large_grid_increases_difficulty(self):
        puzzle = self._create_puzzle(21, 21, black_ratio=0.15, word_count=140, avg_length=6)
        result = self.calculator.calculate_from_puzzle(puzzle)
        self.assertGreaterEqual(result.level, 2)

    def test_result_has_breakdown(self):
        puzzle = self._create_puzzle(10, 10, black_ratio=0.2, word_count=20, avg_length=5)
        result = self.calculator.calculate_from_puzzle(puzzle)
        
        self.assertIn('grid_size', result.breakdown)
        self.assertIn('black_ratio', result.breakdown)
        self.assertIn('avg_word_length', result.breakdown)
        self.assertIn('word_count', result.breakdown)

    def _create_puzzle(self, rows, cols, black_ratio, word_count, avg_length):
        total_cells = rows * cols
        black_count = int(total_cells * black_ratio)
        
        cells = []
        for y in range(rows):
            for x in range(cols):
                is_black = (y * cols + x) < black_count
                cells.append({"x": x, "y": y, "is_black": is_black})
        
        entries = []
        for i in range(word_count):
            length = int(avg_length + (i % 3 - 1))
            entries.append({
                "number": i + 1,
                "direction": "across" if i % 2 == 0 else "down",
                "length": max(2, length),
                "clue": f"Clue number {i}"
            })
        
        return {
            "rows": rows,
            "cols": cols,
            "cells": cells,
            "entries": entries
        }


class TestUtilityFunctions(unittest.TestCase):
    def test_calculate_difficulty(self):
        puzzle = {
            "rows": 10,
            "cols": 10,
            "cells": [{"x": x, "y": y, "is_black": False} for y in range(10) for x in range(10)],
            "entries": [{"number": i, "direction": "across", "length": 5, "clue": "Test"} for i in range(20)]
        }
        level = calculate_difficulty(puzzle)
        self.assertIn(level, [1, 2, 3, 4, 5])

    def test_calculate_difficulty_label(self):
        puzzle = {
            "rows": 10,
            "cols": 10,
            "cells": [{"x": x, "y": y, "is_black": False} for y in range(10) for x in range(10)],
            "entries": [{"number": i, "direction": "across", "length": 5, "clue": "Test"} for i in range(20)]
        }
        label = calculate_difficulty_label(puzzle)
        self.assertIn(label, ["Easy", "Medium", "Hard", "Expert", "Master"])


if __name__ == '__main__':
    unittest.main()
