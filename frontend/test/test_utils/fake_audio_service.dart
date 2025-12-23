import 'package:croiz/services/audio_service.dart';

/// Fake audio service for testing.
///
/// Tracks call counts for all audio methods and completes immediately.
class FakeAudioService implements AudioService {
  int typeCount = 0;
  int deleteCount = 0;
  int successCount = 0;
  int victoryCount = 0;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playDelete() async {
    deleteCount++;
  }

  @override
  Future<void> playSuccess() async {
    successCount++;
  }

  @override
  Future<void> playType() async {
    typeCount++;
  }

  @override
  Future<void> playVictory() async {
    victoryCount++;
  }

  @override
  Future<void> get ready async => Future<void>.value();
}
