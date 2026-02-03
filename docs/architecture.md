# Croiz Project Architecture

Comprehensive architecture documentation for the Croiz crossword game project.

## System Architecture Overview

Croiz is a **client-side first** mobile application built with Flutter. It operates primarily offline, using local databases for storage and on-device algorithms for puzzle generation. External services (Firebase) are used only for specific optional features (AI themes) and monetization (Ads).

```
┌─────────────────────────────────────────────────────────────┐
│                    Mobile Client (Flutter)                   │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │      UI      │  │    Logic     │  │      Data         │  │
│  │  (Widgets)   │  │  (Riverpod)  │  │ (Drift/Services)  │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬──────────┘  │
│         │                 │                   │             │
└─────────┼─────────────────┼───────────────────┼─────────────┘
          │                 │                   │
          ▼                 ▼                   ▼
┌──────────────────┐  ┌─────────────┐   ┌────────────────┐
│   Local Device   │  │   Firebase  │   │     Google     │
│    (SQLite)      │  │Vertex AI API│   │   Mobile Ads   │
└──────────────────┘  └─────────────┘   └────────────────┘
```

## Frontend Architecture (Flutter + Riverpod)

### Layered Architecture

We follow a strict separation of concerns using Clean Architecture principles:

```
Presentation Layer
├── Screens (Game, PuzzlesList, Statistics, Settings)
├── Widgets (CrosswordGrid, VirtualKeyboard, AchievementNotification)
└── Theme (CrosswordThemeColors, AppTheme)

Application/State Layer (Riverpod)
├── Notifiers (GameBoardNotifier, StatisticsNotifier, AchievementNotifier)
├── Providers (puzzleStorageProvider, audioServiceProvider)
└── State Objects (GameState, UserStats, AchievementState)

Domain Layer
├── Entities (Puzzle, Word, Cell, Achievement)
├── Logic (GridFirstGenerator, CSP Solver)
└── Interfaces (IGamePersistenceService)

Data Layer
├── Repositories (PuzzleRepository, StatisticsRepository)
├── Data Sources
│   ├── Local Database (Drift/SQLite)
│   ├── Asset Bundle (JSON Puzzles)
│   └── Shared Preferences (Settings)
└── Services (AudioService, HapticService, AdService)
```

### Directory Structure

```
frontend/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── core/                        # Core utilities
│   │   ├── config/                  # App configuration
│   │   ├── theme/                   # Theme definitions
│   │   └── utils/                   # Helper functions
│   ├── data/
│   │   ├── local/                   # Drift Database definitions
│   │   └── repositories/            # Data access implementation
│   ├── domain/                      # Entities and business logic interfaces
│   ├── features/                    # Feature-based organization
│   │   ├── game/                    # Main gameplay
│   │   ├── puzzles/                 # Puzzle list and selection
│   │   ├── generation/              # AI Puzzle Generation (GADDAG/CSP)
│   │   ├── statistics/              # Stats & Achievements
│   │   ├── settings/                # User preferences
│   │   ├── onboarding/              # First-run experience/Tutorial
│   │   └── monetization/            # Ads and (future) subscriptions
│   ├── l10n/                        # Localization (ARB files)
│   ├── routes/                      # GoRouter definitions
│   └── services/                    # Global services (Audio, Persistence)
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration_test/
└── pubspec.yaml
```

### State Management (Riverpod 3.0)

We use Riverpod for dependency injection and state management.

- **`@Riverpod` Annotation**: utilized for generating providers, ensuring type safety and auto-disposal.
- **StateNotifier**: Used for complex states (Game, Statistics).
- **FutureProvider**: Used for asynchronous data loading (Loading puzzles from DB).
- **StreamProvider**: Used for reactive updates (Listening to achievement unlocks).

### Key Providers

```dart
// Game Logic
@riverpod
class GameBoardNotifier extends _$GameBoardNotifier { ... }

// Stats
@riverpod
class UserStatsNotifier extends _$UserStatsNotifier { ... }

// Achievements
final achievementNotifierProvider = StreamProvider<AchievementId>(...);

// Storage
final puzzleStorageProvider = Provider<PuzzleStorageRepository>(...);
```

## Core Systems

### 1. Puzzle Generation Engine (v3.14)
The app generates puzzles locally using a **Grid-First** approach:
- **GADDAG**: A directed acyclic graph data structure for fast bidirectional pattern matching.
- **CSP (Constraint Satisfaction Problem)**: Uses Arc Consistency (AC-3) and backtracking with Minimum Remaining Values (MRV) heuristics.
- **Isolates**: Generation runs in a background isolate to prevent UI jank.

### 2. Persistence (Drift/SQLite)
All user data is stored locally in a SQLite database via the `drift` package.
- **Tables**: `Puzzles`, `UserStats`, `PuzzleStats`, `Achievements`.
- **Migrations**: Automated schema migrations handled by Drift.

### 3. Monetization
- **Google Mobile Ads**: Banner ads on list screens, Interstitial ads after game completion.
- **Ad Flow**: Strict management to ensure ads do not overlap with achievement popups or critical game UI.

### 4. Localization
- Supports 8 languages.
- Uses `flutter_localizations` with `.arb` files.
- Dynamic key mapping for game-specific terms.

## Data Flow Example: Completing a Puzzle

1.  **User Action**: Enters final letter in `CrosswordGrid`.
2.  **State Update**: `GameBoardNotifier` validates the grid.
3.  **Event Trigger**: If correct, `GameEndService` is called.
4.  **Persistence**:
    *   Puzzle marked as 'completed' in `PuzzleStorage`.
    *   Stats updated (time, hints) in `StatisticsService`.
5.  **Analytics**: `AchievementService` checks for new unlocks (e.g., "Speed Demon").
6.  **UI Feedback**:
    *   `AchievementListener` shows popup (if any).
    *   `EndGameOverlay` appears with confetti.
    *   Interstitial Ad may load (controlled by `AdService`).

## Security & Privacy (Local First)

- **No Backend**: No user data is sent to any remote server (except standard anonymous analytics/ads via Google SDKs).
- **Offline Capable**: The app is fully functional without internet access (except for generating *new* themes via AI).
- **Data Ownership**: All puzzle progress and statistics reside on the user's device.

## Deployment Pipeline

Code is pushed to GitHub, where Actions run:
1.  **Analysis**: `flutter analyze`
2.  **Testing**: `flutter test`
3.  **Build**: (Future) Fastlane integration for App Store/Play Store deployment.

---

**Last Updated**: February 2026
