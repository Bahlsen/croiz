import 'package:audioplayers/audioplayers.dart';

/// Service simple pour jouer des sons du jeu.
class GameAudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playType() async {
    await _player.play(AssetSource('audio/type.mp3'), volume: 1);
  }

  Future<void> playDelete() async {
    await _player.play(AssetSource('audio/delete.mp3'), volume: 1);
  }

  Future<void> playSuccess() async {
    await _player.play(AssetSource('audio/success.mp3'), volume: 1);
  }
}
