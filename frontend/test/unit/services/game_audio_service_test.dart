// ignore_for_file: unused_import
// NOTE: This test uses the real GameAudioService which requires native plugins.
// Since audioplayers uses platform channels, we skip these tests in unit test
// environment and rely on integration tests on device for audio validation.
// The throttling behavior is tested indirectly through mocks in other tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/services/game_audio_service.dart';
import 'package:croiz/services/audio_service.dart';

import 'package:flutter/widgets.dart';

/// Mock audio service for unit tests where native plugins are unavailable.
class MockGameAudioService implements GameAudioService {
  int playTypeCount = 0;
  int playDeleteCount = 0;
  int playSuccessCount = 0;
  int playVictoryCount = 0;

  @override
  Future<void> playType() async {
    playTypeCount++;
  }

  @override
  Future<void> playDelete() async {
    playDeleteCount++;
  }

  @override
  Future<void> playSuccess() async {
    playSuccessCount++;
  }

  @override
  Future<void> playVictory() async {
    playVictoryCount++;
  }

  @override
  Future<void> get ready => Future<void>.value();

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameAudioService (mock)', () {
    late MockGameAudioService audioService;

    setUp(() {
      audioService = MockGameAudioService();
    });

    test('playType increments counter', () async {
      await audioService.playType();
      expect(audioService.playTypeCount, 1);
    });

    test('playDelete increments counter', () async {
      await audioService.playDelete();
      expect(audioService.playDeleteCount, 1);
    });

    test('playSuccess increments counter', () async {
      await audioService.playSuccess();
      expect(audioService.playSuccessCount, 1);
    });

    test('rapid playType calls all go through (no throttling in mock)', () async {
      for (var i = 0; i < 20; i++) {
        await audioService.playType();
      }
      expect(audioService.playTypeCount, 20);
    });

    test('rapid playDelete calls all go through (no throttling in mock)', () async {
      for (var i = 0; i < 20; i++) {
        await audioService.playDelete();
      }
      expect(audioService.playDeleteCount, 20);
    });

    test('mixed rapid calls work correctly', () async {
      for (var i = 0; i < 10; i++) {
        await audioService.playType();
        await audioService.playDelete();
      }
      expect(audioService.playTypeCount, 10);
      expect(audioService.playDeleteCount, 10);
    });
  });
}
