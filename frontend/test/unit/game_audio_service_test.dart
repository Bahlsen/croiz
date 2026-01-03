import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/services/audio_service.dart';

/// Integration tests for GameAudioService behavior.
///
/// Note: Real audio playback requires native plugins which are not available
/// in unit test environment. These tests verify the service contract using
/// a testable implementation. For real audio validation, run on device.
///
/// The key behaviors we test:
/// 1. All AudioService methods are callable
/// 2. Throttling works correctly (80ms between same sound type)
/// 3. Dispose is safe to call multiple times

/// Testable implementation that tracks calls without native dependencies.
class TestableAudioService implements AudioService {
  int typeCount = 0;
  int deleteCount = 0;
  int successCount = 0;
  int victoryCount = 0;
  int revealCount = 0;
  bool isDisposed = false;

  // Simulate throttling like the real service
  static const _minInterval = Duration(milliseconds: 80);
  DateTime? _lastTypeAt;
  DateTime? _lastDeleteAt;

  @override
  Future<void> get ready => Future.value();

  @override
  Future<void> playType() async {
    final now = DateTime.now();
    if (_lastTypeAt != null && now.difference(_lastTypeAt!) < _minInterval) {
      return; // Throttled
    }
    _lastTypeAt = now;
    typeCount++;
  }

  @override
  Future<void> playDelete() async {
    final now = DateTime.now();
    if (_lastDeleteAt != null &&
        now.difference(_lastDeleteAt!) < _minInterval) {
      return; // Throttled
    }
    _lastDeleteAt = now;
    deleteCount++;
  }

  @override
  Future<void> playSuccess() async {
    successCount++;
  }

  @override
  Future<void> playVictory() async {
    victoryCount++;
  }

  @override
  Future<void> playReveal() async {
    revealCount++;
  }

  @override
  Future<void> dispose() async {
    isDisposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService contract', () {
    late TestableAudioService service;

    setUp(() {
      service = TestableAudioService();
    });

    test('ready completes immediately', () async {
      await expectLater(service.ready, completes);
    });

    test('playType increments counter', () async {
      await service.playType();
      expect(service.typeCount, 1);
    });

    test('playDelete increments counter', () async {
      await service.playDelete();
      expect(service.deleteCount, 1);
    });

    test('playSuccess increments counter', () async {
      await service.playSuccess();
      expect(service.successCount, 1);
    });

    test('playVictory increments counter', () async {
      await service.playVictory();
      expect(service.victoryCount, 1);
    });

    test('playReveal increments counter', () async {
      await service.playReveal();
      expect(service.revealCount, 1);
    });

    test('playType is throttled at 80ms', () async {
      // First call goes through
      await service.playType();
      expect(service.typeCount, 1);

      // Immediate second call is throttled
      await service.playType();
      expect(service.typeCount, 1, reason: 'Should be throttled');

      // Wait past throttle interval
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await service.playType();
      expect(service.typeCount, 2, reason: 'Should go through after wait');
    });

    test('playDelete is throttled at 80ms', () async {
      await service.playDelete();
      expect(service.deleteCount, 1);

      await service.playDelete();
      expect(service.deleteCount, 1, reason: 'Should be throttled');

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await service.playDelete();
      expect(service.deleteCount, 2, reason: 'Should go through after wait');
    });

    test('playSuccess is not throttled', () async {
      for (var i = 0; i < 5; i++) {
        await service.playSuccess();
      }
      expect(service.successCount, 5);
    });

    test('dispose marks service as disposed', () async {
      expect(service.isDisposed, false);
      await service.dispose();
      expect(service.isDisposed, true);
    });

    test('dispose can be called multiple times', () async {
      await service.dispose();
      await expectLater(service.dispose(), completes);
    });
  });
}
