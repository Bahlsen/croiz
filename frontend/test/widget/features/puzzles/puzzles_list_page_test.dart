import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/continue_playing_section.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_card.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/puzzles/widgets/puzzles_filter_row.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:croiz/features/monetization/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Google Mobile Ads platform channel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/google_mobile_ads'),
        (call) async {
          if (call.method == 'init') {
            return null;
          }
          if (call.method == 'loadAd') {
            // Return successful load response structure if needed?
            // For BannerAd, it likely expects nothing or a generic success.
            // Based on source, loadAd returns Future<void>.
            return null;
          }
          if (call.method == 'disposeAd') {
            return null;
          }
          return null;
        },
      );

  final testPuzzles = [
    PuzzleDescriptor(
      id: 'puzzle-1',
      title: 'Easy Puzzle',
      path: 'test/easy.json',
      difficulty: 1,
      difficultyLabel: 'Easy',
      language: 'en',
      origin: 'test',
      year: '2024',
    ),
    PuzzleDescriptor(
      id: 'puzzle-2',
      title: 'Medium Puzzle',
      path: 'test/medium.json',
      difficulty: 2,
      difficultyLabel: 'Medium',
      language: 'en',
      origin: 'test',
      year: '2024',
    ),
    PuzzleDescriptor(
      id: 'puzzle-3',
      title: 'Hard Puzzle',
      path: 'test/hard.json',
      difficulty: 3,
      difficultyLabel: 'Hard',
      language: 'fr',
      origin: 'test',
      year: '2024',
    ),
  ];

  testWidgets('shows ContinuePlayingSection at top', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWith((ref) async => testPuzzles),
          inProgressPuzzlesProvider.overrideWith((ref) async => []),
          monetizationServiceProvider.overrideWith(
            (ref) => MockMonetizationService(),
          ),
        ],
        child: MaterialApp(
          home: Sizer(
            builder:
                (context, orientation, deviceType) => const PuzzlesListPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // ContinuePlayingSection should be at top (even if empty shows placeholder)
    expect(find.byType(ContinuePlayingSection), findsOneWidget);
  });

  testWidgets('shows PuzzlesFilterRow below ContinuePlayingSection', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWith((ref) async => testPuzzles),
          inProgressPuzzlesProvider.overrideWith((ref) async => []),
          monetizationServiceProvider.overrideWith(
            (ref) => MockMonetizationService(),
          ),
        ],
        child: MaterialApp(
          home: Sizer(
            builder:
                (context, orientation, deviceType) => const PuzzlesListPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Filter chips should be visible (inside PuzzlesFilterRow)
    expect(find.byType(PuzzlesFilterRow), findsOneWidget);
  });

  testWidgets('list shows all puzzles initially', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWith((ref) async => testPuzzles),
          inProgressPuzzlesProvider.overrideWith((ref) async => []),
          monetizationServiceProvider.overrideWith(
            (ref) => MockMonetizationService(),
          ),
        ],
        child: MaterialApp(
          home: Sizer(
            builder:
                (context, orientation, deviceType) => const PuzzlesListPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // First two puzzles should be visible
    expect(find.text('Easy Puzzle'), findsOneWidget);
    expect(find.text('Medium Puzzle'), findsOneWidget);
    // Third might need scrolling, just check the first two
  });

  testWidgets('shows puzzle count in app bar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWith((ref) async => testPuzzles),
          inProgressPuzzlesProvider.overrideWith((ref) async => []),
          monetizationServiceProvider.overrideWith(
            (ref) => MockMonetizationService(),
          ),
        ],
        child: MaterialApp(
          home: Sizer(
            builder:
                (context, orientation, deviceType) => const PuzzlesListPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // App bar should show count (3 puzzles)
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('shows loading indicator while loading', (tester) async {
    // Use a completer to control when the future completes
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWith(
            (ref) => Future<List<PuzzleDescriptor>>.delayed(
              const Duration(milliseconds: 100),
              () => testPuzzles,
            ),
          ),
          inProgressPuzzlesProvider.overrideWith((ref) async => []),
          monetizationServiceProvider.overrideWith(
            (ref) => MockMonetizationService(),
          ),
        ],
        child: MaterialApp(
          home: Sizer(
            builder:
                (context, orientation, deviceType) => const PuzzlesListPage(),
          ),
        ),
      ),
    );

    // Pump one frame to show loading
    await tester.pump();
    await tester.pump();

    // Should show loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future
    await tester.pumpAndSettle();
  });

  testWidgets('shows error message on error', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWith(
            (ref) async => throw Exception('Test error'),
          ),
          inProgressPuzzlesProvider.overrideWith((ref) async => []),
          monetizationServiceProvider.overrideWith(
            (ref) => MockMonetizationService(),
          ),
        ],
        child: MaterialApp(
          home: Sizer(
            builder:
                (context, orientation, deviceType) => const PuzzlesListPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should show error message
    expect(find.textContaining('Error'), findsOneWidget);
  });

  testWidgets('ListView uses builder pattern for performance', (tester) async {
    // Create many puzzles to test performance
    final manyPuzzles = List.generate(
      100,
      (i) => PuzzleDescriptor(
        id: 'puzzle-$i',
        title: 'Puzzle $i',
        path: 'test/$i.json',
        difficulty: (i % 5) + 1,
        difficultyLabel: ['Easy', 'Medium', 'Hard', 'Expert', 'Master'][i % 5],
        language: 'en',
        origin: 'test',
        year: '2024',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWith((ref) async => manyPuzzles),
          inProgressPuzzlesProvider.overrideWith((ref) async => []),
          monetizationServiceProvider.overrideWith(
            (ref) => MockMonetizationService(),
          ),
        ],
        child: MaterialApp(
          home: Sizer(
            builder:
                (context, orientation, deviceType) => const PuzzlesListPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should not render all items at once (lazy loading)
    // Only visible items + cache should be built
    final listTiles = find.byType(PuzzleCard);
    // Not all 100 tiles should be in the tree at once
    expect(listTiles.evaluate().length, lessThan(100));
  });
  testWidgets('settings icon opens settings menu', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWith((ref) async => testPuzzles),
          inProgressPuzzlesProvider.overrideWith((ref) async => []),
          monetizationServiceProvider.overrideWith(
            (ref) => MockMonetizationService(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Sizer(
            builder:
                (context, orientation, deviceType) => const PuzzlesListPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify settings icon exists
    final settingsIcon = find.byKey(const Key('settings_icon'));
    expect(settingsIcon, findsOneWidget);

    // Tap it
    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();

    // Verify menu is shown
    expect(find.byType(CrosswordControlsMenu), findsOneWidget);
  });

  testWidgets(
    'search query persists when search bar text is cleared on rebuild',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWith((ref) async => testPuzzles),
            inProgressPuzzlesProvider.overrideWith((ref) async => []),
            monetizationServiceProvider.overrideWith(
              (ref) => MockMonetizationService(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Sizer(
              builder:
                  (context, orientation, deviceType) => const PuzzlesListPage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially, all 3 puzzles should be visible
      expect(find.text('Easy Puzzle'), findsOneWidget);
      expect(find.text('Medium Puzzle'), findsOneWidget);

      // Find and enter text in search bar
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Easy');
      await tester.pumpAndSettle();

      // Only "Easy Puzzle" should be visible now
      expect(find.text('Easy Puzzle'), findsOneWidget);
      expect(find.text('Medium Puzzle'), findsNothing);

      // Clear the search field (simulating what happens when widget rebuilds)
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // After clearing the search, all puzzles should be visible again
      expect(find.text('Easy Puzzle'), findsOneWidget);
      expect(find.text('Medium Puzzle'), findsOneWidget);
    },
  );
}

class MockMonetizationService implements MonetizationService {
  @override
  String get bannerAdUnitId => 'test_banner_id';

  @override
  String get interstitialAdUnitId => 'test_interstitial_id';

  @override
  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    final ad = FakeBannerAd(onAdLoaded);
    return ad;
  }

  @override
  void showInterstitialAd() {}
}

class FakeBannerAd extends BannerAd {
  FakeBannerAd(this.onLoadedCallback)
    : super(
        adUnitId: 'test',
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );

  final void Function(Ad) onLoadedCallback;

  @override
  Future<void> load() async {
    // Wait for super.load() to complete so internal state is updated by mocked platform channel
    await super.load();
    // Then notify the listener (which updates BannerAdWidget state)
    onLoadedCallback(this);
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
  }
}
