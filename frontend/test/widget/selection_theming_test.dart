import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/core/theme.dart';

void main() {
  testWidgets(
    'light theme: selected border and selected-word bg are yellow-ish',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: Builder(
            builder: (context) {
              final ext = Theme.of(context).extension<CrosswordThemeColors>()!;
              // Expected values per design: orange border + yellow overlay
              expect(ext.selectedBorderColor, equals(const Color(0xFFFF9800)));
              expect(
                ext.selectedWordBgColor,
                equals(const Color.fromRGBO(255, 235, 59, 0.42)),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    },
  );

  testWidgets('dark theme: selected border remains purple', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme(),
        home: Builder(
          builder: (context) {
            final ext = Theme.of(context).extension<CrosswordThemeColors>()!;
            expect(
              ext.selectedBorderColor,
              equals(const Color.fromARGB(255, 110, 32, 124)),
            );
            // Dark selectedWordBgColor remains blue overlay per existing design
            expect(
              ext.selectedWordBgColor,
              equals(const Color.fromRGBO(33, 150, 243, 0.42)),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}
