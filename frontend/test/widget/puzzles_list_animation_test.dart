import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:croiz/features/generation/logic/generation_controller.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/filtered_puzzles_provider.dart';
import 'package:croiz/l10n/app_localizations.dart';

void main() {
  testWidgets('PuzzleList shows animation on items', (tester) async {
    // Setup
    SharedPreferences.setMockInitialValues({});

    final puzzle = PuzzleDescriptor(
      id: 'test1',
      title: 'Test Puzzle',
      path: 'test/path', // Required field
      difficulty: 1, // Use int instead of undefined enum
      language: 'en',
      // width and height not in PuzzleDescriptor constructor?
      // Let's check PuzzleDescriptor constructor again. It doesn't have width/height.
      // It has id, title, path. It doesn't have width/height.
      // createdAt is also not in PuzzleDescriptor.
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWith((ref) => [puzzle]),
          filteredPuzzlesProvider.overrideWith((ref) => [puzzle]),
          // pendingPuzzlesProvider uses default empty state, no override needed
          completedPuzzleIdsProvider.overrideWith((ref) => const {}),
          generationControllerProvider.overrideWith(
            GenerationController.new,
          ), // Simple override
        ],
        child: Sizer(
          builder:
              (context, orientation, deviceType) => const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: PuzzlesListPage(),
              ),
        ),
      ),
    );

    // Initial build - check that list exists
    expect(find.byType(SliverList), findsOneWidget);

    // Animate effects need time to run
    // Depending on flutter_animate configuration, it usually runs on built-in ticker
    // We can pump frames to simulate time passing

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400)); // Finish animation

    // Items should be fully visible now
    expect(find.text('Test Puzzle'), findsOneWidget);
  });
}
