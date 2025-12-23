import 'dart:async';
import 'dart:developer' as developer;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:croiz/services/audio_service.dart';

/// GameAudioService using FlameAudio and AudioPool for low-latency SFX.
///
/// Audio performance strategy:
/// 1. Use AudioPool for frequently played sounds (typing, delete)
/// 2. Aggressive throttling at 100ms (~10 sounds/sec max) to prevent overlap
/// 3. Simple fire-and-forget - no complex tracking needed
class GameAudioService implements AudioService {
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
  // 100ms minimum ensures ~10 sounds/sec max, preventing audio overlap/backlog.
  // This is aggressive throttling for fast typing - we sacrifice some audio
  // feedback for smoother performance.
  static const _minTypeInterval = Duration(milliseconds: 100);
  static const _minDeleteInterval = Duration(milliseconds: 100);
  DateTime? _lastTypeAt;
  DateTime? _lastDeleteAt;

  /// Future that completes when initialization is finished (success or failure).
  @override
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
      // Smaller pools (3/2) prevent audio backlog when typing fast.
      _typePool = await FlameAudio.createPool('typing.wav', maxPlayers: 3);
      _deletePool = await FlameAudio.createPool('delete.wav', maxPlayers: 2);

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

  @override
  Future<void> playType() async {
    try {
      if (!_initialized) {
        return;
      }

      // Throttle by time interval - simple and effective
      final now = DateTime.now();
      if (_lastTypeAt != null &&
          now.difference(_lastTypeAt!) < _minTypeInterval) {
        // Too frequent: drop this request to avoid audio overlap
        return;
      }

      _lastTypeAt = now;
      // Fire-and-forget - no tracking needed, throttling handles the load
      unawaited(_typePool?.start());
    } on Object catch (e, st) {
      developer.log('playType failed', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> playDelete() async {
    try {
      if (!_initialized) {
        return;
      }

      // Throttle by time interval - simple and effective
      final now = DateTime.now();
      if (_lastDeleteAt != null &&
          now.difference(_lastDeleteAt!) < _minDeleteInterval) {
        return;
      }

      _lastDeleteAt = now;
      // Fire-and-forget - no tracking needed, throttling handles the load
      unawaited(_deletePool?.start());
    } on Object catch (e, st) {
      developer.log('playDelete failed', error: e, stackTrace: st);
    }
  }

  @override
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

  @override
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
