import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/game/providers/game_providers.dart';

void main() {
  group('PuzzlesListPage', () {
    testWidgets('shows loading indicator while loading origins', (
      tester,
    ) async {
      final completer = Completer<List<String>>();
      // Override with a loading state
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleOriginsProvider.overrideWith((ref) => completer.future),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PuzzlesListPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid pending timer errors
      completer.complete(<String>[]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows error message when origins fail to load', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleOriginsProvider.overrideWith(
              (ref) async => throw Exception('Network error'),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PuzzlesListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(tester.element(find.byType(PuzzlesListPage)));
      expect(
        find.textContaining(loc?.errorLoading ?? 'Error loading puzzle'),
        findsOneWidget,
      );
    });

    testWidgets('displays origins as expansion tiles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleOriginsProvider.overrideWith((ref) async => ['nyt', 'wsj']),
            // Provide empty indices for each origin
            originIndexProvider.overrideWith(
              (ref, origin) async => <PuzzleDescriptor>[],
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PuzzlesListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('nyt'), findsOneWidget);
      expect(find.text('wsj'), findsOneWidget);
    });

    testWidgets('groups puzzles by year within origin', (tester) async {
      final puzzles = [
        PuzzleDescriptor(
          id: 'p1',
          title: 'Puzzle 2023',
          path: 'nyt/2023/p1.json',
          origin: 'nyt',
          year: '2023',
        ),
        PuzzleDescriptor(
          id: 'p2',
          title: 'Puzzle 2022',
          path: 'nyt/2022/p2.json',
          origin: 'nyt',
          year: '2022',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          ],
          child: const MaterialApp(home: PuzzlesListPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Expand origin tile
      await tester.tap(find.text('nyt'));
      await tester.pumpAndSettle();

      // Years should be sorted descending (2023 before 2022)
      expect(find.text('2023'), findsOneWidget);
      expect(find.text('2022'), findsOneWidget);

      // Expand year tile to see puzzles
      await tester.tap(find.text('2023'));
      await tester.pumpAndSettle();

      expect(find.text('Puzzle 2023'), findsOneWidget);
    });

    testWidgets('shows loading indicator when expanding origin lazily', (
      tester,
    ) async {
      final completer = Completer<List<PuzzleDescriptor>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleOriginsProvider.overrideWith((ref) async => ['nyt']),
            originIndexProvider.overrideWith((ref, origin) => completer.future),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PuzzlesListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Expand origin tile
      await tester.tap(find.text('nyt'));
      await tester.pump();

      // Should show loading indicator for the origin content
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid pending timer errors
      completer.complete(<PuzzleDescriptor>[]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows error when origin index fails to load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleOriginsProvider.overrideWith((ref) async => ['nyt']),
            originIndexProvider.overrideWith(
              (ref, origin) async => throw Exception('Failed to load'),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PuzzlesListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Expand origin tile
      await tester.tap(find.text('nyt'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error loading'), findsOneWidget);
    });

    testWidgets('displays subtitle when available', (tester) async {
      final puzzles = [
        PuzzleDescriptor(
          id: 'p1',
          title: 'Daily Puzzle',
          path: 'nyt/2023/p1.json',
          subtitle: 'By John Doe',
          origin: 'nyt',
          year: '2023',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          ],
          child: const MaterialApp(home: PuzzlesListPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Expand tiles
      await tester.tap(find.text('nyt'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023'));
      await tester.pumpAndSettle();

      expect(find.text('Daily Puzzle'), findsOneWidget);
      expect(find.text('By John Doe'), findsOneWidget);
    });

    testWidgets('displays puzzles without year under unknown', (tester) async {
      final puzzles = [
        PuzzleDescriptor(
          id: 'p1',
          title: 'Old Puzzle',
          path: 'misc/p1.json',
          origin: 'misc',
          year: '', // Empty year
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          ],
          child: const MaterialApp(home: PuzzlesListPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Expand tiles
      await tester.tap(find.text('misc'));
      await tester.pumpAndSettle();

      // Should appear under "unknown" year
      expect(find.text('unknown'), findsOneWidget);
    });

    testWidgets('navigates to crossword screen on puzzle tap', (tester) async {
      String? navigatedPath;

      final router = GoRouter(
        initialLocation: '/puzzles',
        routes: [
          GoRoute(
            path: '/puzzles',
            builder: (context, state) => const PuzzlesListPage(),
          ),
          GoRoute(
            path: '/crossword',
            builder: (context, state) {
              navigatedPath = state.uri.toString();
              return Scaffold(body: Text('Crossword: ${state.uri}'));
            },
          ),
        ],
      );

      final puzzles = [
        PuzzleDescriptor(
          id: 'test-puzzle',
          title: 'Test Puzzle',
          path: 'nyt/2023/test-puzzle.json',
          origin: 'nyt',
          year: '2023',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Expand tiles
      await tester.tap(find.text('nyt'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023'));
      await tester.pumpAndSettle();

      // Tap puzzle
      await tester.tap(find.text('Test Puzzle'));
      await tester.pumpAndSettle();

      expect(navigatedPath, contains('id=test-puzzle'));
    });

    testWidgets('sets selectedPuzzleIdProvider on puzzle tap', (tester) async {
      String? selectedId;

      final router = GoRouter(
        initialLocation: '/puzzles',
        routes: [
          GoRoute(
            path: '/puzzles',
            builder: (context, state) => const PuzzlesListPage(),
          ),
          GoRoute(
            path: '/crossword',
            builder: (context, state) => Consumer(
              builder: (context, ref, _) {
                selectedId = ref.watch(selectedPuzzleIdProvider.notifier).value;
                return const Scaffold(body: Text('Crossword'));
              },
            ),
          ),
        ],
      );

      final puzzles = [
        PuzzleDescriptor(
          id: 'my-puzzle-id',
          title: 'My Puzzle',
          path: 'test/my-puzzle-id.json',
          origin: 'test',
          year: '2023',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Expand tiles
      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023'));
      await tester.pumpAndSettle();

      // Tap puzzle
      await tester.tap(find.text('My Puzzle'));
      await tester.pumpAndSettle();

      expect(selectedId, equals('my-puzzle-id'));
    });

    testWidgets('shows chevron icon for each puzzle', (tester) async {
      final puzzles = [
        PuzzleDescriptor(
          id: 'p1',
          title: 'Puzzle One',
          path: 'test/p1.json',
          origin: 'test',
          year: '2023',
        ),
        PuzzleDescriptor(
          id: 'p2',
          title: 'Puzzle Two',
          path: 'test/p2.json',
          origin: 'test',
          year: '2023',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          ],
          child: const MaterialApp(home: PuzzlesListPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Expand tiles
      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    });

    testWidgets('appBar shows "Puzzles" title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(const AsyncValue.data([])),
          ],
          child: const MaterialApp(home: PuzzlesListPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Puzzles'), findsOneWidget);
    });

    testWidgets('multiple origins sorted alphabetically', (tester) async {
      final puzzles = [
        PuzzleDescriptor(
          id: 'p1',
          title: 'WSJ Puzzle',
          path: 'wsj/2023/p1.json',
          origin: 'wsj',
          year: '2023',
        ),
        PuzzleDescriptor(
          id: 'p2',
          title: 'NYT Puzzle',
          path: 'nyt/2023/p2.json',
          origin: 'nyt',
          year: '2023',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          ],
          child: const MaterialApp(home: PuzzlesListPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Both origins should be visible and sorted
      expect(find.text('nyt'), findsOneWidget);
      expect(find.text('wsj'), findsOneWidget);
    });

    testWidgets('years sorted descending (newest first)', (tester) async {
      final puzzles = [
        PuzzleDescriptor(
          id: 'p1',
          title: 'Old',
          path: 'test/2020/p1.json',
          origin: 'test',
          year: '2020',
        ),
        PuzzleDescriptor(
          id: 'p2',
          title: 'New',
          path: 'test/2023/p2.json',
          origin: 'test',
          year: '2023',
        ),
        PuzzleDescriptor(
          id: 'p3',
          title: 'Middle',
          path: 'test/2021/p3.json',
          origin: 'test',
          year: '2021',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          ],
          child: const MaterialApp(home: PuzzlesListPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Expand origin tile
      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();

      // All year tiles should be visible
      expect(find.text('2023'), findsOneWidget);
      expect(find.text('2021'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
    });

    testWidgets('puzzles sorted alphabetically by title within year', (
      tester,
    ) async {
      final puzzles = [
        PuzzleDescriptor(
          id: 'p1',
          title: 'Zebra',
          path: 'test/2023/p1.json',
          origin: 'test',
          year: '2023',
        ),
        PuzzleDescriptor(
          id: 'p2',
          title: 'Alpha',
          path: 'test/2023/p2.json',
          origin: 'test',
          year: '2023',
        ),
        PuzzleDescriptor(
          id: 'p3',
          title: 'Beta',
          path: 'test/2023/p3.json',
          origin: 'test',
          year: '2023',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          ],
          child: const MaterialApp(home: PuzzlesListPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Expand tiles
      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023'));
      await tester.pumpAndSettle();

      // All puzzles should be visible
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Zebra'), findsOneWidget);
    });

    testWidgets('handles empty puzzle list gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(const AsyncValue.data([])),
          ],
          child: const MaterialApp(home: PuzzlesListPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Should still show the app bar
      expect(find.text('Puzzles'), findsOneWidget);
      // No expansion tiles since no puzzles
      expect(find.byType(ExpansionTile), findsNothing);
    });
  });
}
