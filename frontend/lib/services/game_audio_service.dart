import 'dart:async';
import 'dart:developer' as developer;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  final Completer<void> _ready = Completer<void>();
  // Throttle spikes: ignore play requests that arrive faster than this.
  static const _minTypeInterval = Duration(milliseconds: 40);
  static const _minDeleteInterval = Duration(milliseconds: 40);
  DateTime? _lastTypeAt;
  DateTime? _lastDeleteAt;

  /// Future that completes when initialization is finished (success or failure).
  Future<void> get ready => _ready.future;

  Future<void> _init() async {
    try {
      // Preload into cache (files placed in assets/audio/)
      await FlameAudio.audioCache.loadAll([
        'typing.wav',
        'delete.wav',
        'success.wav',
        'victory.wav',
      ]);

      // Additionally load raw bytes from assets to ensure they're available
      // to the platform asset system early (helps avoid first-play latency).
      try {
        await Future.wait([
          rootBundle.load('assets/audio/typing.wav'),
          rootBundle.load('assets/audio/delete.wav'),
          rootBundle.load('assets/audio/success.wav'),
          rootBundle.load('assets/audio/victory.wav'),
        ]);
      } on Object catch (e) {
        developer.log('rootBundle.load prewarm failed', error: e);
      }

      // Create small pools for quick, possibly overlapping SFX.
      _typePool = await FlameAudio.createPool('typing.wav', maxPlayers: 6);
      _deletePool = await FlameAudio.createPool('delete.wav', maxPlayers: 4);

      _initialized = true;
      if (!_ready.isCompleted) {
        _ready.complete();
      }
      developer.log('GameAudioService initialized', name: 'GameAudioService');
    } on Object catch (e, st) {
      // Initialization failures should not crash the app; log for visibility.
      _initialized = false;
      developer.log(
        'GameAudioService initialization failed',
        error: e,
        stackTrace: st,
      );
      if (!_ready.isCompleted) {
        _ready.complete();
      }
    }
  }

  Future<void> playType() async {
    try {
      if (!_initialized) {
        return;
      }
      final now = DateTime.now();
      if (_lastTypeAt != null &&
          now.difference(_lastTypeAt!) < _minTypeInterval) {
        // Too frequent: drop this request to avoid backlog/latency.
        return;
      }
      _lastTypeAt = now;
      if (_typePool != null) {
        // Do not await start() — start is fire-and-forget for low-latency SFX.
        unawaited(_typePool!.start());
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
      final now = DateTime.now();
      if (_lastDeleteAt != null &&
          now.difference(_lastDeleteAt!) < _minDeleteInterval) {
        return;
      }
      _lastDeleteAt = now;
      if (_deletePool != null) {
        unawaited(_deletePool!.start());
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
