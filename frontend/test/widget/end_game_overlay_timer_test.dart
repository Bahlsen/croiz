import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/providers/game_timer_provider.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
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
    if (value != null) {
      _map[key] = value;
    }
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
  }) async {
    _map.remove(key);
  }
}

void main() {
  testWidgets(
    'EndGameOverlay shows formatted elapsed time when puzzle completed',
    (tester) async {
      final board = GameBoard(
        id: 'timer-test',
        title: 'Timer Test',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          [null, null, null],
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: [
          [false, false, false],
          [false, false, false],
          [false, false, false],
        ],
        difficulty: 1,
        entries: [
          const PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          secureStorageProvider.overrideWithValue(TestSecureStorage()),
        ],
      );
      addTearDown(container.dispose);

      // Set elapsed to 125 seconds -> formatted 02:05
      await container.read(gameTimerProvider(board.id)).setElapsed(125);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: EndGameOverlay())),
        ),
      );

      // Overlay not visible until marked complete
      expect(find.text('Congratulations!'), findsNothing);

      // Mark words as found to trigger overlay
      container.read(foundWordsProvider.notifier).setFoundWords({'0,0,across'});
      await tester.pumpAndSettle();

      // Expect formatted time displayed
      expect(find.text('02:05'), findsOneWidget);
    },
  );
}
