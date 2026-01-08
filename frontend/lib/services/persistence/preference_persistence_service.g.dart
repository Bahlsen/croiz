// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_persistence_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for PreferencePersistenceService.

@ProviderFor(preferencePersistenceService)
final preferencePersistenceServiceProvider =
    PreferencePersistenceServiceProvider._();

/// Provider for PreferencePersistenceService.

final class PreferencePersistenceServiceProvider
    extends
        $FunctionalProvider<
          PreferencePersistenceService,
          PreferencePersistenceService,
          PreferencePersistenceService
        >
    with $Provider<PreferencePersistenceService> {
  /// Provider for PreferencePersistenceService.
  PreferencePersistenceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencePersistenceServiceProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
      );

  @override
  String debugGetCreateSourceHash() => _$preferencePersistenceServiceHash();

  @$internal
  @override
  $ProviderElement<PreferencePersistenceService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PreferencePersistenceService create(Ref ref) {
    return preferencePersistenceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencePersistenceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencePersistenceService>(value),
    );
  }
}

String _$preferencePersistenceServiceHash() =>
    r'2c8f1f5c1c8aa730afcc7c162300709389066f15';
