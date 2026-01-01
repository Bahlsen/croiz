import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/preference_persistence_service.dart';

/// Provider for global audio mute state.
final gameAudioMutedProvider = NotifierProvider<AudioMutedNotifier, bool>(
  AudioMutedNotifier.new,
);

class AudioMutedNotifier extends Notifier<bool> {
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
