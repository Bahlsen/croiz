// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_loader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the currently selected puzzle id.
///
/// IMPORTANT: null means "no puzzle selected" (there is no default puzzle).

@ProviderFor(SelectedPuzzleIdNotifier)
final selectedPuzzleIdProvider = SelectedPuzzleIdNotifierProvider._();

/// Holds the currently selected puzzle id.
///
/// IMPORTANT: null means "no puzzle selected" (there is no default puzzle).
final class SelectedPuzzleIdNotifierProvider
    extends $NotifierProvider<SelectedPuzzleIdNotifier, String?> {
  /// Holds the currently selected puzzle id.
  ///
  /// IMPORTANT: null means "no puzzle selected" (there is no default puzzle).
  SelectedPuzzleIdNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedPuzzleIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedPuzzleIdNotifierHash();

  @$internal
  @override
  SelectedPuzzleIdNotifier create() => SelectedPuzzleIdNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedPuzzleIdNotifierHash() =>
    r'e6b5ccc20c525f4753eb823a9c481155ceabb8b4';

/// Holds the currently selected puzzle id.
///
/// IMPORTANT: null means "no puzzle selected" (there is no default puzzle).

abstract class _$SelectedPuzzleIdNotifier extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for the loader function so tests can override loading behavior.

@ProviderFor(puzzleAssetLoader)
final puzzleAssetLoaderProvider = PuzzleAssetLoaderProvider._();

/// Provider for the loader function so tests can override loading behavior.

final class PuzzleAssetLoaderProvider
    extends
        $FunctionalProvider<
          PuzzleLoaderFunction,
          PuzzleLoaderFunction,
          PuzzleLoaderFunction
        >
    with $Provider<PuzzleLoaderFunction> {
  /// Provider for the loader function so tests can override loading behavior.
  PuzzleAssetLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'puzzleAssetLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$puzzleAssetLoaderHash();

  @$internal
  @override
  $ProviderElement<PuzzleLoaderFunction> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PuzzleLoaderFunction create(Ref ref) {
    return puzzleAssetLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PuzzleLoaderFunction value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PuzzleLoaderFunction>(value),
    );
  }
}

String _$puzzleAssetLoaderHash() => r'a69a41c1ba12f71af950b1c42d1348e5ca0f951c';

/// Provider to load the puzzle asynchronously from JSON.
///
/// IMPORTANT: this does **not** load any default puzzle. A puzzle id must be
/// selected via `selectedPuzzleIdProvider` (or tests must override this
/// provider). This guarantees we never silently load the same puzzle.

@ProviderFor(puzzleLoader)
final puzzleLoaderProvider = PuzzleLoaderProvider._();

/// Provider to load the puzzle asynchronously from JSON.
///
/// IMPORTANT: this does **not** load any default puzzle. A puzzle id must be
/// selected via `selectedPuzzleIdProvider` (or tests must override this
/// provider). This guarantees we never silently load the same puzzle.

final class PuzzleLoaderProvider
    extends
        $FunctionalProvider<
          AsyncValue<GameBoard>,
          GameBoard,
          FutureOr<GameBoard>
        >
    with $FutureModifier<GameBoard>, $FutureProvider<GameBoard> {
  /// Provider to load the puzzle asynchronously from JSON.
  ///
  /// IMPORTANT: this does **not** load any default puzzle. A puzzle id must be
  /// selected via `selectedPuzzleIdProvider` (or tests must override this
  /// provider). This guarantees we never silently load the same puzzle.
  PuzzleLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'puzzleLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$puzzleLoaderHash();

  @$internal
  @override
  $FutureProviderElement<GameBoard> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GameBoard> create(Ref ref) {
    return puzzleLoader(ref);
  }
}

String _$puzzleLoaderHash() => r'057d81f21cce8363cc25b7d431463f2a9b9e39e2';
