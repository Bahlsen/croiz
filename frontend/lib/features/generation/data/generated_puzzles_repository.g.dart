// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_puzzles_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(generatedPuzzlesRepository)
final generatedPuzzlesRepositoryProvider =
    GeneratedPuzzlesRepositoryProvider._();

final class GeneratedPuzzlesRepositoryProvider
    extends
        $FunctionalProvider<
          GeneratedPuzzlesRepository,
          GeneratedPuzzlesRepository,
          GeneratedPuzzlesRepository
        >
    with $Provider<GeneratedPuzzlesRepository> {
  GeneratedPuzzlesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generatedPuzzlesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generatedPuzzlesRepositoryHash();

  @$internal
  @override
  $ProviderElement<GeneratedPuzzlesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeneratedPuzzlesRepository create(Ref ref) {
    return generatedPuzzlesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeneratedPuzzlesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeneratedPuzzlesRepository>(value),
    );
  }
}

String _$generatedPuzzlesRepositoryHash() =>
    r'87cc1042d54c66480c4e8064455cbde818c7c083';
