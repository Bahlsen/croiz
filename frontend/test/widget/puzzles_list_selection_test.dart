import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/services/persistence/storage_provider.dart';
import '../helpers/fake_puzzle_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import '../helpers/fake_monetization_service.dart';
import 'package:croiz/features/monetization/services/ad_service.dart';

void main() {
  testWidgets('Selecting a puzzle loads board and navigates', (tester) async {
    final sample = [
      PuzzleDescriptor(
        id: 'sample1',
        title: 'Sample',
        path: 'assets/data/sample1.json',
      ),
    ];

    final fakeBoard = GameBoard(
      id: 'sample1',
      title: 'Sample',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: List.generate(3, (_) => List<String?>.filled(3, null)),
      clues: {},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 1,
    );
    fakeBoard.grid[0][0] = 'A';

    final router = GoRouter(
      initialLocation: '/puzzles',
      routes: [
        GoRoute(
          path: '/puzzles',
          builder: (context, state) => const PuzzlesListPage(),
        ),
        GoRoute(
          path: '/crossword',
          builder:
              (context, state) =>
                  CrosswordScreen(puzzleId: state.uri.queryParameters['id']),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWithValue(AsyncValue.data(sample)),
          puzzleAssetLoaderProvider.overrideWithValue(
            (String path) async => fakeBoard,
          ),
          puzzleStorageProvider.overrideWithValue(FakePuzzleStorage()),
          monetizationServiceProvider.overrideWith(
            (ref) => FakeMonetizationService(),
          ),
        ],
        child: Sizer(
          builder:
              (context, orientation, deviceType) => MaterialApp.router(
                routerConfig: router,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
              ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // New UI shows puzzles directly in a flat list (no expansion tiles)
    expect(find.text('Sample'), findsOneWidget);

    await tester.tap(find.text('Sample'));
    await tester.pumpAndSettle();

    // Verify we navigated to the crossword screen and grid is visible
    expect(find.byType(CrosswordScreen), findsOneWidget);
    expect(find.text('A'), findsWidgets);
  });
}
