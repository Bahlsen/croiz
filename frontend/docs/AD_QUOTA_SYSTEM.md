# Ad Quota & Monetization System

## Overview
The Ad Quota System is a monetization feature designed to balance user experience with revenue generation. It controls access to game hints (reveals) and serves interstitial ads based on game usage.

## Key Features

### 1. Reveal Quotas (Freemium)
All non-premium users have a limited number of "free" reveals per session. These quotas are persisted locally.
- **Letter Reveals**: 10 free letters.
- **Word Reveals**: 3 free words.

**Replenishment:**
- When a user runs out of quotas, they are prompted to watch a **Rewarded Ad**.
- Watching the ad fully replenishes the specific quota (reset to 10 letters or 3 words).

### 2. "Reveal All" Gate
- The "Reveal All" action is **always** gated behind a Rewarded Ad for non-premium users.
- Users must explicitly confirm and watch the ad to unlock the full solution.

### 3. Interstitial Ad Triggers
Interstitial ads are shown based on game engagement (puzzle loads).
- **Trigger Rule**: Every 4th puzzle load (e.g., 4th, 8th, 12th).
- **Trigger Location**: When tapping a puzzle card in the list to open it.
- **Logic**:
  1. User taps functionality.
  2. `MonetizationService` increments load count.
  3. If count % 4 == 0, `showInterstitialAd()` is called.
  4. User watches/closes ad -> Navigation proceeds.

### 4. Premium Bypass
Users with an active subscription (`isPremium = true`) bypass **all** ad checks.
- Infinite reveals.
- "Reveal All" without ads.
- No interstitial ads on puzzle load.

## Technical Implementation

### 1. Data Layer (`domain/entities/game_entities.dart`)
We modified the `GameBoard` entity to hold the transient state of ad quotas. This ensures that the quota is tied to the current game session and can be persisted/restored with the puzzle progress.

```dart
class GameBoard extends GameEntity {
  // ... existing fields
  final int lettersUntilAd; // Default: 10
  final int wordsUntilAd;   // Default: 3
  
  // copyWith updated to include these fields
}
```

### 2. Service Layer

#### `MonetizationService` (`features/monetization/services/ad_service.dart`)
This service is the central hub for AdMob integration.
- **Initialization**: Loads both Interstitial and Rewarded ads on startup.
- **Tracking**: Uses `SharedPreferences` to store `puzzles_loaded_count`.
- **Interstitial Logic**:
  ```dart
  // Trigger on every 4th puzzle (1,2,3 -> Ad on 4)
  bool get shouldShowInterstitial => _puzzlesLoadedCount > 0 && _puzzlesLoadedCount % 4 == 0;
  ```
- **Rewarded Logic**:
  - `showRewardedAd()` returns a `Future<bool>` indicating if the user earned the reward.
  - Handles `_pendingShowRewardedRequest` if `show()` is called while an ad is still loading (though UI usually gates this).

#### `GamePersistenceService` (`features/game/services/game_persistence_service.dart`)
- **Schema Update**: Payload schema version bumped to `2`.
- **Fields**: Adds `lettersUntilAd` and `wordsUntilAd` to the JSON payload.
- **Logic**: 
  - On `save`: Serializes current quota values.
  - On `load`: Deserializes values or falls back to defaults (10/3) if missing (migration).

#### `GameBoardNotifier` (`features/game/providers/game_board_notifier.dart`)
Handles the business logic for decrementing quotas and checking limits.
- **Decrementation**:
  Inside `revealLetterAt` and `revealEntry`, we check if `quota > 0` before decrementing.
  ```dart
  var newQuota = state.lettersUntilAd;
  if (newQuota > 0) newQuota--;
  state = state.copyWith(..., lettersUntilAd: newQuota);
  _schedulePersist();
  ```
- **Replenishment**:
  Exposes methods called by the UI after a successful ad watch.
  ```dart
  void replenishLetterQuota() {
    state = state.copyWith(lettersUntilAd: 10);
    _schedulePersist();
  }
  ```

### 3. UI Layer & User Flow

#### Interstitial Ad Flow (`PuzzleCard`)
Located in `features/puzzles/widgets/puzzle_card.dart`.
1. User taps a puzzle.
2. `_onTap` checks `subscriptionProvider`.
   - **If Premium**: Navigates immediately.
   - **If Free**:
     1. Calls `adService.incrementPuzzleLoadCount()`.
     2. Checks `adService.shouldShowInterstitial`.
     3. If true, calls `await adService.showInterstitialAd()`.
     4. Navigates to puzzle.

#### Reveal Quota Flow (`CrosswordControlsBar`)
Located in `features/game/widgets/bottom/crossword_controls_bar.dart`.
1. User acts (Reveal Letter/Word).
2. `_checkAdQuota(currentQuota, callback)` is called.
3. **Check**:
   - If `currentQuota > 0`: Returns `true` (allow action).
   - If `currentQuota == 0`:
     1. Shows `AlertDialog`: "Watch Ad?"
     2. If User cancels: Returns `false`.
     3. If User accepts:
        - Calls `adService.showRewardedAd()`.
        - If result is `true` (rewarded):
          - Calls `callback()` (e.g., `replenishLetterQuota`).
          - Returns `true`.
        - Else: Returns `false`.

#### Reveal All Flow
Strictly gated.
1. User taps "Reveal All".
2. Shows `AlertDialog`: "Must watch ad to reveal all."
3. If confirmed, `adService.showRewardedAd()` is awaited.
4. Only if `true`, `notifier.revealAll()` is called.

### 4. Localization
All user-facing strings are localized in `app_en.arb` and `app_fr.arb`.
- `watchAdTitle`
- `watchAdMessage`
- `revealAllAdMessage`

### 5. Testing Infrastructure
`FakeMonetizationService` (`test/helpers/fake_monetization_service.dart`) was updated to support integration tests.
- Implements `showRewardedAd` to auto-return `true` (mocking a watched ad).
- Implements `incrementPuzzleLoadCount` (no-op or in-memory tracking for tests).
