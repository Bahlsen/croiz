// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_is_dark_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for global dark mode state.

@ProviderFor(AppIsDarkNotifier)
final appIsDarkProvider = AppIsDarkNotifierProvider._();

/// Provider for global dark mode state.
final class AppIsDarkNotifierProvider
    extends $NotifierProvider<AppIsDarkNotifier, bool> {
  /// Provider for global dark mode state.
  AppIsDarkNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appIsDarkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appIsDarkNotifierHash();

  @$internal
  @override
  AppIsDarkNotifier create() => AppIsDarkNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appIsDarkNotifierHash() => r'34c336ae99f7ffc42c90eb1168eea19a274cd852';

/// Provider for global dark mode state.

abstract class _$AppIsDarkNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
