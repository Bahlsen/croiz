import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/routes/app_router.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Puzzles list metadata error still navigates', () {
    testWidgets('error in metadata provider does not block navigation', (
      WidgetTester tester,
    ) async {
      // Descriptor with title equal to token to trigger metadata load path.
      final desc = PuzzleDescriptor(
        id: 'test-err-0001',
        title: 'test-err-0001',
        path: 'testorigin/2020/test-err-0001.json',
        subtitle: '',
        origin: 'testorigin',
        year: '2020',
      );

      final container = ProviderContainer(
        overrides: [
          puzzlesProvider.overrideWithValue(
            AsyncValue.data(<PuzzleDescriptor>[desc]),
          ),
          // Force metadata provider to throw to hit error branch in UI.
          puzzleMetadataProvider.overrideWith((Ref ref, String path) async {
            throw StateError('metadata load failed');
          }),
          // Loader returns a valid board when navigated.
          puzzleAssetLoaderProvider.overrideWithValue(
            (String assetPath) async => GameBoard(
              id: 'test-err-0001',
              title: 'Sample Puzzle',
              gridSize: 3,
              createdAt: DateTime.now(),
              grid: List.generate(3, (_) => List<String?>.filled(3, null)),
              clues: <String, String>{},
              blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
              difficulty: 1,
              entries: const <PuzzleEntryData>[],
              solutionGrid: List.generate(
                3,
                (_) => List<String?>.filled(3, null),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Sizer(
            builder: (context, orientation, deviceType) => MaterialApp.router(
              routerConfig: appRouter,
            ),
          ),
        ),
      );

      // Go to puzzles list and expand origin/year.
      appRouter.go('/puzzles');
      await tester.pumpAndSettle();
      await tester.tap(find.text('testorigin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2020'));
      await tester.pumpAndSettle();

      // Tap the error tile (will show error subtitle but still navigates).
      expect(find.text('Error loading metadata'), findsOneWidget);
      final titleText = find.text('test-err-0001');
      final tileFinder = find.ancestor(
        of: titleText,
        matching: find.byType(ListTile),
      );
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      // Verify selection changed; then optionally navigate.
      final selected = container.read(selectedPuzzleIdProvider);
      expect(selected, 'test-err-0001');
    });
  });
}
