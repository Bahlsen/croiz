import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:croiz/services/audio_service.dart';

/// GameAudioService using single AudioPlayers with fire-and-forget playback.
///
/// Audio performance strategy:
/// 1. Use single AudioPlayer per sound type (no pool accumulation)
/// 2. Fire-and-forget play calls (no await blocking)
/// 3. Configure AudioContext to not request audio focus (prevents interruptions)
/// 4. Throttle at 80ms to prevent excessive calls
/// 5. No queue - if sound is throttled, it's simply skipped
class GameAudioService implements AudioService {
  GameAudioService() {
    // fire-and-forget initialization
    unawaited(_init());
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

  // Throttle interval - prevents excessive calls.
  // 80ms allows ~12 sounds/sec which feels responsive but prevents overload.
  static const _minTypeInterval = Duration(milliseconds: 80);
  static const _minDeleteInterval = Duration(milliseconds: 80);
  DateTime? _lastTypeAt;
  DateTime? _lastDeleteAt;

  /// Future that completes when initialization is finished (success or failure).
  @override
  Future<void> get ready => _ready.future;

  Future<void> _init() async {
    try {
      // Configure global audio context to avoid audio focus issues.
      // This prevents the constant "abandonAudioFocus" spam and makes sounds
      // play more reliably.
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            // Don't request audio focus - we're just playing short UI sounds
            audioFocus: AndroidAudioFocus.none,
            // Use short sound optimized mode
            usageType: AndroidUsageType.assistanceSonification,
            contentType: AndroidContentType.sonification,
          ),
          iOS: AudioContextIOS(
            // Use playback category which allows mixWithOthers
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );

      // Create dedicated players for each sound type.
      _typePlayer = AudioPlayer();
      _deletePlayer = AudioPlayer();
      _successPlayer = AudioPlayer();
      _victoryPlayer = AudioPlayer();

      // Set low latency mode for typing sounds (Android)
      await _typePlayer!.setPlayerMode(PlayerMode.lowLatency);
      await _deletePlayer!.setPlayerMode(PlayerMode.lowLatency);

      // Pre-load assets for faster first play
      await Future.wait([
        _typePlayer!.setSource(AssetSource(_typeAsset)),
        _deletePlayer!.setSource(AssetSource(_deleteAsset)),
        _successPlayer!.setSource(AssetSource(_successAsset)),
        _victoryPlayer!.setSource(AssetSource(_victoryAsset)),
      ]);

      _initialized = true;
      if (!_ready.isCompleted) {
        _ready.complete();
      }
    } on Object catch (e, st) {
      _initialized = false;
      debugPrint('[AUDIO] GameAudioService initialization failed: $e\n$st');
      if (!_ready.isCompleted) {
        _ready.complete();
      }
    }
  }

  @override
  Future<void> playType() async {
    try {
      // Wait for initialization on first call to avoid silent skips
      if (!_initialized) {
        await ready;
      }
      if (!_initialized || _typePlayer == null) {
        return;
      }
      // Throttle to prevent excessive calls
      final now = DateTime.now();
      if (_lastTypeAt != null &&
          now.difference(_lastTypeAt!) < _minTypeInterval) {
        return;
      }
      _lastTypeAt = now;

      // Fire-and-forget: play the sound
      // In lowLatency mode, we must use play(source) each time - seek is not supported
      unawaited(_typePlayer!.stop());
      unawaited(_typePlayer!.play(AssetSource(_typeAsset)));
    } on Object catch (e, st) {
      debugPrint('[AUDIO] playType failed: $e\n$st');
    }
  }

  @override
  Future<void> playDelete() async {
    try {
      // Wait for initialization on first call to avoid silent skips
      if (!_initialized) {
        await ready;
      }
      if (!_initialized || _deletePlayer == null) {
        return;
      }

      // Throttle to prevent excessive calls
      final now = DateTime.now();
      if (_lastDeleteAt != null &&
          now.difference(_lastDeleteAt!) < _minDeleteInterval) {
        return;
      }
      _lastDeleteAt = now;

      // Fire-and-forget: play the sound
      // In lowLatency mode, we must use play(source) each time - seek is not supported
      unawaited(_deletePlayer!.stop());
      unawaited(_deletePlayer!.play(AssetSource(_deleteAsset)));
    } on Object catch (e, st) {
      debugPrint('[AUDIO] playDelete failed: $e\n$st');
    }
  }

  @override
  Future<void> playSuccess() async {
    try {
      if (!_initialized || _successPlayer == null) {
        return;
      }

      // Success uses mediaPlayer mode - can use seek+resume
      await _successPlayer!.seek(Duration.zero);
      await _successPlayer!.resume();
    } on Object catch (e, st) {
      debugPrint('[AUDIO] playSuccess failed: $e\n$st');
    }
  }

  @override
  Future<void> playVictory() async {
    try {
      if (!_initialized || _victoryPlayer == null) {
        return;
      }

      // Victory uses mediaPlayer mode - can use seek+resume
      await _victoryPlayer!.seek(Duration.zero);
      await _victoryPlayer!.resume();
    } on Object catch (e, st) {
      debugPrint('[AUDIO] playVictory failed: $e\n$st');
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
