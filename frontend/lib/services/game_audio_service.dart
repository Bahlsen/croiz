import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:croiz/services/audio_service.dart';

/// GameAudioService using AudioPlayers in mediaPlayer mode for reliable replay.
///
/// Strategy:
/// - Use mediaPlayer mode (not lowLatency) for reliable seek+resume replay
/// - Set ReleaseMode.stop to keep resources loaded after playback
/// - Use seek(0) + resume() to replay sounds quickly
/// - Throttle at 80ms to prevent excessive calls
class GameAudioService implements AudioService {
  GameAudioService();

  AudioPlayer? _typePlayer;
  AudioPlayer? _deletePlayer;
  AudioPlayer? _successPlayer;
  AudioPlayer? _victoryPlayer;
  bool _initialized = false;
  final Completer<void> _ready = Completer<void>();

  static const _minTypeInterval = Duration(milliseconds: 80);
  static const _minDeleteInterval = Duration(milliseconds: 80);
  DateTime? _lastTypeAt;
  DateTime? _lastDeleteAt;

  @override
  Future<void> get ready => _ready.future;

  Future<void> _init() async {
    try {
      // Configure global audio context
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
            usageType: AndroidUsageType.assistanceSonification,
            contentType: AndroidContentType.sonification,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );

      // Create players
      _typePlayer = AudioPlayer();
      _deletePlayer = AudioPlayer();
      _successPlayer = AudioPlayer();
      _victoryPlayer = AudioPlayer();

      // Set release mode to STOP - keeps resources loaded for quick replay
      await Future.wait([
        _typePlayer!.setReleaseMode(ReleaseMode.stop),
        _deletePlayer!.setReleaseMode(ReleaseMode.stop),
        _successPlayer!.setReleaseMode(ReleaseMode.stop),
        _victoryPlayer!.setReleaseMode(ReleaseMode.stop),
      ]);

      // Pre-load and play once silently to fully initialize
      await Future.wait([
        _typePlayer!.setSource(AssetSource('audio/typing.wav')),
        _deletePlayer!.setSource(AssetSource('audio/delete.wav')),
        _successPlayer!.setSource(AssetSource('audio/success.wav')),
        _victoryPlayer!.setSource(AssetSource('audio/victory.wav')),
      ]);

      // Set volume to 0, play, then restore volume - ensures player is ready
      await _typePlayer!.setVolume(0);
      await _typePlayer!.resume();
      await Future.delayed(const Duration(milliseconds: 50));
      await _typePlayer!.stop();
      await _typePlayer!.setVolume(1);

      await _deletePlayer!.setVolume(0);
      await _deletePlayer!.resume();
      await Future.delayed(const Duration(milliseconds: 50));
      await _deletePlayer!.stop();
      await _deletePlayer!.setVolume(1);

      _initialized = true;
      if (!_ready.isCompleted) {
        _ready.complete();
      }
    } on Object catch (e, st) {
      _initialized = false;
      debugPrint('[AUDIO] init failed: $e\n$st');
      if (!_ready.isCompleted) {
        _ready.complete();
      }
    }
  }

  @override
  Future<void> playType() async {
    try {
      WidgetsBinding.instance;
      if (!_initialized && !_ready.isCompleted) {
        unawaited(_init());
      }
    } on Object {
      // Binding not initialized: skip audio
    }
    if (_typePlayer == null) {
      return;
    }

    final now = DateTime.now();
    if (_lastTypeAt != null &&
        now.difference(_lastTypeAt!) < _minTypeInterval) {
      return;
    }
    _lastTypeAt = now;

    // Fire-and-forget replay
    unawaited(_replayFast(_typePlayer!));
  }

  @override
  Future<void> playDelete() async {
    try {
      WidgetsBinding.instance;
      if (!_initialized && !_ready.isCompleted) {
        unawaited(_init());
      }
    } on Object {
      // Binding not initialized: skip audio
    }
    if (_deletePlayer == null) {
      return;
    }

    final now = DateTime.now();
    if (_lastDeleteAt != null &&
        now.difference(_lastDeleteAt!) < _minDeleteInterval) {
      return;
    }
    _lastDeleteAt = now;

    // Fire-and-forget replay
    unawaited(_replayFast(_deletePlayer!));
  }

  @override
  Future<void> playSuccess() async {
    try {
      WidgetsBinding.instance;
      if (!_initialized && !_ready.isCompleted) {
        unawaited(_init());
      }
    } on Object {
      return;
    }
    if (!_initialized || _successPlayer == null) {
      return;
    }
    unawaited(_replayFast(_successPlayer!));
  }

  @override
  Future<void> playVictory() async {
    try {
      WidgetsBinding.instance;
      if (!_initialized && !_ready.isCompleted) {
        unawaited(_init());
      }
    } on Object {
      return;
    }
    if (!_initialized || _victoryPlayer == null) {
      return;
    }
    unawaited(_replayFast(_victoryPlayer!));
  }

  /// Fast replay: seek to start and resume without stopping.
  /// This is much faster than stop→seek→resume.
  Future<void> _replayFast(AudioPlayer player) async {
    try {
      // Seek and resume in parallel for fastest response
      await player.seek(Duration.zero);
      await player.resume();
    } on Object {
      // Silently ignore audio errors to not block UI
    }
  }

  @override
  Future<void> dispose() async {
    await _typePlayer?.dispose();
    await _deletePlayer?.dispose();
    await _successPlayer?.dispose();
    await _victoryPlayer?.dispose();
  }
}
