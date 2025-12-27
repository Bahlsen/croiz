/// Audio performance tests - verify audio throttling and latency behavior.
///
/// These tests simulate fast typing scenarios and verify that:
/// 1. Audio requests are properly throttled
/// 2. No backlog accumulates during rapid input
/// 3. Throttling intervals are correctly enforced
library;

import 'package:flutter_test/flutter_test.dart';

/// Mock-like test implementation of audio throttling logic
/// to verify the throttling algorithm works correctly.
class AudioThrottleTester {
  AudioThrottleTester({required this.minInterval});

  final Duration minInterval;
  DateTime? _lastPlayAt;
  int _playedCount = 0;
  int _droppedCount = 0;
  final List<Duration> _playLatencies = [];
  DateTime? _firstRequestAt;

  /// Simulates a play request. Returns true if played, false if throttled.
  bool tryPlay(DateTime now) {
    _firstRequestAt ??= now;

    if (_lastPlayAt != null && now.difference(_lastPlayAt!) < minInterval) {
      _droppedCount++;
      return false;
    }

    _lastPlayAt = now;
    _playedCount++;
    _playLatencies.add(now.difference(_firstRequestAt!));
    return true;
  }

  int get playedCount => _playedCount;
  int get droppedCount => _droppedCount;
  int get totalRequests => _playedCount + _droppedCount;
  double get dropRate =>
      totalRequests > 0 ? _droppedCount / totalRequests : 0.0;
  List<Duration> get playLatencies => List.unmodifiable(_playLatencies);

  void reset() {
    _lastPlayAt = null;
    _playedCount = 0;
    _droppedCount = 0;
    _playLatencies.clear();
    _firstRequestAt = null;
  }
}

/// Simulates dual-layer throttling (UI + Service level) as in production.
class DualThrottleTester {
  DualThrottleTester({
    required this.uiMinInterval,
    required this.serviceMinInterval,
  });

  final Duration uiMinInterval;
  final Duration serviceMinInterval;

  DateTime? _lastUiAt;
  DateTime? _lastServiceAt;

  int _uiPassedCount = 0;
  int _uiDroppedCount = 0;
  int _servicePlayedCount = 0;
  int _serviceDroppedCount = 0;

  /// Simulates a request going through UI layer then service layer.
  /// Returns: 0 = dropped at UI, 1 = dropped at service, 2 = played
  int tryPlay(DateTime now) {
    // UI layer throttle
    if (_lastUiAt != null && now.difference(_lastUiAt!) < uiMinInterval) {
      _uiDroppedCount++;
      return 0;
    }
    _lastUiAt = now;
    _uiPassedCount++;

    // Service layer throttle
    if (_lastServiceAt != null &&
        now.difference(_lastServiceAt!) < serviceMinInterval) {
      _serviceDroppedCount++;
      return 1;
    }
    _lastServiceAt = now;
    _servicePlayedCount++;
    return 2;
  }

  int get uiDroppedCount => _uiDroppedCount;
  int get serviceDroppedCount => _serviceDroppedCount;
  int get playedCount => _servicePlayedCount;
  int get totalRequests => _uiDroppedCount + _uiPassedCount;

  double get effectiveDropRate {
    final total = totalRequests;
    if (total == 0) {
      return 0;
    }
    return (_uiDroppedCount + _serviceDroppedCount) / total;
  }

  void reset() {
    _lastUiAt = null;
    _lastServiceAt = null;
    _uiPassedCount = 0;
    _uiDroppedCount = 0;
    _servicePlayedCount = 0;
    _serviceDroppedCount = 0;
  }
}

