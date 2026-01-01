# Game Feature

The core crossword gameplay module for Croiz. This feature handles all aspects of playing a crossword puzzle.

## Overview

The Game feature provides:
- Interactive crossword grid with touch/tap input
- Virtual keyboard for letter entry (QWERTY/AZERTY)
- Real-time answer validation
- Progress tracking and persistence
- Audio feedback for interactions

## Directory Structure

```
game/
├── controllers/         # Game logic controllers
│   ├── cursor_controller.dart
│   ├── game_controller.dart
│   ├── input_controller.dart
│   └── validation_controller.dart
├── helpers/             # Helper functions
│   ├── grid_helpers.dart
│   ├── clue_helpers.dart
│   └── navigation_helpers.dart
├── listeners/           # Event handlers
│   ├── keyboard_listener.dart
│   └── gesture_listener.dart
├── providers/           # Riverpod state providers
│   ├── crossword_state_provider.dart
│   ├── cursor_position_provider.dart
│   ├── puzzle_loader_provider.dart
│   └── game_settings_provider.dart
├── screens/             # Full-screen UI
│   ├── game_screen.dart
│   └── game_completion_screen.dart
├── services/            # Business logic services
│   ├── word_check_service.dart
│   └── puzzle_loader_service.dart
├── utils/               # Utility functions
│   ├── grid_utils.dart
│   └── scoring_utils.dart
└── widgets/             # UI components
    ├── crossword_grid_widget.dart
    ├── grid_cell_widget.dart
    ├── clues_panel.dart
    ├── virtual_keyboard.dart
    ├── crossword_controls_bar.dart
    └── ...
```

## Key Providers

### `crosswordStateProvider`
Manages the complete state of the current puzzle:
- Grid data (cells, letters, solved state)
- Clue visibility
- Game mode (play, check, reveal)

### `cursorPositionProvider`
Tracks the player's current position and direction:
- Row/column coordinates
- Direction (across/down)
- Active clue reference

### `puzzleLoaderProvider`
Handles loading puzzle data:
- Asset loading from bundled puzzles
- JSON parsing
- Initial state setup

### `selectedPuzzleIdProvider`
Tracks which puzzle is currently selected for play.

## Widget Hierarchy

```
GameScreen
├── Scaffold
│   ├── AppBar (puzzle title, menu)
│   └── Body
│       ├── CrosswordGridWidget
│       │   └── GridCellWidget (repeated)
│       ├── CluesPanel
│       │   ├── AcrossCluesList
│       │   └── DownCluesList
│       ├── CrosswordControlsBar
│       │   ├── HintButton
│       │   ├── CheckButton
│       │   └── RevealButton
│       └── VirtualKeyboard
│           └── KeyButton (repeated)
```

## Game Flow

1. **Puzzle Selection**: User selects a puzzle from `PuzzlesListPage`
2. **Load**: `puzzleLoaderProvider` fetches and parses puzzle JSON
3. **Initialize**: `crosswordStateProvider` sets up initial game state
4. **Restore Progress**: Check for saved progress in Hive storage
5. **Play**: User interacts with grid and keyboard
6. **Validate**: `WordCheckService` validates answers on demand
7. **Persist**: Progress auto-saved during gameplay
8. **Complete**: Show completion screen on puzzle solve

## Input Handling

### Virtual Keyboard
The app uses a custom in-app keyboard that:
- Supports QWERTY and AZERTY layouts (user preference)
- Has adjustable size (small, medium, large)
- Provides haptic/audio feedback
- Handles special keys (backspace, enter)

### Gesture Input
- **Tap**: Select a cell
- **Double-tap**: Toggle direction (across ↔ down)
- **Swipe**: Navigate between cells

## Audio System

The game integrates with `GameAudioService` for:
- Key press sounds
- Correct answer celebration
- Error feedback
- Background ambient (optional)

Audio can be muted via `gameAudioMutedProvider`.

## Persistence

Game progress is automatically saved using:
- **Hive**: Local NoSQL storage for puzzle state
- **SharedPreferences**: User preferences (keyboard, theme)

See `lib/services/persistence/hive_puzzle_storage.dart`.

## Testing

Tests are organized as:
- `test/unit/features/game/` - Unit tests for controllers/services
- `test/widget/features/game/` - Widget tests for UI components
- `test/integration_test/` - Full gameplay flow tests

## Related Files

- `lib/services/providers.dart` - Global providers
- `lib/data/models/` - Data models
- `lib/core/theme.dart` - Visual styling
