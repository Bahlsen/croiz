import 'package:croiz/services/audio_service.dart';

class FakeAudioService implements AudioService {
  int successCount = 0;
  @override
  Future<void> playSuccess() async => successCount++;

  @override
  Future<void> playType() async {}

  @override
  Future<void> playDelete() async {}

  @override
  Future<void> playVictory() async {}

  @override
  Future<void> playReveal() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> get ready async {}
}
