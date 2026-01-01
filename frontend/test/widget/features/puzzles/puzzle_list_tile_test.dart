import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_card.dart';
import 'package:sizer/sizer.dart';

void main() {
  Widget buildTestWidget(Widget child) => ProviderScope(
    child: Sizer(
      builder:
          (context, orientation, deviceType) =>
              MaterialApp(home: Scaffold(body: child)),
    ),
  );

  testWidgets('shows difficulty badge properly', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        PuzzleCard(
          descriptor: PuzzleDescriptor(
            id: 'test-puzzle',
            title: 'Test Puzzle',
            path: 'test/puzzle.json',
            difficulty: 3,
            difficultyLabel: 'Hard',
          ),
        ),
      ),
    );

    expect(find.text('HARD'), findsOneWidget); // PuzzleCard uppercases label
  });

  testWidgets('shows progress indicator when puzzle is in progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        PuzzleCard(
          descriptor: PuzzleDescriptor(
            id: 'test-puzzle',
            title: 'Test Puzzle',
            path: 'test/puzzle.json',
          ),
          completionPercent: 50,
        ),
      ),
    );

    expect(find.text('50%'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows checkmark icon when puzzle is completed', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        PuzzleCard(
          descriptor: PuzzleDescriptor(
            id: 'test-puzzle',
            title: 'Test Puzzle',
            path: 'test/puzzle.json',
          ),
          isCompleted: true,
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('shows language and metadata', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        PuzzleCard(
          descriptor: PuzzleDescriptor(
            id: 'nyt2024-01-15',
            title: 'Monday, January 15',
            path: 'nytimes/2024/nyt2024-01-15.json',
            origin: 'nytimes',
            year: '2024',
            language: 'fr',
          ),
        ),
      ),
    );

    expect(find.textContaining('nytimes'), findsOneWidget);
    expect(find.textContaining('2024'), findsOneWidget);
    expect(find.textContaining('FR'), findsOneWidget);
  });
}
