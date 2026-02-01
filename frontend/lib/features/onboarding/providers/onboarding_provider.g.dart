// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingService)
final onboardingServiceProvider = OnboardingServiceProvider._();

final class OnboardingServiceProvider
    extends
        $FunctionalProvider<
          OnboardingService,
          OnboardingService,
          OnboardingService
        >
    with $Provider<OnboardingService> {
  OnboardingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingServiceHash();

  @$internal
  @override
  $ProviderElement<OnboardingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingService create(Ref ref) {
    return onboardingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingService>(value),
    );
  }
}

String _$onboardingServiceHash() => r'642d894a5665e228d3508bb078400fe7402c59eb';

@ProviderFor(OnboardingState)
final onboardingStateProvider = OnboardingStateProvider._();

final class OnboardingStateProvider
    extends $AsyncNotifierProvider<OnboardingState, bool> {
  OnboardingStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingStateHash();

  @$internal
  @override
  OnboardingState create() => OnboardingState();
}

String _$onboardingStateHash() => r'97bad4f1be1253fcb0d6bd67c233acf7ece34b7a';

abstract class _$OnboardingState extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
