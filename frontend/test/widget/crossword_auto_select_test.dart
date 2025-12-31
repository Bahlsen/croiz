import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets(
    'auto-selects first cell of first across on game start (widget)',
    (tester) async {
      final board = GameBoard(
        id: 'init-select',
        title: 'Init Select',
        gridSize: 5,
        createdAt: DateTime.now(),
        grid: List<List<String?>>.generate(
          5,
          (_) => List<String?>.filled(5, null),
        ),
        clues: const {},
        blackCells: List<List<bool>>.generate(
          5,
          (_) => List<bool>.filled(5, false),
        ),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          ],
          child: Sizer(
            builder: (context, orientation, deviceType) => MaterialApp(
              home: Builder(
                builder: (context) => Column(
                  children: [
                    const Expanded(child: CrosswordScreen()),
                    Consumer(
                      builder: (context, ref, _) {
                        final sel = ref.watch(selectedCellProvider);
                        if (sel == null) {
                          return const Text('sel:none', key: Key('sel'));
                        }
                        return Text(
                          'sel:${sel.row},${sel.col}',
                          key: const Key('sel'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Allow any microtasks / listeners to run.
      await tester.pumpAndSettle();

      expect(find.text('sel:0,0'), findsOneWidget);
    },
  );
}
