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
        dependencies: <ProviderOrFamily>[appDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GeneratedPuzzlesRepositoryProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = appDatabaseProvider;

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
    r'4ffc9d8178014a2e0173c19ae17c13676fd1e7e7';
