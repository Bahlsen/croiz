// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_audio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the game audio service.

@ProviderFor(gameAudioService)
final gameAudioServiceProvider = GameAudioServiceProvider._();

/// Provider for the game audio service.

final class GameAudioServiceProvider
    extends $FunctionalProvider<AudioService, AudioService, AudioService>
    with $Provider<AudioService> {
  /// Provider for the game audio service.
  GameAudioServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameAudioServiceProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
      );

  @override
  String debugGetCreateSourceHash() => _$gameAudioServiceHash();

  @$internal
  @override
  $ProviderElement<AudioService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioService create(Ref ref) {
    return gameAudioService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioService>(value),
    );
  }
}

String _$gameAudioServiceHash() => r'b39286e4492bd7264f431e844a223613570feabd';
