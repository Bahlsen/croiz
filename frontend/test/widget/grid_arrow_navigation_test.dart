import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/main.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/widgets/crossword_grid.dart';

void main() {
  testWidgets('arrow right moves selection to next non-black cell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CroizApp()));
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    // Select first selectable cell
    final firstCell = find.byType(GestureDetector).first;
    await tester.tap(firstCell);
    await tester.pumpAndSettle();
    final gridContext = tester.element(find.byType(CrosswordGrid));
    final container = ProviderScope.containerOf(gridContext);
    final initial = container.read(selectedCellProvider);
    expect(initial, isNotNull);

    // Send arrow right key
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    final after = container.read(selectedCellProvider);

    // Ensure either column advanced or wrapped to different row/col
    expect(after, isNotNull);
    expect(!(after!.row == initial!.row && after.col == initial.col), isTrue);
  });
}
