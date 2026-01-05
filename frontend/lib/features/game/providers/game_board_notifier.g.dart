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

String _$flashClearDelayHash() => r'7d6fb3e168802938de722243788a3d74e1a31dbe';

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
        dependencies: null,
        $allTransitiveDependencies: null,
      );

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

String _$gameBoardNotifierHash() => r'2b1389d12f67da26c385809e565a3d159633fe96';

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