void main() {
  group('Audio Throttle Performance Tests', () {
    late AudioThrottleTester tester;

    setUp(() {
      tester = AudioThrottleTester(
        minInterval: const Duration(milliseconds: 60),
      );
    });

    test('Single request should always play', () {
      final now = DateTime.now();
      expect(tester.tryPlay(now), isTrue);
      expect(tester.playedCount, 1);
      expect(tester.droppedCount, 0);
    });

    test('Requests spaced by minInterval should all play', () {
      var now = DateTime.now();
      const spacing = Duration(milliseconds: 60);

      for (var i = 0; i < 10; i++) {
        expect(tester.tryPlay(now), isTrue, reason: 'Request $i should play');
        now = now.add(spacing);
      }

      expect(tester.playedCount, 10);
      expect(tester.droppedCount, 0);
    });

    test('Rapid requests (10ms apart) should be throttled', () {
      var now = DateTime.now();
      const rapidSpacing = Duration(milliseconds: 10);

      // Simulate 100ms of rapid typing at 100 keys/sec
      for (var i = 0; i < 10; i++) {
        tester.tryPlay(now);
        now = now.add(rapidSpacing);
      }

      // With 60ms throttle and 10ms spacing over 100ms:
      // First request at 0ms -> plays
      // Requests at 10,20,30,40,50ms -> dropped (< 60ms from first)
      // Request at 60ms-ish -> should ideally play (but we're at 70ms by then)
      // Expected: ~2 plays (at 0ms and around 70ms)
      expect(tester.playedCount, lessThanOrEqualTo(3));
      expect(tester.droppedCount, greaterThanOrEqualTo(7));
      expect(tester.dropRate, greaterThan(0.6));
    });

    test('Very fast typing (5ms apart) stress test', () {
      var now = DateTime.now();
      const veryFastSpacing = Duration(milliseconds: 5);

      // Simulate 500ms of extremely fast typing
      for (var i = 0; i < 100; i++) {
        tester.tryPlay(now);
        now = now.add(veryFastSpacing);
      }

      // 500ms total, 60ms throttle = max ~8-9 sounds
      expect(tester.playedCount, lessThanOrEqualTo(10));
      expect(tester.dropRate, greaterThan(0.9));
    });

    test('Burst typing pattern (fast burst, pause, fast burst)', () {
      var now = DateTime.now();

      // First burst: 5 keys in 20ms
      for (var i = 0; i < 5; i++) {
        tester.tryPlay(now);
        now = now.add(const Duration(milliseconds: 4));
      }

      // Pause for 100ms
      now = now.add(const Duration(milliseconds: 100));

      // Second burst: 5 keys in 20ms
      for (var i = 0; i < 5; i++) {
        tester.tryPlay(now);
        now = now.add(const Duration(milliseconds: 4));
      }

      // Should have 1 play per burst + maybe 1 more = 2-4 plays
      expect(tester.playedCount, inInclusiveRange(2, 4));
      expect(tester.totalRequests, 10);
    });

    test('Maximum throughput should not exceed ~16.7 sounds/sec', () {
      var now = DateTime.now();
      const testDuration = Duration(seconds: 1);
      const keyInterval = Duration(milliseconds: 1); // 1000 keys/sec input

      final endTime = now.add(testDuration);
      while (now.isBefore(endTime)) {
        tester.tryPlay(now);
        now = now.add(keyInterval);
      }

      // 60ms throttle = max 16.67 sounds/sec
      // Over 1 second, should get ~16-17 plays max
      expect(tester.playedCount, lessThanOrEqualTo(18));
      expect(tester.playedCount, greaterThanOrEqualTo(15));
    });
  });

  group('Dual Layer Throttle Tests', () {
    late DualThrottleTester tester;

    setUp(() {
      tester = DualThrottleTester(
        uiMinInterval: const Duration(milliseconds: 60),
        serviceMinInterval: const Duration(milliseconds: 60),
      );
    });

    test('Synchronized throttles should behave like single throttle', () {
      var now = DateTime.now();

      // When both layers have same interval and are synchronized,
      // the service layer should never drop (UI catches everything)
      for (var i = 0; i < 100; i++) {
        tester.tryPlay(now);
        now = now.add(const Duration(milliseconds: 5));
      }

      // UI should catch most drops, service should get few/none
      expect(
        tester.serviceDroppedCount,
        0,
        reason: 'Service should not drop when UI is synchronized',
      );
      expect(tester.uiDroppedCount, greaterThan(0));
    });

    test('Realistic typing speed (150 WPM) should be smooth', () {
      // 150 WPM = 150 * 5 chars = 750 chars/min = 12.5 chars/sec
      // = 80ms between keystrokes on average
      var now = DateTime.now();
      const typingInterval = Duration(milliseconds: 80);

      for (var i = 0; i < 50; i++) {
        final result = tester.tryPlay(now);
        expect(result, 2, reason: 'Normal typing should always play');
        now = now.add(typingInterval);
      }

      expect(tester.playedCount, 50);
      expect(tester.effectiveDropRate, 0.0);
    });

    test('Fast typing speed (300 WPM) should have some drops', () {
      // 300 WPM = 1500 chars/min = 25 chars/sec = 40ms between keys
      var now = DateTime.now();
      const fastTypingInterval = Duration(milliseconds: 40);

      for (var i = 0; i < 50; i++) {
        tester.tryPlay(now);
        now = now.add(fastTypingInterval);
      }

      // 40ms < 60ms throttle, so some will drop
      expect(tester.effectiveDropRate, greaterThan(0.0));
      expect(tester.effectiveDropRate, lessThanOrEqualTo(0.5));
    });

    test('Extreme speed typing stress test', () {
      var now = DateTime.now();
      const extremeInterval = Duration(milliseconds: 10);

      // 1000ms of extreme typing
      for (var i = 0; i < 100; i++) {
        tester.tryPlay(now);
        now = now.add(extremeInterval);
      }

      // Should drop >80% of requests
      expect(tester.effectiveDropRate, greaterThan(0.8));
      // But still play some sounds
      expect(tester.playedCount, greaterThan(0));
      expect(tester.playedCount, lessThanOrEqualTo(20));
    });
  });

  group('Audio Backlog Prevention Tests', () {
    test('Fire-and-forget pattern should not accumulate futures', () async {
      // Simulate what happens when we call unawaited(pool.start())
      // many times in quick succession
      final futures = <Future<void>>[];
      var completedCount = 0;

      // Simulate 50 rapid audio starts (even if throttled in real code)
      for (var i = 0; i < 50; i++) {
        final future = Future<void>.delayed(
          Duration(milliseconds: i % 10), // Variable completion time
          () => completedCount++,
        );
        futures.add(future);
      }

      // All should complete eventually
      await Future.wait(futures);
      expect(completedCount, 50);
    });

    test('Throttle prevents queue buildup simulation', () {
      // This tests that throttling prevents too many sounds from queuing
      final tester = AudioThrottleTester(
        minInterval: const Duration(milliseconds: 60),
      );

      var now = DateTime.now();
      var queuedSounds = 0;

      // Simulate 500ms of typing at 5ms intervals (100 key presses)
      for (var i = 0; i < 100; i++) {
        if (tester.tryPlay(now)) {
          queuedSounds++;
        }
        now = now.add(const Duration(milliseconds: 5));
      }

      // With proper throttling, should queue max ~8-9 sounds (500ms / 60ms)
      expect(queuedSounds, lessThanOrEqualTo(10));

      // Verify the throttle is working correctly
      expect(tester.dropRate, greaterThan(0.9));
    });
  });

  group('Throttle Interval Tuning Tests', () {
    test('30ms interval allows more sounds (for comparison)', () {
      final tester30ms = AudioThrottleTester(
        minInterval: const Duration(milliseconds: 30),
      );
      var now = DateTime.now();

      for (var i = 0; i < 100; i++) {
        tester30ms.tryPlay(now);
        now = now.add(const Duration(milliseconds: 5));
      }

      // 500ms / 30ms = ~16-17 sounds
      expect(tester30ms.playedCount, greaterThan(15));
    });

    test('100ms interval drops more but prevents backlog better', () {
      final tester100ms = AudioThrottleTester(
        minInterval: const Duration(milliseconds: 100),
      );
      var now = DateTime.now();

      for (var i = 0; i < 100; i++) {
        tester100ms.tryPlay(now);
        now = now.add(const Duration(milliseconds: 5));
      }

      // 500ms / 100ms = ~5 sounds
      expect(tester100ms.playedCount, lessThanOrEqualTo(6));
    });

    test('Find optimal interval for balance', () {
      // Test different intervals to find the sweet spot
      final results = <int, int>{};

      for (final intervalMs in [30, 40, 50, 60, 80, 100]) {
        final tester = AudioThrottleTester(
          minInterval: Duration(milliseconds: intervalMs),
        );
        var now = DateTime.now();

        // Simulate 1 second of fast typing (10ms intervals)
        for (var i = 0; i < 100; i++) {
          tester.tryPlay(now);
          now = now.add(const Duration(milliseconds: 10));
        }

        results[intervalMs] = tester.playedCount;
      }

      // 60ms is a good balance: ~16 sounds/sec max
      // This should feel responsive without causing backlog
      expect(results[60], inInclusiveRange(15, 18));

      // Print results for analysis (visible in verbose test output)
      // (perf) suppressed noisy output: throttle interval analysis results
      // results: ${results.toString()}
    });
  });

  group('Edge Cases', () {
    test('Exactly at threshold timing', () {
      final tester = AudioThrottleTester(
        minInterval: const Duration(milliseconds: 60),
      );
      final now = DateTime.now();

      // First play
      expect(tester.tryPlay(now), isTrue);

      // Exactly at 60ms - should play
      expect(tester.tryPlay(now.add(const Duration(milliseconds: 60))), isTrue);

      // At 59ms from second play - should drop
      expect(
        tester.tryPlay(now.add(const Duration(milliseconds: 119))),
        isFalse,
      );

      // At 120ms from start - should play
      expect(
        tester.tryPlay(now.add(const Duration(milliseconds: 120))),
        isTrue,
      );

      expect(tester.playedCount, 3);
      expect(tester.droppedCount, 1);
    });

    test('Very long gap resets throttle correctly', () {
      final tester = AudioThrottleTester(
        minInterval: const Duration(milliseconds: 60),
      );
      var now = DateTime.now();

      expect(tester.tryPlay(now), isTrue);

      // Long gap (10 seconds)
      now = now.add(const Duration(seconds: 10));
      expect(tester.tryPlay(now), isTrue);

      // Should still throttle rapid follow-up
      now = now.add(const Duration(milliseconds: 10));
      expect(tester.tryPlay(now), isFalse);

      expect(tester.playedCount, 2);
    });
  });
}
