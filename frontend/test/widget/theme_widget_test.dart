import 'package:croiz/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppTheme applies custom typography to widgets', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Scaffold(
          appBar: AppBar(title: const Text('Test')),
          body: const Column(
            children: [
              Text('Headline', style: TextStyle(fontSize: 24)),
              Text('Body text', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );

    // Verify the app builds without errors
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Headline'), findsOneWidget);
    expect(find.text('Body text'), findsOneWidget);

    // Verify theme is applied
    final BuildContext context = tester.element(find.text('Test'));
    final theme = Theme.of(context);

    expect(theme.useMaterial3, isTrue);
    expect(theme.textTheme.headlineLarge, isNotNull);
    expect(theme.textTheme.bodyMedium, isNotNull);
  });

  testWidgets('Dark theme applies custom typography to widgets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme(),
        home: Scaffold(
          appBar: AppBar(title: const Text('Dark Test')),
          body: const Text('Dark body'),
        ),
      ),
    );

    // Verify the app builds without errors
    expect(find.text('Dark Test'), findsOneWidget);
    expect(find.text('Dark body'), findsOneWidget);

    // Verify dark theme is applied
    final BuildContext context = tester.element(find.text('Dark Test'));
    final theme = Theme.of(context);

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, Colors.black);
    expect(theme.textTheme.headlineLarge, isNotNull);
  });
}
