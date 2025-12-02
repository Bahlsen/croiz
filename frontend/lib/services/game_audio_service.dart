import 'package:flame_audio/flame_audio.dart';

/// GameAudioService using FlameAudio and AudioPool for low-latency SFX.
class GameAudioService {

  GameAudioService() {
    _init();
  }
  AudioPool? _typePool;
  AudioPool? _deletePool;
  bool _initialized = false;

  Future<void> _init() async {
    try {
      // Preload into cache (files placed in assets/audio/)
      await FlameAudio.audioCache.loadAll([
        'typing.wav',
        'delete.wav',
        'success.wav',
      ]);

      // Create small pools for quick, possibly overlapping SFX.
      _typePool = await FlameAudio.createPool('typing.wav', maxPlayers: 6);
      _deletePool = await FlameAudio.createPool('delete.wav', maxPlayers: 4);

      _initialized = true;
    } on Object catch (_) {
      // Initialization failures should not crash the app; log elsewhere if needed.
      _initialized = false;
    }
  }

  void playType() {
    try {
      if (!_initialized) {
        return;
      }
      if (_typePool != null) {
        _typePool!.start();
      }
    } on Object catch (_) {}
  }

  void playDelete() {
    try {
      if (!_initialized) {
        return;
      }
      if (_deletePool != null) {
        _deletePool!.start();
      }
    } on Object catch (_) {}
  }

  void playSuccess() {
    try {
      if (!_initialized) {
        return;
      }
      FlameAudio.play('success.wav');
    } on Object catch (_) {}
  }
  
}
