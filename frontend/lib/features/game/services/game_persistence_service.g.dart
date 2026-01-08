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
        dependencies: <ProviderOrFamily>[puzzleStorageProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GamePersistenceServiceProvider.$allTransitiveDependencies0,
          GamePersistenceServiceProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = puzzleStorageProvider;
  static final $allTransitiveDependencies1 =
      PuzzleStorageProvider.$allTransitiveDependencies0;

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
    r'ebe208f1ec17cf5d9294885fdab0ff1027245b4e';
