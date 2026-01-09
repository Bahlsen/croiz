// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filtered_puzzles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that returns the set of completed puzzle IDs.
///
/// A puzzle is considered "completed" if it has been saved with 100%
/// completion in storage. This checks the `isCompleted` field in the
/// saved puzzle data.

@ProviderFor(completedPuzzleIds)
final completedPuzzleIdsProvider = CompletedPuzzleIdsProvider._();

/// Provider that returns the set of completed puzzle IDs.
///
/// A puzzle is considered "completed" if it has been saved with 100%
/// completion in storage. This checks the `isCompleted` field in the
/// saved puzzle data.

final class CompletedPuzzleIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// Provider that returns the set of completed puzzle IDs.
  ///
  /// A puzzle is considered "completed" if it has been saved with 100%
  /// completion in storage. This checks the `isCompleted` field in the
  /// saved puzzle data.
  CompletedPuzzleIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedPuzzleIdsProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[puzzleStorageProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          CompletedPuzzleIdsProvider.$allTransitiveDependencies0,
          CompletedPuzzleIdsProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = puzzleStorageProvider;
  static final $allTransitiveDependencies1 =
      PuzzleStorageProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$completedPuzzleIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return completedPuzzleIds(ref);
  }
}

String _$completedPuzzleIdsHash() =>
    r'0f3b870921246b48e95c64450a238c057875671b';

/// Provider that returns all available languages from the puzzle index.
///
/// Derives the set of unique language codes from all puzzles.

@ProviderFor(availableLanguages)
final availableLanguagesProvider = AvailableLanguagesProvider._();

/// Provider that returns all available languages from the puzzle index.
///
/// Derives the set of unique language codes from all puzzles.

final class AvailableLanguagesProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  /// Provider that returns all available languages from the puzzle index.
  ///
  /// Derives the set of unique language codes from all puzzles.
  AvailableLanguagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableLanguagesProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[puzzlesProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          AvailableLanguagesProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = puzzlesProvider;

  @override
  String debugGetCreateSourceHash() => _$availableLanguagesHash();

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    return availableLanguages(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$availableLanguagesHash() =>
    r'8827e06cbe172600d85222d63e1f7f3e6ffaff64';

/// Provider that returns all available difficulties from the puzzle index.
///
/// Derives the set of unique difficulty levels from all puzzles.

@ProviderFor(availableDifficulties)
final availableDifficultiesProvider = AvailableDifficultiesProvider._();

/// Provider that returns all available difficulties from the puzzle index.
///
/// Derives the set of unique difficulty levels from all puzzles.

final class AvailableDifficultiesProvider
    extends $FunctionalProvider<Set<int>, Set<int>, Set<int>>
    with $Provider<Set<int>> {
  /// Provider that returns all available difficulties from the puzzle index.
  ///
  /// Derives the set of unique difficulty levels from all puzzles.
  AvailableDifficultiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableDifficultiesProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[puzzlesProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          AvailableDifficultiesProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = puzzlesProvider;

  @override
  String debugGetCreateSourceHash() => _$availableDifficultiesHash();

  @$internal
  @override
  $ProviderElement<Set<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<int> create(Ref ref) {
    return availableDifficulties(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$availableDifficultiesHash() =>
    r'e7c8d93cf0425bc1bb43f1b06de4a8415ad1cb97';

/// Provider that returns puzzles filtered by the current filter state.
///
/// Watches both [puzzlesProvider] and [puzzleFilterProvider] and returns
/// only puzzles that match the current filters.

@ProviderFor(filteredPuzzles)
final filteredPuzzlesProvider = FilteredPuzzlesProvider._();

/// Provider that returns puzzles filtered by the current filter state.
///
/// Watches both [puzzlesProvider] and [puzzleFilterProvider] and returns
/// only puzzles that match the current filters.

final class FilteredPuzzlesProvider
    extends
        $FunctionalProvider<
          List<PuzzleDescriptor>,
          List<PuzzleDescriptor>,
          List<PuzzleDescriptor>
        >
    with $Provider<List<PuzzleDescriptor>> {
  /// Provider that returns puzzles filtered by the current filter state.
  ///
  /// Watches both [puzzlesProvider] and [puzzleFilterProvider] and returns
  /// only puzzles that match the current filters.
  FilteredPuzzlesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredPuzzlesProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[
          puzzlesProvider,
          puzzleFilterProvider,
          completedPuzzleIdsProvider,
          availableLanguagesProvider,
          pendingPuzzlesProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>{
          FilteredPuzzlesProvider.$allTransitiveDependencies0,
          FilteredPuzzlesProvider.$allTransitiveDependencies1,
          FilteredPuzzlesProvider.$allTransitiveDependencies2,
          FilteredPuzzlesProvider.$allTransitiveDependencies3,
          FilteredPuzzlesProvider.$allTransitiveDependencies4,
          FilteredPuzzlesProvider.$allTransitiveDependencies5,
          FilteredPuzzlesProvider.$allTransitiveDependencies6,
        },
      );

  static final $allTransitiveDependencies0 = puzzlesProvider;
  static final $allTransitiveDependencies1 = puzzleFilterProvider;
  static final $allTransitiveDependencies2 = completedPuzzleIdsProvider;
  static final $allTransitiveDependencies3 =
      CompletedPuzzleIdsProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies4 =
      CompletedPuzzleIdsProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies5 = availableLanguagesProvider;
  static final $allTransitiveDependencies6 = pendingPuzzlesProvider;

  @override
  String debugGetCreateSourceHash() => _$filteredPuzzlesHash();

  @$internal
  @override
  $ProviderElement<List<PuzzleDescriptor>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PuzzleDescriptor> create(Ref ref) {
    return filteredPuzzles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PuzzleDescriptor> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PuzzleDescriptor>>(value),
    );
  }
}

String _$filteredPuzzlesHash() => r'9f085759425cbc02ac83a7591f837a61a7ce211c';
