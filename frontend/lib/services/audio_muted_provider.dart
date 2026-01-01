import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for global audio mute state.
final gameAudioMutedProvider = NotifierProvider<AudioMutedNotifier, bool>(
  AudioMutedNotifier.new,
);

class AudioMutedNotifier extends Notifier<bool> {
  @override
  bool build() => false; // not muted by default

  void setMuted({required bool muted}) {
    state = muted;
    _persistMuted(muted);
  }

  Future<void> _persistMuted(bool v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pref_audio_muted', v);
    } on Object {
      // ignore
    }
  }

  void toggle() => state = !state;
}
