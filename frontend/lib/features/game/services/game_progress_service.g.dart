// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_progress_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameProgressService)
final gameProgressServiceProvider = GameProgressServiceProvider._();

final class GameProgressServiceProvider
    extends
        $FunctionalProvider<
          GameProgressService,
          GameProgressService,
          GameProgressService
        >
    with $Provider<GameProgressService> {
  GameProgressServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameProgressServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameProgressServiceHash();

  @$internal
  @override
  $ProviderElement<GameProgressService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GameProgressService create(Ref ref) {
    return gameProgressService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameProgressService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameProgressService>(value),
    );
  }
}

String _$gameProgressServiceHash() =>
    r'fb091560a442b244260370931341b92303ef7a81';
