import 'package:croiz/features/game/widgets/crossword_clues_banner.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrosswordClueBanner', () {
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
          )
        ],
      );
      final container = ProviderContainer(
        overrides: [
          gameBoardProvider.overrideWith((ref) => GameBoardNotifier(board)),
        ],
      );
      addTearDown(container.dispose);
      container.read(selectedCellProvider.notifier).state = const SelectedCell(0, 0);
      container.read(wordDirectionProvider.notifier).state = WordDirection.horizontal;

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CrosswordClueBanner(),
            ),
          ),
        ),
      );

      // Assert: banner text is centered and contains clue
        final textFinder = find.byWidgetPredicate((w) =>
          w is Text && w.style?.fontWeight == FontWeight.w600);
        expect(textFinder, findsOneWidget);
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.textAlign, TextAlign.center);
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
          gameBoardProvider.overrideWith((ref) => GameBoardNotifier(board)),
        ],
      );
      addTearDown(container.dispose);
      container.read(selectedCellProvider.notifier).state = null;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: CrosswordClueBanner()),
          ),
        ),
      );

      expect(find.byType(Center), findsNothing);
    });

    testWidgets('left/right arrows navigate to previous/next word',
        (tester) async {
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
          gameBoardProvider.overrideWith((ref) => GameBoardNotifier(board)),
        ],
      );
      addTearDown(container.dispose);
      container.read(selectedCellProvider.notifier).state = const SelectedCell(0, 0);
      container.read(wordDirectionProvider.notifier).state = WordDirection.horizontal;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: CrosswordClueBanner()),
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
