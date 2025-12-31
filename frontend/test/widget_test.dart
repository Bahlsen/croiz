// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';

import 'test_utils/fake_audio_service.dart';
import 'package:croiz/l10n/app_localizations.dart';

void main() {
  testWidgets('App renders puzzles list screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    const size = 5;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final black = List.generate(size, (_) => List<bool>.filled(size, false));
    final boardWithEntries = GameBoard(
      id: 'test-empty',
      title: 'Test',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 3),
        PuzzleEntryData(number: 2, direction: 'down', x: 2, y: 1, length: 4),
      ],
    );

    // Use a fake audio service that completes initialization instantly
    final fakeAudioService = FakeAudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(boardWithEntries),
          ),
          // Override audio service for fast initialization
          gameAudioServiceProvider.overrideWithValue(fakeAudioService),
          // Provide puzzle list data for the puzzles list screen
          puzzlesProvider.overrideWithValue(
            AsyncValue.data([
              PuzzleDescriptor(
                id: 'test-puzzle',
                title: 'Test Puzzle',
                path: 'assets/data/test.json',
              ),
            ]),
          ),
        ],
        child: Sizer(
          builder: (context, orientation, deviceType) => const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PuzzlesListPage(),
          ),
        ),
      ),
    );

    // Wait for splash screen to complete and transition to puzzles list
    // Pump frames at intervals to allow async providers and animations to settle
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify that the puzzles list screen is displayed
    // The app now navigates directly to the puzzles list, skipping the home page
    expect(find.text('Puzzles'), findsWidgets);
  });
}
