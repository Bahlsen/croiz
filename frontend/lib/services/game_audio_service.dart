import 'dart:async';
import 'dart:developer' as developer;
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
            category: AVAudioSessionCategory.ambient,
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
      // Wait for initialization on first call to avoid silent skips
      if (!_initialized) {
        await ready;
      }
      if (!_initialized || _typePlayer == null) {
        developer.log(
          'playType skipped: initialized=$_initialized, player=${_typePlayer != null}',
          name: 'GameAudioService',
        );
        return;
      }
      // Throttle to prevent excessive calls
      final now = DateTime.now();
      if (_lastTypeAt != null &&
          now.difference(_lastTypeAt!) < _minTypeInterval) {
        return;
      }
      _lastTypeAt = now;

      // Fire-and-forget: seek to start and resume
      // Don't await - we want this to be non-blocking
      unawaited(_playSound(_typePlayer!));
    } on Object catch (e, st) {
      developer.log('playType failed', error: e, stackTrace: st);
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
        developer.log(
          'playDelete skipped: initialized=$_initialized, player=${_deletePlayer != null}',
          name: 'GameAudioService',
        );
        return;
      }

      // Throttle to prevent excessive calls
      final now = DateTime.now();
      if (_lastDeleteAt != null &&
          now.difference(_lastDeleteAt!) < _minDeleteInterval) {
        return;
      }
      _lastDeleteAt = now;

      // Fire-and-forget
      unawaited(_playSound(_deletePlayer!));
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

      unawaited(_playSound(_successPlayer!));
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

      unawaited(_playSound(_victoryPlayer!));
    } on Object catch (e, st) {
      developer.log('playVictory failed', error: e, stackTrace: st);
    }
  }

  /// Play a sound by seeking to start and resuming.
  /// Using seek(0) + resume() is faster than stop() + play() because
  /// the source is already loaded.
  Future<void> _playSound(AudioPlayer player) async {
    try {
      await player.seek(Duration.zero);
      await player.resume();
    } on Object catch (e, st) {
      developer.log('_playSound failed', error: e, stackTrace: st);
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
