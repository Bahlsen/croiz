import 'package:croiz/services/audio_service.dart';

class FakeAudioService implements AudioService {
  int successCount = 0;
  int typeCount = 0;
  int deleteCount = 0;
  int victoryCount = 0;
  int revealCount = 0;

  @override
  Future<void> playSuccess() async => successCount++;

  @override
  Future<void> playType() async => typeCount++;

  @override
  Future<void> playDelete() async => deleteCount++;

  @override
  Future<void> playVictory() async => victoryCount++;

  @override
  Future<void> playReveal() async => revealCount++;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> get ready async {}
}
