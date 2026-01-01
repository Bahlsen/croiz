import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/audio_service.dart';
import 'package:croiz/services/game_audio_service.dart';

/// Provider for the game audio service.
final gameAudioServiceProvider = Provider<AudioService>(
  (ref) => GameAudioService(),
);
