// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_persistence_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gamePersistenceService)
final gamePersistenceServiceProvider = GamePersistenceServiceProvider._();

final class GamePersistenceServiceProvider
    extends
        $FunctionalProvider<
          GamePersistenceService,
          GamePersistenceService,
          GamePersistenceService
        >
    with $Provider<GamePersistenceService> {
  GamePersistenceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gamePersistenceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gamePersistenceServiceHash();

  @$internal
  @override
  $ProviderElement<GamePersistenceService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GamePersistenceService create(Ref ref) {
    return gamePersistenceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GamePersistenceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GamePersistenceService>(value),
    );
  }
}

String _$gamePersistenceServiceHash() =>
    r'29ec04a4bd5bba66ef15868e1088a5e11cc1db5b';
