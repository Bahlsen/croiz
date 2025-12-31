import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/widgets/content/crossword_content.dart';
import 'package:croiz/features/game/widgets/layout/crossword_grid_area.dart';
import 'package:croiz/features/game/widgets/layout/crossword_controls_area.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

/// Test suite for layout behavior across different screen sizes and grid sizes.
///
/// These tests verify that:
/// 1. Grid and controls never overlap
/// 2. Layout adapts to different screen sizes
/// 3. Different grid sizes are handled correctly
/// 4. All elements remain visible and accessible
void main() {
  group('CrosswordContent Layout Tests', () {
    // Helper to create a GameBoard with specific grid size
    GameBoard createBoard({
      required int gridSize,
      String id = 'test',
    }) =>
        GameBoard(
        id: id,
        title: 'Test Board $gridSize x $gridSize',
        gridSize: gridSize,
        createdAt: DateTime(2025, 1, 1),
        grid: List.generate(
          gridSize,
          (_) => List.generate(gridSize, (_) => null),
        ),
        clues: const {'1-across': 'Test clue'},
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
            clue: 'Test clue',
          ),
        ],
      );

    // Helper to pump a CrosswordContent with specific screen size
    Future<void> pumpWithScreenSize(
      WidgetTester tester, {
      required Size screenSize,
      required ProviderContainer container,
    }) async {
      final controller = CrosswordInputController.fromContainer(container);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Sizer(
            builder: (context, orientation, deviceType) => MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(size: screenSize),
                child: Scaffold(
                  body: SizedBox(
                    width: screenSize.width,
                    height: screenSize.height,
                    child: CrosswordContent(controller: controller),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    group('Screen Size Adaptability', () {
      testWidgets(
        'layout works on small phone (320x568 - iPhone SE 1st gen)',
        (tester) async {
          const screenSize = Size(320, 568);
          final board = createBoard(gridSize: 5);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          // Verify both areas are present
          expect(find.byType(CrosswordGridArea), findsOneWidget);
          expect(find.byType(CrosswordControlsArea), findsOneWidget);

          // Get bounding boxes
          final gridBox = tester.getRect(find.byType(CrosswordGridArea));
          final controlsBox = tester.getRect(find.byType(CrosswordControlsArea));

          // Verify no overlap: grid bottom should be <= controls top
          expect(
            gridBox.bottom,
            lessThanOrEqualTo(controlsBox.top + 1), // +1 for divider
            reason: 'Grid should not overlap with controls',
          );

          // Both should be visible (positive height)
          expect(gridBox.height, greaterThan(0));
          expect(controlsBox.height, greaterThan(0));
        },
      );

      testWidgets(
        'layout works on medium phone (375x667 - iPhone 8)',
        (tester) async {
          const screenSize = Size(375, 667);
          final board = createBoard(gridSize: 7);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          final gridBox = tester.getRect(find.byType(CrosswordGridArea));
          final controlsBox = tester.getRect(find.byType(CrosswordControlsArea));

          // No overlap
          expect(
            gridBox.bottom,
            lessThanOrEqualTo(controlsBox.top + 1),
            reason: 'Grid should not overlap with controls on medium phone',
          );

          // Both visible
          expect(gridBox.height, greaterThan(0));
          expect(controlsBox.height, greaterThan(0));
        },
      );

      testWidgets(
        'layout works on large phone (414x896 - iPhone XS Max)',
        (tester) async {
          const screenSize = Size(414, 896);
          final board = createBoard(gridSize: 10);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          final gridBox = tester.getRect(find.byType(CrosswordGridArea));
          final controlsBox = tester.getRect(find.byType(CrosswordControlsArea));

          // No overlap
          expect(
            gridBox.bottom,
            lessThanOrEqualTo(controlsBox.top + 1),
            reason: 'Grid should not overlap with controls on large phone',
          );

          // Both visible with reasonable sizes
          expect(gridBox.height, greaterThan(100));
          expect(controlsBox.height, greaterThan(100));
        },
      );

      testWidgets(
        'layout works on tablet (768x1024 - iPad)',
        (tester) async {
          const screenSize = Size(768, 1024);
          final board = createBoard(gridSize: 15);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          final gridBox = tester.getRect(find.byType(CrosswordGridArea));
          final controlsBox = tester.getRect(find.byType(CrosswordControlsArea));

          // No overlap
          expect(
            gridBox.bottom,
            lessThanOrEqualTo(controlsBox.top + 1),
            reason: 'Grid should not overlap with controls on tablet',
          );

          // Both visible
          expect(gridBox.height, greaterThan(0));
          expect(controlsBox.height, greaterThan(0));
        },
      );
    });

    group('Grid Size Adaptability', () {
      testWidgets(
        'small grid (3x3) does not cause layout issues',
        (tester) async {
          const screenSize = Size(375, 667);
          final board = createBoard(gridSize: 3);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          final gridBox = tester.getRect(find.byType(CrosswordGridArea));
          final controlsBox = tester.getRect(find.byType(CrosswordControlsArea));

          // No overlap
          expect(
            gridBox.bottom,
            lessThanOrEqualTo(controlsBox.top + 1),
            reason: 'Small grid should not overlap with controls',
          );

          // Grid should still have reasonable size
          expect(gridBox.height, greaterThan(50));
        },
      );

      testWidgets(
        'medium grid (7x7) layout is balanced',
        (tester) async {
          const screenSize = Size(375, 667);
          final board = createBoard(gridSize: 7);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          final gridBox = tester.getRect(find.byType(CrosswordGridArea));
          final controlsBox = tester.getRect(find.byType(CrosswordControlsArea));

          // No overlap
          expect(
            gridBox.bottom,
            lessThanOrEqualTo(controlsBox.top + 1),
            reason: 'Medium grid should not overlap with controls',
          );

          // Both should have substantial height
          expect(gridBox.height, greaterThan(100));
          expect(controlsBox.height, greaterThan(100));
        },
      );

      testWidgets(
        'large grid (15x15) still shows controls',
        (tester) async {
          const screenSize = Size(375, 667);
          final board = createBoard(gridSize: 15);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          final gridBox = tester.getRect(find.byType(CrosswordGridArea));
          final controlsBox = tester.getRect(find.byType(CrosswordControlsArea));

          // No overlap
          expect(
            gridBox.bottom,
            lessThanOrEqualTo(controlsBox.top + 1),
            reason: 'Large grid should not overlap with controls',
          );

          // Controls should still be visible
          expect(
            controlsBox.height,
            greaterThan(50),
            reason: 'Controls should remain visible with large grid',
          );
        },
      );

      testWidgets(
        'extra large grid (21x21) on small screen still shows controls',
        (tester) async {
          const screenSize = Size(320, 568);
          final board = createBoard(gridSize: 21);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          final gridBox = tester.getRect(find.byType(CrosswordGridArea));
          final controlsBox = tester.getRect(find.byType(CrosswordControlsArea));

          // No overlap - this is the critical test
          expect(
            gridBox.bottom,
            lessThanOrEqualTo(controlsBox.top + 1),
            reason: 'Extra large grid on small screen should not overlap',
          );

          // Controls must be visible
          expect(
            controlsBox.height,
            greaterThan(0),
            reason: 'Controls must be visible even with very large grid',
          );
        },
      );
    });

    group('Layout Constraints Validation', () {
      testWidgets(
        'grid area uses Expanded correctly',
        (tester) async {
          const screenSize = Size(375, 667);
          final board = createBoard(gridSize: 5);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          // Verify Expanded is used for grid area
          final expanded = tester.widget<Expanded>(
            find.ancestor(
              of: find.byType(CrosswordGridArea),
              matching: find.byType(Expanded),
            ),
          );
          expect(expanded, isNotNull);
        },
      );

      testWidgets(
        'controls area has intrinsic sizing (MainAxisSize.min)',
        (tester) async {
          const screenSize = Size(375, 667);
          final board = createBoard(gridSize: 5);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          // Controls should be present and sized based on content
          final controlsArea = find.byType(CrosswordControlsArea);
          expect(controlsArea, findsOneWidget);

          // The controls area should have positive height
          final controlsBox = tester.getRect(controlsArea);
          expect(controlsBox.height, greaterThan(0));
        },
      );

      testWidgets(
        'divider is present between grid and controls',
        (tester) async {
          const screenSize = Size(375, 667);
          final board = createBoard(gridSize: 5);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          // Verify divider exists
          expect(find.byType(Divider), findsOneWidget);
        },
      );
    });

    group('Landscape Orientation', () {
      testWidgets(
        'layout works in landscape mode on phone',
        (tester) async {
          // Landscape dimensions for a typical phone
          const screenSize = Size(667, 375);
          final board = createBoard(gridSize: 7);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          final gridBox = tester.getRect(find.byType(CrosswordGridArea));
          final controlsBox = tester.getRect(find.byType(CrosswordControlsArea));

          // No overlap in landscape
          expect(
            gridBox.bottom,
            lessThanOrEqualTo(controlsBox.top + 1),
            reason: 'Grid should not overlap controls in landscape',
          );

          // Both should be visible
          expect(gridBox.height, greaterThan(0));
          expect(controlsBox.height, greaterThan(0));
        },
      );

      testWidgets(
        'layout works in landscape mode on tablet',
        (tester) async {
          // Landscape dimensions for iPad
          const screenSize = Size(1024, 768);
          final board = createBoard(gridSize: 15);
          final container = ProviderContainer(
            overrides: [
              puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            ],
          );
          addTearDown(container.dispose);

          await pumpWithScreenSize(
            tester,
            screenSize: screenSize,
            container: container,
          );

          final gridBox = tester.getRect(find.byType(CrosswordGridArea));
          final controlsBox = tester.getRect(find.byType(CrosswordControlsArea));

          // No overlap
          expect(
            gridBox.bottom,
            lessThanOrEqualTo(controlsBox.top + 1),
            reason: 'Grid should not overlap controls on tablet landscape',
          );
        },
      );
    });
  });
}
