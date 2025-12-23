import 'dart:async';
import 'dart:developer' as developer;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:croiz/services/audio_service.dart';

/// GameAudioService using FlameAudio and AudioPool for low-latency SFX.
///
/// Audio performance strategy:
/// 1. Use AudioPool for frequently played sounds (typing, delete)
/// 2. Throttle at 60ms minimum interval (~16 sounds/sec max)
/// 3. Track in-flight sounds to prevent backlog accumulation
/// 4. Drop sounds when pool is busy rather than queuing
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
  // 60ms minimum ensures ~16 sounds/sec max, preventing audio backlog.
  static const _minTypeInterval = Duration(milliseconds: 60);
  static const _minDeleteInterval = Duration(milliseconds: 60);
  DateTime? _lastTypeAt;
  DateTime? _lastDeleteAt;

  // Track in-flight sounds to prevent backlog when pool is saturated.
  // When all pool players are busy, we drop the request instead of queuing.
  int _typeInFlight = 0;
  int _deleteInFlight = 0;
  static const _maxTypeInFlight = 2; // Leave 1 player as buffer
  static const _maxDeleteInFlight = 1; // Leave 1 player as buffer

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

      // Throttle by time interval
      final now = DateTime.now();
      if (_lastTypeAt != null &&
          now.difference(_lastTypeAt!) < _minTypeInterval) {
        // Too frequent: drop this request to avoid backlog/latency.
        return;
      }

      // Drop if too many sounds in flight (prevents queue buildup)
      if (_typeInFlight >= _maxTypeInFlight) {
        developer.log(
          'playType dropped: pool saturated ($_typeInFlight in flight)',
          name: 'GameAudioService',
        );
        return;
      }

      _lastTypeAt = now;
      if (_typePool != null) {
        _typeInFlight++;
        // Fire-and-forget but track completion to know when pool frees up
        unawaited(
          _typePool!
              .start()
              .then((_) {
                // Sound started, will auto-complete
                // Decrement after estimated sound duration (typing.wav is short)
                Future<void>.delayed(const Duration(milliseconds: 100), () {
                  _typeInFlight = (_typeInFlight - 1).clamp(
                    0,
                    _maxTypeInFlight,
                  );
                });
              })
              .catchError((Object e) {
                _typeInFlight = (_typeInFlight - 1).clamp(0, _maxTypeInFlight);
                developer.log('playType pool.start failed', error: e);
              }),
        );
      }
    } on Object catch (e, st) {
      developer.log('playType failed', error: e, stackTrace: st);
    }
    return;
  }

  @override
  Future<void> playDelete() async {
    try {
      if (!_initialized) {
        return;
      }

      // Throttle by time interval
      final now = DateTime.now();
      if (_lastDeleteAt != null &&
          now.difference(_lastDeleteAt!) < _minDeleteInterval) {
        return;
      }

      // Drop if too many sounds in flight (prevents queue buildup)
      if (_deleteInFlight >= _maxDeleteInFlight) {
        developer.log(
          'playDelete dropped: pool saturated ($_deleteInFlight in flight)',
          name: 'GameAudioService',
        );
        return;
      }

      _lastDeleteAt = now;
      if (_deletePool != null) {
        _deleteInFlight++;
        // Fire-and-forget but track completion to know when pool frees up
        unawaited(
          _deletePool!
              .start()
              .then((_) {
                // Sound started, will auto-complete
                // Decrement after estimated sound duration (delete.wav is short)
                Future<void>.delayed(const Duration(milliseconds: 100), () {
                  _deleteInFlight = (_deleteInFlight - 1).clamp(
                    0,
                    _maxDeleteInFlight,
                  );
                });
              })
              .catchError((Object e) {
                _deleteInFlight = (_deleteInFlight - 1).clamp(
                  0,
                  _maxDeleteInFlight,
                );
                developer.log('playDelete pool.start failed', error: e);
              }),
        );
      }
    } on Object catch (e, st) {
      developer.log('playDelete failed', error: e, stackTrace: st);
    }
    return;
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
