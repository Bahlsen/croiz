# croiz Refactor and Stability Plan

Purpose: Document the fixes and recommendations applied and planned to improve performance, maintainability, and test stability of the Flutter frontend. This plan guides implementation, testing, and rollout.

## Goals
- Improve input handling correctness and determinism.
- Reduce stringly-typed logic with safer domain types.
- Stabilize animations/timers for predictable tests.
- Align Riverpod usage and provider contracts.
- Keep UI responsive and behavior consistent with project guidelines.

## Completed Changes (Summary)
- Input controller: skip found/locked entries when advancing; fill next empty cell within the entry when typing on a filled cell; immediate completion checks before debounce.
- Flash clearing: always scheduled via a `Timer` (including `Duration.zero`) for deterministic FakeAsync behavior.
- Riverpod writes standardized to `.state`/`.value` conventions in notifiers.
- Word direction: introduced `EntryDirection` enum and `PuzzleEntryData.directionEnum` to remove raw string comparisons.
- Audio timing: `playSuccess`/`playVictory` called synchronously to avoid provider reads after disposal.

## In-Progress and Planned Work
1. Typed cell identifiers: introduce `CellKey` (row, col) and migrate flashing/locked provider sets and consumers away from `String` keys like `"row,col"`.
2. Services: update `WordCheckService.getCellKeys()` to return `List<CellKey>` and propagate to controller and provider seeds.
3. UI: update widgets to consume `Set<CellKey>` for flashing/locked states while keeping existing clue-number maps keyed by strings.
4. Navigation helpers: update `nextEditableCell(...)` to use typed locks.
5. Tests: adapt unit and widget tests that assert on flashing/locked cells to use `CellKey` values.
6. Performance follow-ups (post-migration):
   - Pre-index entries by cell to speed up containment checks.
   - Use `Provider.select` for granular rebuilds in large grids.
   - Review discontinued packages (e.g., golden_toolkit) and remove or replace.

## Step-by-Step Implementation
1. Add `CellKey` in `lib/domain/entities/game_entities.dart` with `==`/`hashCode` and a concise `toString()`.
2. Change provider types in `lib/features/game/game_providers.dart` for `flashingCellsProvider` and `lockedCellsProvider` to `Set<CellKey>` (done), and ensure initial seeds and consumers use the new type.
3. Update `lib/features/game/services/word_check_service.dart` to return typed cell keys.
4. Update `lib/features/game/controllers/crossword_navigation.dart` and `lib/features/game/controllers/crossword_input_controller.dart` to use `CellKey` everywhere locks/flashes are checked or set.
5. Update UI in `lib/features/game/widgets/grid/crossword_cell.dart` to compute `CellKey(row, col)` for flashing checks; keep clue numbering map lookups with string keys.
6. Adapt targeted tests in `frontend/test/unit/...` to use `CellKey` for locked/flashing sets.
7. Run auto-linting and tests:
   - `dart format` on changed files
   - `dart fix --apply`
   - `flutter analyze`
   - `flutter test` (targeted, then full)
8. Verify via hot reload task: `frontend/tools/run_hot_reload.ps1 false`.
4
## Risk and Rollback
- Risk: Wide refactor touches controller, services, UI, and tests; type mismatches can break builds. Mitigation: migrate in small steps, run analyzer/tests after each batch.
- Rollback: If instability occurs, revert to string keys for specific providers temporarily or gate typed migration behind a feature flag (not planned unless needed).

## Acceptance Criteria
- Analyzer clean; all unit/widget tests pass locally on Windows.
- No regressions in input behavior: skipping locked/found entries, correct next-word selection, flash timing predictable.
- UI renders flashing/cleared states correctly using typed keys.

## Quick Commands

```powershell
cd frontend
dart format lib test
dart fix --apply
flutter analyze
flutter test --reporter expanded
```

Optional hot reload during development:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File frontend/tools/run_hot_reload.ps1 false
```
