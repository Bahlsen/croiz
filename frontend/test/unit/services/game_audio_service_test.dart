// ignore_for_file: unused_import

import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/services/game_audio_service.dart';

import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameAudioService', () {
    late GameAudioService audioService;

    setUp(() {
      audioService = GameAudioService();
    });

    test('playType does not throw', () async {
      expect(() => audioService.playType(), returnsNormally);
    });

    test('playDelete does not throw', () async {
      expect(() => audioService.playDelete(), returnsNormally);
    });

    test('playSuccess does not throw', () async {
      expect(() => audioService.playSuccess(), returnsNormally);
    });

    test('rapid playType calls do not throw (throttling test)', () async {
      // Simulate rapid typing - should be throttled without errors
      for (var i = 0; i < 20; i++) {
        expect(() => audioService.playType(), returnsNormally);
      }
    });

    test('rapid playDelete calls do not throw (throttling test)', () async {
      // Simulate rapid deleting - should be throttled without errors
      for (var i = 0; i < 20; i++) {
        expect(() => audioService.playDelete(), returnsNormally);
      }
    });

    test('mixed rapid calls do not throw', () async {
      // Simulate mixed rapid typing and deleting
      for (var i = 0; i < 10; i++) {
        expect(() => audioService.playType(), returnsNormally);
        expect(() => audioService.playDelete(), returnsNormally);
      }
    });
  });
}
