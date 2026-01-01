import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/services/audio_service.dart';
import 'package:croiz/services/game_audio_service.dart';

part 'game_audio_provider.g.dart';

/// Provider for the game audio service.
@Riverpod(keepAlive: true)
AudioService gameAudioService(Ref ref) => GameAudioService();
