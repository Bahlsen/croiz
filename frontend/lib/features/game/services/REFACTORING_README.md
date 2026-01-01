# Game Services

This directory contains services extracted (or scaffolded for extraction) from `GameBoardNotifier` to improve separation of concerns and testability.

## Current Status

The following services have been **scaffolded** as preparation for incremental migration:

| Service | Purpose | Status |
|---------|---------|--------|
| `game_persistence_service.dart` | Debounced progress persistence | Scaffolded, not yet integrated |
| `game_progress_service.dart` | Progress loading/restoration | Scaffolded, not yet integrated |
| `game_reveal_service.dart` | Reveal letter/word/all operations | Scaffolded, not yet integrated |
| `word_check_service.dart` | Word completion checking | **Active** - already in use |
| `incorrect_letter_cleaner.dart` | Clear incorrect letters | **Active** - already in use |
| `endgame_service.dart` | End-game detection | **Active** - already in use |

## Recommended Migration Approach

Direct integration was attempted but broke 160+ tests due to provider dependency changes. The recommended approach is **incremental migration**:

### Step 1: Add service providers to test helpers
Update `test/helpers/` to include overrides for the new services.

### Step 2: Migrate one method at a time
1. Pick one method (e.g., `_persistProgress`)
2. Delegate to the service
3. Run tests, fix any failures
4. Repeat

### Step 3: Update GameBoardNotifier
After all methods are delegated, the notifier becomes a thin orchestration layer.

## Why This Approach?

The `GameBoardNotifier` is tightly coupled with:
- Riverpod provider references (`ref.read()`)
- State updates (`state = ...`)
- Other providers (timer, audio, found words, etc.)

Full extraction requires updating all test files to provide the new service providers, which is a larger effort best done incrementally.
