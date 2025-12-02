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
  });
}
