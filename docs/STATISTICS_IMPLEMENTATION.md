# Statistics & Leaderboards Implementation Plan

**Status**: ✅ Done  
**Started**: 2026-01-31  
**Estimated Completion**: 8-10 days

---

## 📋 Overview

Implement a comprehensive statistics tracking system with:
- User statistics (puzzles completed, streaks, play time)
- Per-puzzle statistics (completion time, accuracy)
- Achievements system
- Visual statistics dashboard

---

## 🎯 Phases

### ✅ Phase 0: Planning & Setup
- [x] Review existing database structure (Drift)
- [x] Plan data models and schema
- [ ] Create feature directory structure

### ✅ Phase 1: Data Model & Storage (Done)
**Goal**: Create Drift tables and Freezed models for statistics

#### Tasks:
- [x] Create `user_stats.dart` Freezed model
- [x] Create `puzzle_stat.dart` Freezed model  
- [x] Add Drift tables to database
- [x] Generate Drift code
- [x] Write unit tests for models

#### Files Created:
```
lib/features/statistics/
├── models/
│   ├── user_stats.dart
│   └── puzzle_stat.dart
├── data/
│   └── stats_tables.dart (in app_database.dart)
```

### ✅ Phase 2: Statistics Service (Done)
**Goal**: CRUD operations for statistics

#### Tasks:
- [x] Create `StatisticsService` class
- [x] Implement user stats CRUD
- [x] Implement puzzle stats CRUD
- [x] Create Riverpod providers
- [x] Write unit tests

#### Files Created:
```
lib/features/statistics/
├── services/
│   └── statistics_service.dart
├── providers/
│   └── statistics_providers.dart
```

### ✅ Phase 3: Statistics UI (Done)
**Goal**: Build statistics dashboard

#### Tasks:
- [x] Create `StatisticsScreen`
- [x] Build summary cards
- [x] Implement streak calendar
- [x] Add completion charts (fl_chart)
- [x] Write widget tests

#### Files Created:
```
lib/features/statistics/
├── screens/
│   └── statistics_screen.dart
├── widgets/
│   ├── stats_summary_card.dart
│   ├── streak_calendar.dart
│   └── completion_chart.dart
```

### ✅ Phase 4: Achievements System (Done)
**Goal**: Unlock and display achievements

#### Tasks:
- [x] Define Achievement enum
- [x] Create achievement logic
- [x] Build achievement badges UI
- [x] Implement unlock notifications

#### Files Created:
```
lib/features/statistics/
├── models/
│   └── achievement.dart
├── services/
│   └── achievement_service.dart
├── widgets/
│   └── achievement_badge.dart
```

### ✅ Phase 5: Integration (Done)
**Goal**: Connect statistics to game flow

#### Tasks:
- [x] Update `EndGameOverlay` to record stats
- [x] Add stats button to settings
- [x] Add `/statistics` route
- [x] Test end-to-end flow

#### Modified Files:
- `lib/features/game/services/game_endgame_service.dart`
- `lib/features/game/widgets/end_game_overlay.dart`
- `lib/features/game/widgets/bottom/crossword_controls_menu.dart`
- `lib/routes/app_routes.dart`

---

## 📊 Database Schema

### UserStats Table
```dart
class UserStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get totalPuzzlesCompleted => integer().withDefault(const Constant(0))();
  IntColumn get totalWordsFound => integer().withDefault(const Constant(0))();
  IntColumn get totalPlayTimeSeconds => integer().withDefault(const Constant(0))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

### PuzzleStats Table
```dart
class PuzzleStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get puzzleId => text()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get timeToCompleteSeconds => integer()();
  IntColumn get hintsUsed => integer().withDefault(const Constant(0))();
  RealColumn get accuracy => real()(); // 0.0 - 1.0
  IntColumn get totalWords => integer()();
  IntColumn get wordsRevealed => integer().withDefault(const Constant(0))();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### UserAchievements Table
```dart
class UserAchievementsTable extends Table {
  TextColumn get achievementId => text()();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {achievementId};
}
```

---

## 🎨 UI Components

### StatisticsScreen Layout
```
┌─────────────────────────────────────┐
│  📊 Your Statistics                 │
├─────────────────────────────────────┤
│  Summary Cards (3 columns)          │
│  ┌───────┐ ┌───────┐ ┌───────┐     │
│  │  42   │ │  🔥7  │ │ 23h   │     │
│  │Puzzles│ │Streak │ │ Time  │     │
│  └───────┘ └───────┘ └───────┘     │
├─────────────────────────────────────┤
│  Streak Calendar (Heatmap)          │
│  [GitHub-style contribution graph]  │
├─────────────────────────────────────┤
│  Completion Chart                   │
│  [Bar/Line chart with fl_chart]     │
├─────────────────────────────────────┤
│  🏅 Achievements                    │
│  [Badge grid with unlock status]    │
└─────────────────────────────────────┘
```

---

## 📦 Dependencies to Add

```yaml
dependencies:
  fl_chart: ^0.69.0  # For charts and graphs
  
# Already have:
# - drift (database)
# - freezed (models)
# - riverpod (state management)
```

---

## ✅ Testing Strategy

- **Unit Tests**: Models, services, streak calculation
- **Widget Tests**: All UI components
- **Integration Tests**: End-to-end stats recording flow

---

## 🔄 Progress Tracking

| Phase | Status | Progress | Notes |
|-------|--------|----------|-------|
| Phase 0 | ✅ Done | 100% | Planning complete |
| Phase 1 | ✅ Done | 100% | Models & DB implemented |
| Phase 2 | ✅ Done | 100% | Service & Providers implemented |
| Phase 3 | ✅ Done | 100% | Charts & Calendar implemented |
| Phase 4 | ✅ Done | 100% | Achievement logic & UI integrated |
| Phase 5 | ✅ Done | 100% | Stats integrated into game flow |

---

## 📝 Notes

- Use existing Drift database infrastructure
- Follow TDD approach (tests first)
- Ensure all stats are persisted immediately
- Handle edge cases (timezone changes, date boundaries for streaks)
- Make UI responsive and beautiful
