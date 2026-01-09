// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_endgame_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameEndgameService)
final gameEndgameServiceProvider = GameEndgameServiceProvider._();

final class GameEndgameServiceProvider
    extends
        $FunctionalProvider<
          GameEndgameService,
          GameEndgameService,
          GameEndgameService
        >
    with $Provider<GameEndgameService> {
  GameEndgameServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameEndgameServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameEndgameServiceHash();

  @$internal
  @override
  $ProviderElement<GameEndgameService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GameEndgameService create(Ref ref) {
    return gameEndgameService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameEndgameService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameEndgameService>(value),
    );
  }
}

String _$gameEndgameServiceHash() =>
    r'777aee44f42c119e33330affa1773b3c8e4ccde7';
