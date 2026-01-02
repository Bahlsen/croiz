import 'package:croiz/features/generation/data/generated_puzzles_repository.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class MockGeneratedPuzzlesRepository extends Mock
    implements GeneratedPuzzlesRepository {}

void main() {
  late MockGeneratedPuzzlesRepository mockRepo;

  setUp(() {
    mockRepo = MockGeneratedPuzzlesRepository();
    when(() => mockRepo.deletePuzzle(any())).thenAnswer((_) async {});
  });

  Widget createSubject(PuzzleDescriptor descriptor) => ProviderScope(
    overrides: [generatedPuzzlesRepositoryProvider.overrideWithValue(mockRepo)],
    child: Sizer(
      builder:
          (context, orientation, deviceType) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Scaffold(body: PuzzleCard(descriptor: descriptor)),
          ),
    ),
  );

  testWidgets(
    'Long press on local puzzle shows delete dialog and deletes on confirm',
    (tester) async {
      final localPuzzle = PuzzleDescriptor(
        id: 'local-1',
        title: 'My Puzzle',
        path: 'local-1',
        source: PuzzleSource.local,
        origin: 'generated',
      );

      await tester.pumpWidget(createSubject(localPuzzle));

      // Long press
      await tester.longPress(find.text('My Puzzle'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Delete Generated Puzzle'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete this puzzle? This action cannot be undone.',
        ),
        findsOneWidget,
      );

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      verifyNever(() => mockRepo.deletePuzzle(any()));

      // Long press again
      await tester.longPress(find.text('My Puzzle'));
      await tester.pumpAndSettle();

      // Confirm delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle(); // Wait for dialog to close

      // Allow for async provider calls
      await tester.runAsync(() async {
        // Small delay to ensure the controller's async method executes
        await Future.delayed(const Duration(milliseconds: 100));
      });

      verify(() => mockRepo.deletePuzzle('local-1')).called(1);
    },
  );

  testWidgets('Long press on asset puzzle does NOT show delete dialog', (
    tester,
  ) async {
    final assetPuzzle = PuzzleDescriptor(
      id: 'asset-1',
      title: 'Official Puzzle',
      path: 'assets/puzzles/1.json',
      source: PuzzleSource.asset,
    );

    await tester.pumpWidget(createSubject(assetPuzzle));

    // Verify InkWell has no long press handler
    final inkWellFinder = find.descendant(
      of: find.byType(PuzzleCard),
      matching: find.byType(InkWell),
    );
    final inkWell = tester.widget<InkWell>(inkWellFinder.first);
    expect(inkWell.onLongPress, isNull);

    // Also assert dialog is not present just in case
    expect(find.text('Delete Generated Puzzle'), findsNothing);
  });
}
