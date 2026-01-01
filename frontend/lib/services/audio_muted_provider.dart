import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/services/persistence/preference_persistence_service.dart';

part 'audio_muted_provider.g.dart';

/// Provider for global audio mute state.
@Riverpod(keepAlive: true)
class AudioMutedNotifier extends _$AudioMutedNotifier {
  @override
  bool build() => false; // not muted by default

  void setMuted({required bool muted}) {
    state = muted;
    ref
        .read(preferencePersistenceServiceProvider)
        .setBool('pref_audio_muted', value: muted);
  }

  void toggle() => state = !state;
}

// Compatibility alias
final gameAudioMutedProvider = audioMutedProvider;
