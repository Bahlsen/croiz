import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/services/persistence/storage_provider.dart';
import '../helpers/fake_puzzle_storage.dart';
import '../helpers/fake_monetization_service.dart';
import 'package:croiz/features/monetization/services/ad_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'CrosswordScreen leading button uses arrow icon and navigates to puzzles',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/crossword',
        routes: [
          GoRoute(
            path: '/crossword',
            builder: (context, state) => const CrosswordScreen(),
          ),
          GoRoute(
            path: '/puzzles',
            builder: (context, state) => const PuzzlesListPage(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzlesProvider.overrideWithValue(
              const AsyncValue.data(<PuzzleDescriptor>[]),
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

      // Open the in-screen menu and use the Home action to navigate.
      expect(find.byKey(const Key('menu_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('menu_button')));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.text('Puzzles'), findsOneWidget);
    },
  );
}
