# Plan: TDD Puzzle Selection UI Refonte

> **Status:** ✅ COMPLETE  
> **Started:** 2025-12-31  
> **Completed:** 2025-12-31

## Overview

Refonte complète de l'interface de sélection des puzzles avec:
- Filtres par difficulté et langue
- Section "Reprendre" pour puzzles en cours
- Indicateurs de progression
- Performance optimisée pour 10k+ puzzles

---

## Progress Tracker

| Phase | Description | Status | Tests | Implementation |
|-------|-------------|--------|-------|----------------|
| 0 | Python scripts - add `language` field | ✅ Done | N/A | ✅ |
| 1 | `PuzzleDescriptor` extension | ✅ Done | ✅ | ✅ |
| 2 | `PuzzleProgressService` | ✅ Done | ✅ | ✅ |
| 3 | `PuzzleFilterNotifier` | ✅ Done | ✅ | ✅ |
| 4 | `filteredPuzzlesProvider` | ✅ Done | ✅ | ✅ |
| 5 | `DifficultyFilterChips` widget | ✅ Done | ✅ | ✅ |
| 6 | `ContinuePlayingSection` widget | ✅ Done | ✅ | ✅ |
| 7 | `PuzzleListTileEnhanced` widget | ✅ Done | ✅ | ✅ |
| 8 | `PuzzlesListPageEnhanced` integration | ✅ Done | ✅ | ✅ |

Legend: ⏳ TODO | 🔄 In Progress | ✅ Done | ❌ Blocked

**Total Tests Added:** 67+ new tests across 8 phases

---

## Phase 0: Python Scripts — Add `language` Field

### Files to Modify

| File | Change | Status |
|------|--------|--------|
| `tools/xd_to_canonical.py` | Add default `language` to metadata | ✅ |
| `frontend/tools/generate_puzzles_metadata_index.py` | Add `ORIGIN_LANGUAGE_MAP`, include `language` in output | ✅ |
| Regenerate index | Run script | ✅ |

### Origin → Language Mapping

```python
ORIGIN_LANGUAGE_MAP = {
    'atlantic': 'en',
    'latimes': 'en',
    'newsday': 'en',
    'newyorker': 'en',
    'nytimes': 'en',
    'slate': 'en',
    'universal': 'en',
    'usatoday': 'en',
    'wsj': 'en',
    # Future:
    # 'lemonde': 'fr',
    # 'el_pais': 'es',
}
DEFAULT_LANGUAGE = 'en'
```

---

## Phase 1: Model Layer — `PuzzleDescriptor` Extension

### Test File: `test/unit/puzzles_provider_test.dart`

| # | Test Name | Status |
|---|-----------|--------|
| 1.1 | `PuzzleDescriptor parses difficulty from JSON` | ✅ |
| 1.2 | `PuzzleDescriptor parses difficultyLabel from JSON` | ✅ |
| 1.3 | `PuzzleDescriptor defaults difficulty to 2 (Medium)` | ✅ |
| 1.4 | `PuzzleDescriptor parses language from JSON` | ✅ |
| 1.5 | `PuzzleDescriptor defaults language to "en"` | ✅ |
| 1.6 | `PuzzleDescriptor.copyWith preserves all fields` | ✅ |

---

## Phase 2: Progress Service — `PuzzleProgressService`

### Test File: `test/unit/services/puzzle_progress_service_test.dart` (NEW)

| # | Test Name | Status |
|---|-----------|--------|
| 2.1 | `getAllInProgressPuzzleIds returns empty when no saves` | ✅ |
| 2.2 | `getAllInProgressPuzzleIds returns saved puzzle IDs` | ✅ |
| 2.3 | `getProgress returns null for unknown puzzle` | ✅ |
| 2.4 | `getProgress returns PuzzleProgress with correct fields` | ✅ |
| 2.5 | `calculateCompletionPercent returns 0 for empty grid` | ✅ |
| 2.6 | `calculateCompletionPercent returns 100 for full grid` | ✅ |
| 2.7 | `calculateCompletionPercent ignores black cells` | ✅ |
| 2.8 | `getInProgressPuzzlesSortedByRecency returns newest first` | ✅ |
| 2.9 | `isCompleted returns true when grid matches solution` | ✅ |
| 2.10 | `isCompleted returns false for partial completion` | ✅ |
| 2.11 | `solution cache prevents redundant asset loads` | ✅ |
| 2.12 | `clearSolutionCache frees memory` | ✅ |

