// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_board_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Duration used to schedule clearing of flashed cells after animations.
/// Tests can override this provider to `Duration.zero` to avoid scheduling
/// real timers (FakeAsync-friendly).

@ProviderFor(flashClearDelay)
final flashClearDelayProvider = FlashClearDelayProvider._();

/// Duration used to schedule clearing of flashed cells after animations.
/// Tests can override this provider to `Duration.zero` to avoid scheduling
/// real timers (FakeAsync-friendly).

final class FlashClearDelayProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// Duration used to schedule clearing of flashed cells after animations.
  /// Tests can override this provider to `Duration.zero` to avoid scheduling
  /// real timers (FakeAsync-friendly).
  FlashClearDelayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flashClearDelayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flashClearDelayHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return flashClearDelay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$flashClearDelayHash() => r'a107336325a692715e5eaa6eb4ae5f8b1a963eff';

/// Debounce delay for word completion checks during fast typing.
/// In production: 16ms (one frame) to batch checks while staying responsive.
/// Tests can override to Duration.zero for synchronous checks.

@ProviderFor(wordCheckDebounceDelay)
final wordCheckDebounceDelayProvider = WordCheckDebounceDelayProvider._();

/// Debounce delay for word completion checks during fast typing.
/// In production: 16ms (one frame) to batch checks while staying responsive.
/// Tests can override to Duration.zero for synchronous checks.

final class WordCheckDebounceDelayProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// Debounce delay for word completion checks during fast typing.
  /// In production: 16ms (one frame) to batch checks while staying responsive.
  /// Tests can override to Duration.zero for synchronous checks.
  WordCheckDebounceDelayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordCheckDebounceDelayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordCheckDebounceDelayHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return wordCheckDebounceDelay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$wordCheckDebounceDelayHash() =>
    r'74fa28b70bee9450f53ea1c639c50ca4c0d5924d';

/// Main notifier for the game board state.

@ProviderFor(GameBoardNotifier)
final gameBoardProvider = GameBoardNotifierProvider._();

/// Main notifier for the game board state.
final class GameBoardNotifierProvider
    extends $NotifierProvider<GameBoardNotifier, GameBoard> {
  /// Main notifier for the game board state.
  GameBoardNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameBoardProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[
          puzzleLoaderProvider,
          gamePersistenceServiceProvider,
          gameProgressServiceProvider,
          gameRevealServiceProvider,
          gameEndgameServiceProvider,
          selectedPuzzleIdProvider,
          selectedCellProvider,
          foundWordsProvider,
          lockedCellsProvider,
          flashingCellsProvider,
          flashingClearedCellsProvider,
          flashClearDelayProvider,
          gameTimerProvider,
          audioMutedProvider,
          gameAudioServiceProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>{
          GameBoardNotifierProvider.$allTransitiveDependencies0,
          GameBoardNotifierProvider.$allTransitiveDependencies1,
          GameBoardNotifierProvider.$allTransitiveDependencies2,
          GameBoardNotifierProvider.$allTransitiveDependencies3,
          GameBoardNotifierProvider.$allTransitiveDependencies4,
          GameBoardNotifierProvider.$allTransitiveDependencies5,
          GameBoardNotifierProvider.$allTransitiveDependencies6,
          GameBoardNotifierProvider.$allTransitiveDependencies7,
          GameBoardNotifierProvider.$allTransitiveDependencies8,
          GameBoardNotifierProvider.$allTransitiveDependencies9,
          GameBoardNotifierProvider.$allTransitiveDependencies10,
          GameBoardNotifierProvider.$allTransitiveDependencies11,
          GameBoardNotifierProvider.$allTransitiveDependencies12,
          GameBoardNotifierProvider.$allTransitiveDependencies13,
          GameBoardNotifierProvider.$allTransitiveDependencies14,
          GameBoardNotifierProvider.$allTransitiveDependencies15,
          GameBoardNotifierProvider.$allTransitiveDependencies16,
          GameBoardNotifierProvider.$allTransitiveDependencies17,
          GameBoardNotifierProvider.$allTransitiveDependencies18,
          GameBoardNotifierProvider.$allTransitiveDependencies19,
          GameBoardNotifierProvider.$allTransitiveDependencies20,
          GameBoardNotifierProvider.$allTransitiveDependencies21,
          GameBoardNotifierProvider.$allTransitiveDependencies22,
          GameBoardNotifierProvider.$allTransitiveDependencies23,
          GameBoardNotifierProvider.$allTransitiveDependencies24,
        },
      );

  static final $allTransitiveDependencies0 = puzzleLoaderProvider;
  static final $allTransitiveDependencies1 =
      PuzzleLoaderProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      PuzzleLoaderProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies3 =
      PuzzleLoaderProvider.$allTransitiveDependencies2;
  static final $allTransitiveDependencies4 =
      PuzzleLoaderProvider.$allTransitiveDependencies3;
  static final $allTransitiveDependencies5 =
      PuzzleLoaderProvider.$allTransitiveDependencies4;
  static final $allTransitiveDependencies6 =
      PuzzleLoaderProvider.$allTransitiveDependencies5;
  static final $allTransitiveDependencies7 = gamePersistenceServiceProvider;
  static final $allTransitiveDependencies8 = gameProgressServiceProvider;
  static final $allTransitiveDependencies9 =
      GameProgressServiceProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies10 = gameRevealServiceProvider;
  static final $allTransitiveDependencies11 = gameEndgameServiceProvider;
  static final $allTransitiveDependencies12 =
      GameEndgameServiceProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies13 =
      GameEndgameServiceProvider.$allTransitiveDependencies2;
  static final $allTransitiveDependencies14 =
      GameEndgameServiceProvider.$allTransitiveDependencies3;
  static final $allTransitiveDependencies15 = selectedCellProvider;
  static final $allTransitiveDependencies16 = foundWordsProvider;
  static final $allTransitiveDependencies17 = lockedCellsProvider;
  static final $allTransitiveDependencies18 = flashingCellsProvider;
  static final $allTransitiveDependencies19 = flashingClearedCellsProvider;
  static final $allTransitiveDependencies20 = flashClearDelayProvider;
  static final $allTransitiveDependencies21 = gameTimerProvider;
  static final $allTransitiveDependencies22 = audioMutedProvider;
  static final $allTransitiveDependencies23 =
      AudioMutedNotifierProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies24 = gameAudioServiceProvider;

  @override
  String debugGetCreateSourceHash() => _$gameBoardNotifierHash();

  @$internal
  @override
  GameBoardNotifier create() => GameBoardNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameBoard value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameBoard>(value),
    );
  }
}

String _$gameBoardNotifierHash() => r'2734d9d8717a22e3d1470932288453968ebc4392';

/// Main notifier for the game board state.

abstract class _$GameBoardNotifier extends $Notifier<GameBoard> {
  GameBoard build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GameBoard, GameBoard>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GameBoard, GameBoard>,
              GameBoard,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
