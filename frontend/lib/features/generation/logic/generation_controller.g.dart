// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GenerationController)
final generationControllerProvider = GenerationControllerProvider._();

final class GenerationControllerProvider
    extends $NotifierProvider<GenerationController, AsyncValue<String?>> {
  GenerationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generationControllerProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[pendingPuzzlesProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GenerationControllerProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = pendingPuzzlesProvider;

  @override
  String debugGetCreateSourceHash() => _$generationControllerHash();

  @$internal
  @override
  GenerationController create() => GenerationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String?>>(value),
    );
  }
}

String _$generationControllerHash() =>
    r'ee83b746536d3e922fb9779a37149b64a7534e87';

abstract class _$GenerationController extends $Notifier<AsyncValue<String?>> {
  AsyncValue<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, AsyncValue<String?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, AsyncValue<String?>>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
