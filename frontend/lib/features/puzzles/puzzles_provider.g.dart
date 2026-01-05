// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// FutureProvider that enumerates puzzle JSONs and extracts basic metadata (id/title/path).
///
/// Strict behaviour: requires `assets/data/puzzles_index.json` to exist and contain
/// a JSON object with an "items" array. Each item must have an "origin" field.
/// Provider that returns the list of available origins (for lazy-loading).

@ProviderFor(puzzleOrigins)
final puzzleOriginsProvider = PuzzleOriginsProvider._();

/// FutureProvider that enumerates puzzle JSONs and extracts basic metadata (id/title/path).
///
/// Strict behaviour: requires `assets/data/puzzles_index.json` to exist and contain
/// a JSON object with an "items" array. Each item must have an "origin" field.
/// Provider that returns the list of available origins (for lazy-loading).

final class PuzzleOriginsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// FutureProvider that enumerates puzzle JSONs and extracts basic metadata (id/title/path).
  ///
  /// Strict behaviour: requires `assets/data/puzzles_index.json` to exist and contain
  /// a JSON object with an "items" array. Each item must have an "origin" field.
  /// Provider that returns the list of available origins (for lazy-loading).
  PuzzleOriginsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'puzzleOriginsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$puzzleOriginsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return puzzleOrigins(ref);
  }
}

String _$puzzleOriginsHash() => r'3376e61369a9a58d0e6b01c9a763751e8b3df1c2';

@ProviderFor(originIndex)
final originIndexProvider = OriginIndexFamily._();

final class OriginIndexProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PuzzleDescriptor>>,
          List<PuzzleDescriptor>,
          FutureOr<List<PuzzleDescriptor>>
        >
    with
        $FutureModifier<List<PuzzleDescriptor>>,
        $FutureProvider<List<PuzzleDescriptor>> {
  OriginIndexProvider._({
    required OriginIndexFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'originIndexProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$originIndexHash();

  @override
  String toString() {
    return r'originIndexProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PuzzleDescriptor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PuzzleDescriptor>> create(Ref ref) {
    final argument = this.argument as String;
    return originIndex(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OriginIndexProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$originIndexHash() => r'f02af96473eb029eb8f394fc6a234523240e8ff9';

final class OriginIndexFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PuzzleDescriptor>>, String> {
  OriginIndexFamily._()
    : super(
        retry: null,
        name: r'originIndexProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OriginIndexProvider call(String origin) =>
      OriginIndexProvider._(argument: origin, from: this);

  @override
  String toString() => r'originIndexProvider';
}

@ProviderFor(puzzles)
final puzzlesProvider = PuzzlesProvider._();

final class PuzzlesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PuzzleDescriptor>>,
          List<PuzzleDescriptor>,
          FutureOr<List<PuzzleDescriptor>>
        >
    with
        $FutureModifier<List<PuzzleDescriptor>>,
        $FutureProvider<List<PuzzleDescriptor>> {
  PuzzlesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'puzzlesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$puzzlesHash();

  @$internal
  @override
  $FutureProviderElement<List<PuzzleDescriptor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PuzzleDescriptor>> create(Ref ref) {
    return puzzles(ref);
  }
}

String _$puzzlesHash() => r'5c8f25063d8a9ad8f93c85bff7f2b2fef1f8d780';

/// Loads full metadata for a single puzzle asset path on demand.

@ProviderFor(puzzleMetadata)
final puzzleMetadataProvider = PuzzleMetadataFamily._();

/// Loads full metadata for a single puzzle asset path on demand.

final class PuzzleMetadataProvider
    extends
        $FunctionalProvider<
          AsyncValue<PuzzleDescriptor>,
          PuzzleDescriptor,
          FutureOr<PuzzleDescriptor>
        >
    with $FutureModifier<PuzzleDescriptor>, $FutureProvider<PuzzleDescriptor> {
  /// Loads full metadata for a single puzzle asset path on demand.
  PuzzleMetadataProvider._({
    required PuzzleMetadataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'puzzleMetadataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$puzzleMetadataHash();

  @override
  String toString() {
    return r'puzzleMetadataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PuzzleDescriptor> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PuzzleDescriptor> create(Ref ref) {
    final argument = this.argument as String;
    return puzzleMetadata(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PuzzleMetadataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$puzzleMetadataHash() => r'7891ec4871519d9809622374176e7013707c5f7a';

/// Loads full metadata for a single puzzle asset path on demand.

final class PuzzleMetadataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PuzzleDescriptor>, String> {
  PuzzleMetadataFamily._()
    : super(
        retry: null,
        name: r'puzzleMetadataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads full metadata for a single puzzle asset path on demand.

  PuzzleMetadataProvider call(String path) =>
      PuzzleMetadataProvider._(argument: path, from: this);

  @override
  String toString() => r'puzzleMetadataProvider';
}
