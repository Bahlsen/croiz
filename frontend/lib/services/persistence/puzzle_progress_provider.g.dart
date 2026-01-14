// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(puzzleJsonLoader)
final puzzleJsonLoaderProvider = PuzzleJsonLoaderProvider._();

final class PuzzleJsonLoaderProvider
    extends
        $FunctionalProvider<
          PuzzleJsonLoader,
          PuzzleJsonLoader,
          PuzzleJsonLoader
        >
    with $Provider<PuzzleJsonLoader> {
  PuzzleJsonLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'puzzleJsonLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$puzzleJsonLoaderHash();

  @$internal
  @override
  $ProviderElement<PuzzleJsonLoader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PuzzleJsonLoader create(Ref ref) {
    return puzzleJsonLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PuzzleJsonLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PuzzleJsonLoader>(value),
    );
  }
}

String _$puzzleJsonLoaderHash() => r'ab34b3fdb9f6b5e096f8311d91ca9cc05c8fb7c9';

@ProviderFor(puzzleProgressService)
final puzzleProgressServiceProvider = PuzzleProgressServiceProvider._();

final class PuzzleProgressServiceProvider
    extends
        $FunctionalProvider<
          PuzzleProgressService,
          PuzzleProgressService,
          PuzzleProgressService
        >
    with $Provider<PuzzleProgressService> {
  PuzzleProgressServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'puzzleProgressServiceProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[
          puzzleStorageProvider,
          puzzleJsonLoaderProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>[
          PuzzleProgressServiceProvider.$allTransitiveDependencies0,
          PuzzleProgressServiceProvider.$allTransitiveDependencies1,
          PuzzleProgressServiceProvider.$allTransitiveDependencies2,
        ],
      );

  static final $allTransitiveDependencies0 = puzzleStorageProvider;
  static final $allTransitiveDependencies1 =
      PuzzleStorageProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 = puzzleJsonLoaderProvider;

  @override
  String debugGetCreateSourceHash() => _$puzzleProgressServiceHash();

  @$internal
  @override
  $ProviderElement<PuzzleProgressService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PuzzleProgressService create(Ref ref) {
    return puzzleProgressService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PuzzleProgressService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PuzzleProgressService>(value),
    );
  }
}

String _$puzzleProgressServiceHash() =>
    r'34ca4b14dd5528b0362fd01b2da51f10634ea5dd';
