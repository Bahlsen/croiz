import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          ],
          child: Sizer(
            builder: (context, orientation, deviceType) => MaterialApp.router(
              routerConfig: router,
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
