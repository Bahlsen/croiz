import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/main.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/widgets/crossword_grid.dart';

void main() {
  testWidgets('tapping same cell toggles word direction', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CroizApp()));

    // Start game (navigate to crossword screen)
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    // Find a selectable cell (GestureDetector in grid)
    final cellFinder = find.byType(GestureDetector).first;
    await tester.tap(cellFinder);
    await tester.pumpAndSettle();

    // Access provider container via grid context
    final gridContext = tester.element(find.byType(CrosswordGrid));
    final container = ProviderScope.containerOf(gridContext);
    expect(container.read(wordDirectionProvider), WordDirection.horizontal);

    // Tap same cell again -> should toggle to vertical
    await tester.tap(cellFinder);
    await tester.pumpAndSettle();
    expect(container.read(wordDirectionProvider), WordDirection.vertical);
  });
}
