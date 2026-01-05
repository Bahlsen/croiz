import 'package:alchemist/alchemist.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/core/config/app_languages.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('PuzzleCard Golden Tests', () {
    final descriptor = PuzzleDescriptor(
      id: 'test-puzzle-1',
      title: 'Daily Crossword',
      path: 'puzzles/daily.json',
      difficulty: 3,
      difficultyLabel: 'Hard',
      language: 'en',
    );

    Widget buildTestWrapper(Widget child) => Sizer(
      builder:
          (context, orientation, deviceType) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLanguages.uiLocales,
            home: Material(child: child),
            debugShowCheckedModeBanner: false,
          ),
    );

    goldenTest(
      'renders correctly in different states',
      fileName: 'puzzle_card',
      builder:
          () => GoldenTestGroup(
            children: [
              GoldenTestScenario(
                name: 'Default State',
                child: ProviderScope(
                  child: buildTestWrapper(
                    SizedBox(
                      width: 300,
                      child: PuzzleCard(descriptor: descriptor),
                    ),
                  ),
                ),
              ),
              GoldenTestScenario(
                name: 'Completed State',
                child: ProviderScope(
                  child: buildTestWrapper(
                    SizedBox(
                      width: 300,
                      child: PuzzleCard(
                        descriptor: descriptor,
                        isCompleted: true,
                        completionPercent: 100,
                      ),
                    ),
                  ),
                ),
              ),
              GoldenTestScenario(
                name: 'Pending State',
                child: ProviderScope(
                  child: buildTestWrapper(
                    SizedBox(
                      width: 300,
                      child: PuzzleCard(
                        descriptor: descriptor,
                        isPending: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  });
}
