import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/l10n/app_localizations.dart';

void main() {
  testWidgets('Menu Home item navigates to Puzzles list', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            // `CrosswordControlsMenu` uses Positioned.fill and expects to be
            // a child of a Stack. Mirror that here to avoid parent-data
            // errors in tests.
            body: Stack(children: [CrosswordControlsMenu(onClose: () {})]),
          ),
        ),
        GoRoute(
          path: '/puzzles',
          builder: (context, state) => const PuzzlesListPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();

    // Ensure the Home item exists and tap it.
    expect(find.text('Home'), findsOneWidget);
    await tester.tap(find.text('Home'));
    // Pump a few frames to allow navigation to complete without waiting
    // indefinitely for animations (BackdropFilter etc.).
    await tester.pump();
    for (var i = 0; i < 10 && find.text('Puzzles').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // After tapping Home we expect the Puzzles page to be visible.
    expect(find.text('Puzzles'), findsOneWidget);
  });
}
