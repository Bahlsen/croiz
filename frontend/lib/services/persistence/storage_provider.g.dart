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
        dependencies: null,
        $allTransitiveDependencies: null,
      );

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

String _$puzzleStorageHash() => r'92ef9a645bcfc466011792e7f0023f16995358a8';
