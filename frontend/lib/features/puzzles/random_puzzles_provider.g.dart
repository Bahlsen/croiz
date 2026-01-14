// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'random_puzzles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that returns a random selection of puzzles for Quick Play mode.
///
/// Returns up to [kQuickPlayPuzzleCount] puzzles from the filtered list.
/// Use `ref.invalidate(randomPuzzlesProvider)` to get a new random selection.

@ProviderFor(randomPuzzles)
final randomPuzzlesProvider = RandomPuzzlesProvider._();

/// Provider that returns a random selection of puzzles for Quick Play mode.
///
/// Returns up to [kQuickPlayPuzzleCount] puzzles from the filtered list.
/// Use `ref.invalidate(randomPuzzlesProvider)` to get a new random selection.

final class RandomPuzzlesProvider
    extends
        $FunctionalProvider<
          List<PuzzleDescriptor>,
          List<PuzzleDescriptor>,
          List<PuzzleDescriptor>
        >
    with $Provider<List<PuzzleDescriptor>> {
  /// Provider that returns a random selection of puzzles for Quick Play mode.
  ///
  /// Returns up to [kQuickPlayPuzzleCount] puzzles from the filtered list.
  /// Use `ref.invalidate(randomPuzzlesProvider)` to get a new random selection.
  RandomPuzzlesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'randomPuzzlesProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[filteredPuzzlesProvider],
        $allTransitiveDependencies: <ProviderOrFamily>{
          RandomPuzzlesProvider.$allTransitiveDependencies0,
          RandomPuzzlesProvider.$allTransitiveDependencies1,
          RandomPuzzlesProvider.$allTransitiveDependencies2,
          RandomPuzzlesProvider.$allTransitiveDependencies3,
          RandomPuzzlesProvider.$allTransitiveDependencies4,
          RandomPuzzlesProvider.$allTransitiveDependencies5,
          RandomPuzzlesProvider.$allTransitiveDependencies6,
          RandomPuzzlesProvider.$allTransitiveDependencies7,
          RandomPuzzlesProvider.$allTransitiveDependencies8,
        },
      );

  static final $allTransitiveDependencies0 = filteredPuzzlesProvider;
  static final $allTransitiveDependencies1 =
      FilteredPuzzlesProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      FilteredPuzzlesProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies3 =
      FilteredPuzzlesProvider.$allTransitiveDependencies2;
  static final $allTransitiveDependencies4 =
      FilteredPuzzlesProvider.$allTransitiveDependencies3;
  static final $allTransitiveDependencies5 =
      FilteredPuzzlesProvider.$allTransitiveDependencies4;
  static final $allTransitiveDependencies6 =
      FilteredPuzzlesProvider.$allTransitiveDependencies5;
  static final $allTransitiveDependencies7 =
      FilteredPuzzlesProvider.$allTransitiveDependencies6;
  static final $allTransitiveDependencies8 =
      FilteredPuzzlesProvider.$allTransitiveDependencies7;

  @override
  String debugGetCreateSourceHash() => _$randomPuzzlesHash();

  @$internal
  @override
  $ProviderElement<List<PuzzleDescriptor>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PuzzleDescriptor> create(Ref ref) {
    return randomPuzzles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PuzzleDescriptor> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PuzzleDescriptor>>(value),
    );
  }
}

String _$randomPuzzlesHash() => r'477dadadbebe291197d85d8d7bb6d2c0f7d4fe6d';