### Implementation Notes

- Lazy load solutions on demand
- Cache solutions in memory (`Map<String, List<List<String?>>>`)
- `clearCache()` method for memory management

---

## Phase 3: Filter State — `PuzzleFilterNotifier`

### Test File: `test/unit/features/puzzles/puzzle_filter_provider_test.dart` (NEW)

| # | Test Name | Status |
|---|-----------|--------|
| 3.1 | `initial state has all difficulties selected` | ✅ |
| 3.2 | `initial state has all languages selected` | ✅ |
| 3.3 | `toggleDifficulty removes difficulty when present` | ✅ |
| 3.4 | `toggleDifficulty adds difficulty when absent` | ✅ |
| 3.5 | `toggleLanguage removes/adds language correctly` | ✅ |
| 3.6 | `setShowCompleted updates flag` | ✅ |
| 3.7 | `clearFilters resets to defaults` | ✅ |
| 3.8 | `state persists to SharedPreferences on change` | ✅ |
| 3.9 | `state restores from SharedPreferences on init` | ✅ |
| 3.10 | `hasActiveFilters returns true when filtering` | ✅ |

---

## Phase 4: Filtered Puzzles Provider

### Test File: `test/unit/features/puzzles/filtered_puzzles_provider_test.dart` (NEW)

| # | Test Name | Status |
|---|-----------|--------|
| 4.1 | `returns all when no filter active` | ✅ |
| 4.2 | `filters by difficulty` | ✅ |
| 4.3 | `filters by language` | ✅ |
| 4.4 | `combines difficulty + language` | ✅ |
| 4.5 | `excludes completed when showCompleted=false` | ✅ |
| 4.6 | `updates reactively on filter change` | ✅ |

---

## Phase 5: Widget Tests — Filter Chips

### Test File: `test/widget/features/puzzles/difficulty_filter_chips_test.dart` (NEW)

| # | Test Name | Status |
|---|-----------|--------|
| 5.1 | `renders 5 chips for each difficulty` | ✅ |
| 5.2 | `chip shows correct color` | ✅ |
| 5.3 | `tapping chip toggles selection` | ✅ |
| 5.4 | `selected chips filled, unselected outlined` | ✅ |

---

## Phase 6: Widget Tests — Continue Playing Section

### Test File: `test/widget/features/puzzles/continue_playing_section_test.dart` (NEW)

| # | Test Name | Status |
|---|-----------|--------|
| 6.1 | `shows placeholder when empty` | ✅ |
| 6.2 | `renders horizontal ListView` | ✅ |
| 6.3 | `card shows puzzle title` | ✅ |
| 6.4 | `card shows progress percentage` | ✅ |
| 6.5 | `card shows difficulty badge` | ✅ |
| 6.6 | `card shows elapsed time` | ✅ |
| 6.7 | `tapping navigates to game` | ✅ |
| 6.8 | `sorted by savedAt DESC` | ✅ |

---

## Phase 7: Widget Tests — Updated `PuzzleListTile`

### Status: ✅ Done

### Test File: `test/widget/features/puzzles/puzzle_list_tile_test.dart` (NEW)

| # | Test Name | Status |
|---|-----------|--------|
| 7.1 | `shows difficulty badge with color` | ✅ |
| 7.2 | `shows difficulty label` | ✅ |
| 7.3 | `shows progress indicator when in progress` | ✅ |
| 7.4 | `shows checkmark when completed` | ✅ |
| 7.5 | `shows language flag/code` | ✅ |
| 7.6 | `no indicator for unstarted` | ✅ |
| 7.7 | `shows origin and date in subtitle` | ✅ |

---

## Phase 8: Integration — `PuzzlesListPageEnhanced` with Performance

### Status: ✅ Done

### Test File: `test/widget/features/puzzles/puzzles_list_page_enhanced_test.dart` (NEW)

