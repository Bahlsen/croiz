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
        dependencies: null,
        $allTransitiveDependencies: null,
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
    r'57c1bd9e851105ebb658718f8dc6b4e4b20c417a';
