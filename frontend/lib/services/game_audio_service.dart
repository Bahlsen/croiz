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

  // Asset sources for replay
  static const _typeAsset = 'audio/typing.wav';
  static const _deleteAsset = 'audio/delete.wav';
  static const _successAsset = 'audio/success.wav';
  static const _victoryAsset = 'audio/victory.wav';

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
      _typePlayer = AudioPlayer();
      _deletePlayer = AudioPlayer();
      _successPlayer = AudioPlayer();
      _victoryPlayer = AudioPlayer();

      // Set low latency mode for typing sounds (Android) - must be set before play
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

      // Stop any current playback then play fresh
      await _typePlayer!.stop();
      await _typePlayer!.play(AssetSource(_typeAsset));
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

      // Stop any current playback then play fresh
      await _deletePlayer!.stop();
      await _deletePlayer!.play(AssetSource(_deleteAsset));
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
      await _successPlayer!.stop();
      await _successPlayer!.play(AssetSource(_successAsset));
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
      await _victoryPlayer!.stop();
      await _victoryPlayer!.play(AssetSource(_victoryAsset));
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