| # | Test Name | Status |
|---|-----------|--------|
| 8.1 | `shows ContinuePlayingSection at top` | ✅ |
| 8.2 | `shows DifficultyFilterChips below ContinuePlayingSection` | ✅ |
| 8.3 | `list shows all puzzles initially` | ✅ |
| 8.4 | `shows puzzle count in app bar` | ✅ |
| 8.5 | `shows loading indicator while loading` | ✅ |
| 8.6 | `shows error message on error` | ✅ |
| 8.7 | `ListView uses builder pattern for performance` | ✅ |

### Performance Implementation

```dart
ListView.builder(
  itemCount: filteredPuzzles.length,
  itemExtent: 72, // Fixed height for O(1) scroll calculation
  cacheExtent: 500, // Pre-render 500px above/below viewport
  itemBuilder: (context, index) => PuzzleListTileEnhanced(descriptor: filteredPuzzles[index]),
)
```

---

## New Files Created

| Path | Purpose | Status |
|------|---------|--------|
| `lib/services/persistence/puzzle_progress_service.dart` | Progress tracking | ✅ |
| `lib/features/puzzles/puzzle_filter_provider.dart` | Filter state | ✅ |
| `lib/features/puzzles/filtered_puzzles_provider.dart` | Filtered list | ✅ |
| `lib/features/puzzles/widgets/difficulty_filter_chips.dart` | Filter chips | ✅ |
| `lib/features/puzzles/widgets/puzzle_list_tile_enhanced.dart` | Enhanced list tile | ✅ |
| `lib/features/puzzles/widgets/continue_playing_section.dart` | In-progress list | ✅ |
| `lib/features/puzzles/puzzles_list_page_enhanced.dart` | Enhanced page | ✅ |
| `test/unit/services/puzzle_progress_service_test.dart` | Unit tests | ✅ |
| `test/unit/features/puzzles/puzzle_filter_provider_test.dart` | Unit tests | ✅ |
| `test/unit/features/puzzles/filtered_puzzles_provider_test.dart` | Unit tests | ✅ |
| `test/widget/features/puzzles/difficulty_filter_chips_test.dart` | Widget tests | ✅ |
| `test/widget/features/puzzles/continue_playing_section_test.dart` | Widget tests | ✅ |
| `test/widget/features/puzzles/puzzle_list_tile_test.dart` | Widget tests | ✅ |
| `test/widget/features/puzzles/puzzles_list_page_enhanced_test.dart` | Widget tests | ✅ |

---

## Difficulty Badge Colors

| Level | Value | Label | Color |
|-------|-------|-------|-------|
| Easy | 1 | Easy | Green (`Colors.green`) |
| Medium | 2 | Medium | Amber (`Colors.amber`) |
| Hard | 3 | Hard | Red (`Colors.red`) |
| Expert | 4 | Expert | Purple (`Colors.purple`) |
| Master | 5 | Master | Black (`Colors.black`) |

---

## ✅ Completion Summary

**Final Test Count:** 362 tests passing (67+ new tests added)

### Key Implementations Delivered

1. **Difficulty Classification** — Puzzles auto-classified by grid size, word count, and black cell ratio
2. **Language Support** — Multi-language filtering with origin-based language mapping
3. **Completion Status Filtering** — `completedPuzzleIdsProvider` + `showCompleted` toggle
4. **Continue Playing Section** — Real-time progress from `HivePuzzleStorage`, sorted by recency
5. **Performance Optimized** — `ListView.builder` with fixed extent for 10k+ puzzles

### Architecture Highlights

- `HivePuzzleStorage` implements `PuzzleStorageInterface` with `getAllKeys()` for batch operations
- `filteredPuzzlesProvider` combines difficulty, language, AND completion filters
- `PuzzleProgressService` calculates completion % by comparing user grid vs solution
- GoRouter integration for seamless puzzle resumption via `context.go('/game')`

### Next Steps (Optional Enhancements)

- [ ] Wire `PuzzlesListPageEnhanced` into main app routing
- [ ] Add visual completion indicator (checkmark badge) on puzzle tiles
- [ ] Real-time refresh when a puzzle is completed
- [ ] Add search functionality for puzzle titles/authors
