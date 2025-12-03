import 'dart:developer' as developer;
import 'package:flame_audio/flame_audio.dart';

/// GameAudioService using FlameAudio and AudioPool for low-latency SFX.
class GameAudioService {

  GameAudioService() {
    // fire-and-forget initialization
    // ignore: unawaited_futures
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
        'victory.wav',
      ]);

      // Create small pools for quick, possibly overlapping SFX.
      _typePool = await FlameAudio.createPool('typing.wav', maxPlayers: 6);
      _deletePool = await FlameAudio.createPool('delete.wav', maxPlayers: 4);

      _initialized = true;
    } on Object catch (e, st) {
      // Initialization failures should not crash the app; log for visibility.
      _initialized = false;
      developer.log('GameAudioService initialization failed', error: e, stackTrace: st);
    }
  }

  Future<void> playType() async {
    try {
      if (!_initialized) {
        return;
      }
      if (_typePool != null) {
        await _typePool!.start();
      }
    } on Object catch (e, st) {
      developer.log('playType failed', error: e, stackTrace: st);
    }
    return;
  }

  Future<void> playDelete() async {
    try {
      if (!_initialized) {
        return;
      }
      if (_deletePool != null) {
        await _deletePool!.start();
      }
    } on Object catch (e, st) {
      developer.log('playDelete failed', error: e, stackTrace: st);
    }
    return;
  }

  Future<void> playSuccess() async {
    try {
      if (!_initialized) {
        return;
      }
      await FlameAudio.play('success.wav');
    } on Object catch (e, st) {
      developer.log('playSuccess failed', error: e, stackTrace: st);
    }
    return;
  }
  
  Future<void> playVictory() async {
    try {
      if (!_initialized) {
        return;
      }
      await FlameAudio.play('victory.wav');
    } on Object catch (e, st) {
      developer.log('playVictory failed', error: e, stackTrace: st);
    }
    return;
  }
  
}
