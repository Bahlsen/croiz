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
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Seed a simple 3x3 board with all selectable cells
      container.read(gameBoardProvider.notifier).state = GameBoard(
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
      container.read(selectedCellProvider.notifier).state = const SelectedCell(0, 0);
      container.read(wordDirectionProvider.notifier).state = WordDirection.horizontal;

      // Act
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CrosswordClueBanner(),
            ),
          ),
        ),
      );

      // Assert: text contains only number and clue and is centered
      expect(find.textContaining('1  Lundi'), findsOneWidget);
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('renders nothing when no selection', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(gameBoardProvider.notifier).state = GameBoard(
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
      container.read(selectedCellProvider.notifier).state = null;

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: Scaffold(body: CrosswordClueBanner()),
          ),
        ),
      );

      expect(find.byType(Center), findsNothing);
    });
  });
}