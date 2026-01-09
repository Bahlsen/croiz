// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(puzzleStorage)
final puzzleStorageProvider = PuzzleStorageProvider._();

final class PuzzleStorageProvider
    extends
        $FunctionalProvider<
          PuzzleStorageInterface,
          PuzzleStorageInterface,
          PuzzleStorageInterface
        >
    with $Provider<PuzzleStorageInterface> {
  PuzzleStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'puzzleStorageProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[appDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          PuzzleStorageProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = appDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$puzzleStorageHash();

  @$internal
  @override
  $ProviderElement<PuzzleStorageInterface> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PuzzleStorageInterface create(Ref ref) {
    return puzzleStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PuzzleStorageInterface value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PuzzleStorageInterface>(value),
    );
  }
}

String _$puzzleStorageHash() => r'a5d609221b5a30da9bc7a86e6b16086b077e87ed';
