import 'package:croiz/features/game/widgets/bottom/crossword_clue_header.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sizer/sizer.dart';
import 'clue_banner_container_test.dart'; // for extractTextFromSpan

void main() {
  group('CrosswordClueHeader', () {
    testWidgets('tapping banner toggles direction and updates clue', (
      tester,
    ) async {
      // Board with both across and down at same start
      final board = GameBoard(
        id: 'toggle',
        title: 'Toggle Board',
        gridSize: 3,
        createdAt: DateTime(2025, 1, 1),
        grid: List.generate(3, (_) => List.generate(3, (_) => null)),
        clues: const {'1-across': 'Across clue', '1-down': 'Down clue'},
        blackCells: List.generate(3, (_) => List.generate(3, (_) => false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            clue: 'Across clue',
          ),
          PuzzleEntryData(
            number: 1,
            direction: 'down',
            x: 0,
            y: 0,
            length: 3,
            clue: 'Down clue',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);
      // Ensure gameBoardProvider is initialized before making selections
      container.read(gameBoardProvider);
      await Future.microtask(() {});
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(0, 0));
      container
          .read(wordDirectionProvider.notifier)
          .setDirection(WordDirection.horizontal);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Sizer(
            builder:
                (context, orientation, deviceType) => const MaterialApp(
                  home: Scaffold(body: CrosswordClueHeader()),
                ),
          ),
        ),
      );

      // Separate expectations for number/direction and clue
      expect(find.text('1'), findsOneWidget);
      expect(find.text('ACROSS'), findsOneWidget);

      final clueTextFinder = find.byKey(const Key('clue_text'));
      final richTextFinder = find.descendant(
        of: clueTextFinder,
        matching: find.byType(RichText),
      );
      final richText = tester.widget<RichText>(richTextFinder);
      expect(extractTextFromSpan(richText.text), equals('Across clue'));

      // Tap on the ClueBannerContainer (which has the GestureDetector)
      await tester.tap(find.byType(ClueBannerContainer));
      await tester.pump();

      expect(container.read(wordDirectionProvider), WordDirection.vertical);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('DOWN'), findsOneWidget);

      final richText2Finder = find.descendant(
        of: find.byKey(const Key('clue_text')),
        matching: find.byType(RichText),
      );
      final richText2 = tester.widget<RichText>(richText2Finder);
      expect(extractTextFromSpan(richText2.text), equals('Down clue'));
    });
    testWidgets('shows only entry number and clue, centered', (tester) async {
      // Arrange minimal board state with one entry and selection
      // Seed a simple 3x3 board with all selectable cells
      final board = GameBoard(
        id: 'test',
        title: 'Test Board',
        gridSize: 3,
        createdAt: DateTime(2025, 1, 1),
        grid: List.generate(3, (_) => List.generate(3, (_) => '' as String?)),
        clues: const {},
        blackCells: List.generate(3, (_) => List.generate(3, (_) => false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            clue: 'Lundi',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);
      // Ensure gameBoardProvider is initialized before making selections
      container.read(gameBoardProvider);
      await Future.microtask(() {});
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(0, 0));
      container
          .read(wordDirectionProvider.notifier)
          .setDirection(WordDirection.horizontal);

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Sizer(
            builder:
                (context, orientation, deviceType) => const MaterialApp(
                  home: Scaffold(body: CrosswordClueHeader()),
                ),
          ),
        ),
      );

      // Assert: banner text contains clue
      expect(find.text('1'), findsOneWidget);
      final richTextFinder = find.descendant(
        of: find.byKey(const Key('clue_text')),
        matching: find.byType(RichText),
      );
      final richText = tester.widget<RichText>(richTextFinder);
      expect(extractTextFromSpan(richText.text), equals('Lundi'));
      // Arrows should be present
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders nothing when no selection', (tester) async {
      final board = GameBoard(
        id: 'test2',
        title: 'Empty',
        gridSize: 3,
        createdAt: DateTime(2025, 1, 2),
        grid: List.generate(3, (_) => List.generate(3, (_) => '' as String?)),
        clues: const {},
        blackCells: List.generate(3, (_) => List.generate(3, (_) => false)),
        difficulty: 1,
        entries: const [],
      );
      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);
      container.read(selectedCellProvider.notifier).select(null);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Sizer(
            builder:
                (context, orientation, deviceType) => const MaterialApp(
                  home: Scaffold(body: CrosswordClueHeader()),
                ),
          ),
        ),
      );

      expect(find.byType(Center), findsNothing);
    });

    testWidgets('left/right arrows navigate to previous/next word', (
      tester,
    ) async {
      // Two across entries and one down, ensure ordering by number then direction.
      final board = GameBoard(
        id: 'nav',
        title: 'Nav Board',
        gridSize: 3,
        createdAt: DateTime(2025, 1, 3),
        grid: List.generate(3, (_) => List.generate(3, (_) => '' as String?)),
        clues: const {},
        blackCells: List.generate(3, (_) => List.generate(3, (_) => false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            clue: 'First across',
          ),
          PuzzleEntryData(
            number: 2,
            direction: 'down',
            x: 2,
            y: 0,
            length: 3,
            clue: 'Second down',
          ),
          PuzzleEntryData(
            number: 3,
            direction: 'across',
            x: 0,
            y: 2,
            length: 3,
            clue: 'Third across',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(0, 0));
      container
          .read(wordDirectionProvider.notifier)
          .setDirection(WordDirection.horizontal);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Sizer(
            builder:
                (context, orientation, deviceType) => const MaterialApp(
                  home: Scaffold(body: CrosswordClueHeader()),
                ),
          ),
        ),
      );

      // Tap right arrow → should go to next across (entry #3) at (y=2,x=0)
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      final sel1 = container.read(selectedCellProvider);
      final dir1 = container.read(wordDirectionProvider);
      expect(sel1?.row, 2);
      expect(sel1?.col, 0);
      expect(dir1, WordDirection.horizontal);

      // Tap right arrow again → should wrap to first down (entry #2) at (y=0,x=2)
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      final sel2 = container.read(selectedCellProvider);
      final dir2 = container.read(wordDirectionProvider);
      expect(sel2?.row, 0);
      expect(sel2?.col, 2);
      expect(dir2, WordDirection.vertical);

      // Tap left arrow → back to entry #3 (across)
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      final sel3 = container.read(selectedCellProvider);
      final dir3 = container.read(wordDirectionProvider);
      expect(sel3?.row, 2);
      expect(sel3?.col, 0);
      expect(dir3, WordDirection.horizontal);
    });
  });
}
