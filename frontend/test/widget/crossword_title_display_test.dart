import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_header.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/l10n/app_localizations.dart';

void main() {
  testWidgets('Puzzle title is displayed in CrosswordClueHeader', (
    WidgetTester tester,
  ) async {
    final board = GameBoard(
      id: 'test_id',
      title: 'TEST PUZZLE TITLE',
      gridSize: 5,
      createdAt: DateTime.now(),
      grid: List.generate(5, (_) => List.generate(5, (_) => null)),
      clues: {},
      blackCells: List.generate(5, (_) => List.generate(5, (_) => false)),
      difficulty: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzleLoaderProvider.overrideWith((ref) => Future.value(board)),
        ],
        child: Sizer(
          builder:
              (context, orientation, deviceType) => const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: CrosswordClueHeader(onMenu: null, onReveal: null),
                ),
              ),
        ),
      ),
    );

    // Wait for the future to complete
    await tester.pumpAndSettle();

    // Verify title is displayed
    expect(find.text('TEST PUZZLE TITLE'), findsOneWidget);
  });

  testWidgets('Puzzle title is NOT displayed when board is still loading', (
    WidgetTester tester,
  ) async {
    // A future that never completes during the test
    final completer = Future<GameBoard>.value(
      GameBoard(
        id: 'id',
        title: 'LOADING...',
        gridSize: 5,
        createdAt: DateTime.now(),
        grid: [],
        clues: {},
        blackCells: [],
        difficulty: 1,
      ),
    ).then((_) => Completer<GameBoard>().future);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [puzzleLoaderProvider.overrideWith((ref) => completer)],
        child: Sizer(
          builder:
              (context, orientation, deviceType) => const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: CrosswordClueHeader(onMenu: null, onReveal: null),
                ),
              ),
        ),
      ),
    );

    // Should not find the title yet
    expect(find.text('TEST PUZZLE TITLE'), findsNothing);
  });
}
