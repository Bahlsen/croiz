// ignore_for_file: always_put_required_named_parameters_first,always_put_control_body_on_new_line,prefer_expression_function_bodies,unnecessary_lambdas
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_timer_provider.dart';
import 'package:croiz/services/providers.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TestSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _map = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    if (value != null) _map[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async => _map[key];

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async => _map.remove(key);
}

void main() {
  test('GameTimer start/pause/finalize persistence', () async {
    final storage = TestSecureStorage();
    final container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(storage)],
    );

    addTearDown(() => container.dispose());

    final timer = container.read(gameTimerProvider('test-game'));

    // start should persist startedAt
    await timer.start();
    final started = await storage.read(key: 'puzzle:test-game:startedAt');
    expect(started, isNotNull);

    // pause should persist accumulatedMs and clear startedAt
    await Future.delayed(const Duration(milliseconds: 10));
    await timer.pause();
    final acc = await storage.read(key: 'puzzle:test-game:accumulatedMs');
    expect(acc, isNotNull);

    // finalizeSync returns a non-negative seconds count and persists completedAt
    final secs = timer.finalizeSync();
    expect(secs, greaterThanOrEqualTo(0));
    final completed = await storage.read(key: 'puzzle:test-game:completedAt');
    expect(completed, isNotNull);
  });
}
