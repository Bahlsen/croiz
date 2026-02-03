// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubscriptionNotifier)
final subscriptionProvider = SubscriptionNotifierProvider._();

final class SubscriptionNotifierProvider
    extends $AsyncNotifierProvider<SubscriptionNotifier, bool> {
  SubscriptionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionNotifierHash();

  @$internal
  @override
  SubscriptionNotifier create() => SubscriptionNotifier();
}

String _$subscriptionNotifierHash() =>
    r'3c766f52e4b9f49a15d7bb8f7275918db4471a32';

abstract class _$SubscriptionNotifier extends $AsyncNotifier<bool> {
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
