import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/screens/crossword_body.dart';
import 'package:croiz/features/game/widgets/layout/crossword_grid_area.dart';
import 'package:croiz/features/game/widgets/layout/crossword_controls_area.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

/// Integration test that verifies the layout does not have overlapping widgets.
///
/// This test renders the ACTUAL CrosswordBody (as used in production) and
/// measures the pixel positions of key widgets to ensure they do not overlap.
void main() {
  group('Layout Overlap Integration Tests', () {
    GameBoard createBoard({required int gridSize}) => GameBoard(
      id: 'test',
      title: 'Test Board $gridSize x $gridSize',
      gridSize: gridSize,
      createdAt: DateTime(2025, 1, 1),
      grid: List.generate(
        gridSize,
        (_) => List.generate(gridSize, (_) => null),
      ),
      clues: const {'1-across': 'Test clue for testing layout'},
      blackCells: List.generate(
        gridSize,
        (_) => List.generate(gridSize, (_) => false),
      ),
      difficulty: 1,
      entries: [
        PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 0,
          y: 0,
          length: gridSize,
          clue: 'Test clue for testing layout',
        ),
      ],
    );

    Future<void> pumpLayout(
      WidgetTester tester, {
      required Size screenSize,
      required ProviderContainer container,
      double topPadding = 44, // Status bar + notch
      double bottomPadding = 34, // Home indicator
    }) async {
      final controller = CrosswordInputController.fromContainer(container);

      // Set the physical size for the test view (required for Sizer)
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Sizer(
            builder:
                (context, orientation, deviceType) => MaterialApp(
                  home: MediaQuery(
                    data: MediaQueryData(
                      size: screenSize,
                      padding: EdgeInsets.only(
                        top: topPadding,
                        bottom: bottomPadding,
                      ),
                    ),
                    // Use the ACTUAL CrosswordBody as in production
                    child: CrosswordBody(controller: controller),
                  ),
                ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('CRITICAL: Grid and controls do NOT overlap on real phone size', (
      tester,
    ) async {
      // Use a realistic phone size (iPhone 8)
      const screenSize = Size(375, 667);
      final board = createBoard(gridSize: 7);
      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);

      await pumpLayout(tester, screenSize: screenSize, container: container);

      // Get actual pixel positions
      final gridAreaRect = tester.getRect(find.byType(CrosswordGridArea));
      final controlsAreaRect = tester.getRect(
        find.byType(CrosswordControlsArea),
      );

      // Debug output
      debugPrint('Screen size: $screenSize');
      debugPrint('Grid area: $gridAreaRect');
      debugPrint('Controls area: $controlsAreaRect');
      debugPrint('Grid bottom: ${gridAreaRect.bottom}');
      debugPrint('Controls top: ${controlsAreaRect.top}');
      debugPrint(
        'Overlap: ${gridAreaRect.bottom - controlsAreaRect.top} pixels',
      );

      // CRITICAL ASSERTION: Grid bottom must be <= controls top
      expect(
        gridAreaRect.bottom,
        lessThanOrEqualTo(controlsAreaRect.top + 1), // +1 for divider
        reason:
            'Grid bottom (${gridAreaRect.bottom}) overlaps controls top (${controlsAreaRect.top})',
      );

      // Verify both are visible (positive dimensions)
      expect(
        gridAreaRect.height,
        greaterThan(50),
        reason: 'Grid must have visible height',
      );
      expect(
        controlsAreaRect.height,
        greaterThan(50),
        reason: 'Controls must have visible height',
      );

      // Verify grid is within screen bounds
      expect(gridAreaRect.left, greaterThanOrEqualTo(0));
      expect(gridAreaRect.top, greaterThanOrEqualTo(0));
      expect(gridAreaRect.right, lessThanOrEqualTo(screenSize.width));
      expect(gridAreaRect.bottom, lessThanOrEqualTo(screenSize.height));
    });

    testWidgets('CRITICAL: CrosswordGrid fits within CrosswordGridArea', (
      tester,
    ) async {
      const screenSize = Size(375, 667);
      final board = createBoard(gridSize: 7);
      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);

      await pumpLayout(tester, screenSize: screenSize, container: container);

      final gridAreaRect = tester.getRect(find.byType(CrosswordGridArea));
      final gridRect = tester.getRect(find.byType(CrosswordGrid));

      debugPrint('GridArea: $gridAreaRect');
      debugPrint('Grid: $gridRect');

      // Grid must be completely within GridArea
      expect(
        gridRect.left,
        greaterThanOrEqualTo(gridAreaRect.left - 1),
        reason: 'Grid left edge outside GridArea',
      );
      expect(
        gridRect.top,
        greaterThanOrEqualTo(gridAreaRect.top - 1),
        reason: 'Grid top edge outside GridArea',
      );
      expect(
        gridRect.right,
        lessThanOrEqualTo(gridAreaRect.right + 1),
        reason: 'Grid right edge outside GridArea',
      );
      expect(
        gridRect.bottom,
        lessThanOrEqualTo(gridAreaRect.bottom + 1),
        reason: 'Grid bottom edge outside GridArea',
      );
    });

    testWidgets(
      'CRITICAL: No overflow errors on small screen with large grid',
      (tester) async {
        // Small screen + large grid = most likely to overflow
        const screenSize = Size(320, 568);
        final board = createBoard(gridSize: 15);
        final container = ProviderContainer(
          overrides: [
            puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          ],
        );
        addTearDown(container.dispose);

        // This will throw if there's an overflow
        await pumpLayout(tester, screenSize: screenSize, container: container);

        final gridAreaRect = tester.getRect(find.byType(CrosswordGridArea));
        final controlsAreaRect = tester.getRect(
          find.byType(CrosswordControlsArea),
        );
        final gridRect = tester.getRect(find.byType(CrosswordGrid));

        debugPrint('=== Small screen + large grid ===');
        debugPrint('Screen: $screenSize');
        debugPrint('GridArea: $gridAreaRect');
        debugPrint('Grid: $gridRect');
        debugPrint('Controls: $controlsAreaRect');

        // No overlap
        expect(
          gridAreaRect.bottom,
          lessThanOrEqualTo(controlsAreaRect.top + 1),
          reason: 'Grid overlaps controls on small screen',
        );

        // Grid fits in GridArea
        expect(
          gridRect.bottom,
          lessThanOrEqualTo(gridAreaRect.bottom + 1),
          reason: 'Grid overflows GridArea on small screen',
        );
      },
    );

    testWidgets('Layout percentages are reasonable', (tester) async {
      const screenSize = Size(375, 667);
      final board = createBoard(gridSize: 7);
      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);

      await pumpLayout(tester, screenSize: screenSize, container: container);

      final gridAreaRect = tester.getRect(find.byType(CrosswordGridArea));
      final controlsAreaRect = tester.getRect(
        find.byType(CrosswordControlsArea),
      );

      final gridPercent = gridAreaRect.height / screenSize.height * 100;
      final controlsPercent = controlsAreaRect.height / screenSize.height * 100;
      final totalPercent = gridPercent + controlsPercent;

      debugPrint('Grid: ${gridPercent.toStringAsFixed(1)}% of screen');
      debugPrint('Controls: ${controlsPercent.toStringAsFixed(1)}% of screen');
      debugPrint('Total: ${totalPercent.toStringAsFixed(1)}%');

      // Controls should not take more than 55% of the screen
      expect(
        controlsPercent,
        lessThan(55),
        reason:
            'Controls take too much space: ${controlsPercent.toStringAsFixed(1)}%',
      );

      // Grid should have at least 30% of the screen (reduced from 35/40% to
      // accommodate larger premium clue banner)
      expect(
        gridPercent,
        greaterThan(30),
        reason: 'Grid has too little space: ${gridPercent.toStringAsFixed(1)}%',
      );
    });
  });
}
