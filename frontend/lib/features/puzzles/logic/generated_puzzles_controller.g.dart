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
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generatedPuzzlesControllerHash();

  @$internal
  @override
  GeneratedPuzzlesController create() => GeneratedPuzzlesController();
}

String _$generatedPuzzlesControllerHash() =>
    r'7ac87314d7711aa2d8bff53d4a933ae4ab43f64a';

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
