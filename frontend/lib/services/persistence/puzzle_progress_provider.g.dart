// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
        dependencies: <ProviderOrFamily>[puzzleStorageProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          PuzzleProgressServiceProvider.$allTransitiveDependencies0,
          PuzzleProgressServiceProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = puzzleStorageProvider;
  static final $allTransitiveDependencies1 =
      PuzzleStorageProvider.$allTransitiveDependencies0;

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
    r'365a920ee1bbce4a0fc1ceac9caad3da22a5d53f';
