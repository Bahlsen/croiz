import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/fake_monetization_service.dart';
import 'package:croiz/features/monetization/services/ad_service.dart';

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
  }) async => _map.remove(key);
}

void main() {
  testWidgets('EndGameOverlay shows when all words found', (tester) async {
    final board = GameBoard(
      id: 'test',
      title: 'T',
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
        monetizationServiceProvider.overrideWith(
          (ref) => FakeMonetizationService(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) =>
                  const MaterialApp(home: Scaffold(body: EndGameOverlay())),
        ),
      ),
    );

    // not yet showing because foundWords is empty
    final congratsFinder = find.text('Congratulations!');
    expect(congratsFinder, findsNothing);

    // mark words as found
    container.read(foundWordsProvider.notifier).setFoundWords({'0,0,across'});

    // Use multiple pumps to trigger the first few frames of animations
    // instead of pumpAndSettle which would timeout on repeating animations
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // overlay should appear
    expect(congratsFinder, findsOneWidget);
    // Use find.textContaining or check for the fallback 'View' if localization is missing
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });
}
