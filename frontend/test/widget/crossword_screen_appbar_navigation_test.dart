import 'package:croiz/features/game/crossword_screen.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Puzzles'), findsOneWidget);
    },
  );
}
