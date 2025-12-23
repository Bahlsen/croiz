import 'dart:async';
import 'dart:developer' as developer;
import 'package:audioplayers/audioplayers.dart';
import 'package:croiz/services/audio_service.dart';

/// GameAudioService using single AudioPlayers with stop-before-play strategy.
///
/// Audio performance strategy:
/// 1. Use single AudioPlayer per sound type (no pool accumulation)
/// 2. Stop current sound before playing new one (prevents overlap/avalanche)
/// 3. Throttle at 80ms to prevent excessive stop/start cycles
/// 4. No queue - if sound is throttled, it's simply skipped
class GameAudioService implements AudioService {
  GameAudioService() {
    // fire-and-forget initialization
    // ignore: unawaited_futures
    _init();
  }

  AudioPlayer? _typePlayer;
  AudioPlayer? _deletePlayer;
  AudioPlayer? _successPlayer;
  AudioPlayer? _victoryPlayer;
  bool _initialized = false;
  final Completer<void> _ready = Completer<void>();

  // Throttle interval - prevents excessive stop/start cycles.
  // 80ms allows ~12 sounds/sec which feels responsive but prevents avalanche.
  static const _minTypeInterval = Duration(milliseconds: 80);
  static const _minDeleteInterval = Duration(milliseconds: 80);
  DateTime? _lastTypeAt;
  DateTime? _lastDeleteAt;

  /// Future that completes when initialization is finished (success or failure).
  @override
  Future<void> get ready => _ready.future;

  Future<void> _init() async {
    try {
      // Create dedicated players for each sound type.
      // Using AssetSource with setSourceAsset for low-latency playback.
      _typePlayer = AudioPlayer();
      _deletePlayer = AudioPlayer();
      _successPlayer = AudioPlayer();
      _victoryPlayer = AudioPlayer();

      // Pre-set sources to reduce first-play latency
      await Future.wait([
        _typePlayer!.setSourceAsset('audio/typing.wav'),
        _deletePlayer!.setSourceAsset('audio/delete.wav'),
        _successPlayer!.setSourceAsset('audio/success.wav'),
        _victoryPlayer!.setSourceAsset('audio/victory.wav'),
      ]);

      // Set low latency mode for typing sounds (Android)
      await _typePlayer!.setPlayerMode(PlayerMode.lowLatency);
      await _deletePlayer!.setPlayerMode(PlayerMode.lowLatency);

      _initialized = true;
      if (!_ready.isCompleted) {
        _ready.complete();
      }
      developer.log('GameAudioService initialized', name: 'GameAudioService');
    } on Object catch (e, st) {
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
      if (!_initialized || _typePlayer == null) {
        return;
      }

      // Throttle to prevent excessive stop/start cycles
      final now = DateTime.now();
      if (_lastTypeAt != null &&
          now.difference(_lastTypeAt!) < _minTypeInterval) {
        return;
      }
      _lastTypeAt = now;

      // Stop-before-play: prevents sound accumulation
      // Using seek(0) + resume for lower latency than stop + play
      await _typePlayer!.seek(Duration.zero);
      await _typePlayer!.resume();
    } on Object catch (e, st) {
      developer.log('playType failed', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> playDelete() async {
    try {
      if (!_initialized || _deletePlayer == null) {
        return;
      }

      // Throttle to prevent excessive stop/start cycles
      final now = DateTime.now();
      if (_lastDeleteAt != null &&
          now.difference(_lastDeleteAt!) < _minDeleteInterval) {
        return;
      }
      _lastDeleteAt = now;

      // Stop-before-play: prevents sound accumulation
      await _deletePlayer!.seek(Duration.zero);
      await _deletePlayer!.resume();
    } on Object catch (e, st) {
      developer.log('playDelete failed', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> playSuccess() async {
    try {
      if (!_initialized || _successPlayer == null) {
        return;
      }
      await _successPlayer!.seek(Duration.zero);
      await _successPlayer!.resume();
    } on Object catch (e, st) {
      developer.log('playSuccess failed', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> playVictory() async {
    try {
      if (!_initialized || _victoryPlayer == null) {
        return;
      }
      await _victoryPlayer!.seek(Duration.zero);
      await _victoryPlayer!.resume();
    } on Object catch (e, st) {
      developer.log('playVictory failed', error: e, stackTrace: st);
    }
  }

  /// Dispose all players when the service is no longer needed.
  @override
  Future<void> dispose() async {
    await _typePlayer?.dispose();
    await _deletePlayer?.dispose();
    await _successPlayer?.dispose();
    await _victoryPlayer?.dispose();
  }
}
