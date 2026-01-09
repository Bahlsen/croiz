// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_puzzles_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GeneratedPuzzlesController)
final generatedPuzzlesControllerProvider =
    GeneratedPuzzlesControllerProvider._();

final class GeneratedPuzzlesControllerProvider
    extends $AsyncNotifierProvider<GeneratedPuzzlesController, void> {
  GeneratedPuzzlesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generatedPuzzlesControllerProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[
          generatedPuzzlesRepositoryProvider,
          puzzlesProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GeneratedPuzzlesControllerProvider.$allTransitiveDependencies0,
          GeneratedPuzzlesControllerProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = generatedPuzzlesRepositoryProvider;
  static final $allTransitiveDependencies1 = puzzlesProvider;

  @override
  String debugGetCreateSourceHash() => _$generatedPuzzlesControllerHash();

  @$internal
  @override
  GeneratedPuzzlesController create() => GeneratedPuzzlesController();
}

String _$generatedPuzzlesControllerHash() =>
    r'b063615139554949d47f3fad24c5c83865d8a472';

abstract class _$GeneratedPuzzlesController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
