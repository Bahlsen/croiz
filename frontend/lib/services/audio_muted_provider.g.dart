// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_muted_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for global audio mute state.

@ProviderFor(AudioMutedNotifier)
final audioMutedProvider = AudioMutedNotifierProvider._();

/// Provider for global audio mute state.
final class AudioMutedNotifierProvider
    extends $NotifierProvider<AudioMutedNotifier, bool> {
  /// Provider for global audio mute state.
  AudioMutedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioMutedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioMutedNotifierHash();

  @$internal
  @override
  AudioMutedNotifier create() => AudioMutedNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$audioMutedNotifierHash() =>
    r'4e422de8acf81afc1a78a360223aff723a216bad';

/// Provider for global audio mute state.

abstract class _$AudioMutedNotifier extends $Notifier<bool> {
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
