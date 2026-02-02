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
        dependencies: <ProviderOrFamily>[statisticsServiceProvider],
        $allTransitiveDependencies: <ProviderOrFamily>{
          GameEndgameServiceProvider.$allTransitiveDependencies0,
          GameEndgameServiceProvider.$allTransitiveDependencies1,
          GameEndgameServiceProvider.$allTransitiveDependencies2,
          GameEndgameServiceProvider.$allTransitiveDependencies3,
        },
      );

  static final $allTransitiveDependencies0 = statisticsServiceProvider;
  static final $allTransitiveDependencies1 =
      StatisticsServiceProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      StatisticsServiceProvider.$allTransitiveDependencies1;
  static final $allTransitiveDependencies3 =
      StatisticsServiceProvider.$allTransitiveDependencies2;

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
    r'c6c8b765ac119a547ec7d21545e72c1688e7f47b';
