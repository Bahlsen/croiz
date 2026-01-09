// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_reveal_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameRevealService)
final gameRevealServiceProvider = GameRevealServiceProvider._();

final class GameRevealServiceProvider
    extends
        $FunctionalProvider<
          GameRevealService,
          GameRevealService,
          GameRevealService
        >
    with $Provider<GameRevealService> {
  GameRevealServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameRevealServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameRevealServiceHash();

  @$internal
  @override
  $ProviderElement<GameRevealService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GameRevealService create(Ref ref) {
    return gameRevealService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameRevealService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameRevealService>(value),
    );
  }
}

String _$gameRevealServiceHash() => r'3b2bfe753ac81983c1421b4379489201a9968dd3';
