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
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
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

String _$puzzleOriginsHash() => r'5e21161037c51a05c1c0ccd28fd4053610057592';

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

String _$originIndexHash() => r'436aece4d5dd686f83f7276cd1db69b7ed705714';

final class OriginIndexFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PuzzleDescriptor>>, String> {
  OriginIndexFamily._()
    : super(
        retry: null,
        name: r'originIndexProvider',
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
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
        isAutoDispose: false,
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

String _$puzzlesHash() => r'c31ab319970e638fd28bdf2eaf6d294a4002286d';

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

String _$puzzleMetadataHash() => r'3fa82730facd8304752cf9ed6d09aeaf6eff6b8f';

/// Loads full metadata for a single puzzle asset path on demand.

final class PuzzleMetadataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PuzzleDescriptor>, String> {
  PuzzleMetadataFamily._()
    : super(
        retry: null,
        name: r'puzzleMetadataProvider',
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
        isAutoDispose: true,
      );

  /// Loads full metadata for a single puzzle asset path on demand.

  PuzzleMetadataProvider call(String path) =>
      PuzzleMetadataProvider._(argument: path, from: this);

  @override
  String toString() => r'puzzleMetadataProvider';
}
