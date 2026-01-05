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
        dependencies: null,
        $allTransitiveDependencies: null,
      );

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
    r'f93e576c32c42ebb67f568f24407b7429110929c';
