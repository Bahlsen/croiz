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
        dependencies: null,
        $allTransitiveDependencies: null,
      );

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
    r'948dac9809ad27aaba74017394b765f397bbe013';

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
        dependencies: null,
        $allTransitiveDependencies: null,
      );

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
    r'39d66ba66ef7e7a03c57a7816bfd6406ccfc0319';

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
        dependencies: null,
        $allTransitiveDependencies: null,
      );

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
    r'5aa98cffdd1b5b492f345301459c2ba56bc87e0f';

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
        dependencies: null,
        $allTransitiveDependencies: null,
      );

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

String _$filteredPuzzlesHash() => r'b6c7c196697ac0c43378d8425714034a3aeea140';
