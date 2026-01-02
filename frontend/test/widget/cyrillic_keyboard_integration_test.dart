import 'dart:async';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/features/game/services/game_persistence_service.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/core/responsive/responsive.dart';
import 'package:croiz/features/game/services/game_progress_service.dart';
import 'package:croiz/features/game/services/game_reveal_service.dart';
import 'package:croiz/features/game/services/game_endgame_service.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/features/game/providers/word_check_provider.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart'
    show PuzzleStorageInterface;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePuzzleStorage implements PuzzleStorageInterface {
  @override
  Future<List<String>> getAllKeys() async => [];

  @override
  Future<Map<String, dynamic>?> load(String id) async => null;

  @override
  Stream<void> get onDataChanged => const Stream.empty();

  @override
  Future<void> save(String id, Map<String, dynamic> payload) async {}
}

class FakeSelectedPuzzleIdNotifier extends SelectedPuzzleIdNotifier {
  FakeSelectedPuzzleIdNotifier(this._initId);
  final String _initId;

  @override
  String? build() => _initId;

  @override
  void setSelected(String? v) {
    state = v;
  }
}

void main() {
  SharedPreferences.setMockInitialValues({});

  final emptyBoard = GameBoard(
    id: 'test',
    title: 'Test',
    gridSize: 5,
    createdAt: DateTime.now(),
    grid: List.generate(5, (_) => List.filled(5, null)),
    clues: {},
    blackCells: List.generate(5, (_) => List.filled(5, false)),
    difficulty: 1,
    language: 'en',
  );

  Widget createSubject(GameBoard board) {
    // Instantiate mocks/fakes
    final storage = FakePuzzleStorage();
    final persistenceService = GamePersistenceService(storage: storage);
    final wordCheckService = WordCheckService();
    final progressService = GameProgressService(
      wordCheckService,
      storage: storage,
    );
    final revealService = GameRevealService(wordCheckService);
    final endgameService = GameEndgameService();

    // Create container with overrides
    final container = ProviderContainer(
      overrides: [
        // Override puzzleLoader to return our test board
        puzzleLoaderProvider.overrideWith((ref) => board),

        // Override services to avoid real side effects and ensure initialization
        gamePersistenceServiceProvider.overrideWithValue(persistenceService),
        gameProgressServiceProvider.overrideWithValue(progressService),
        gameRevealServiceProvider.overrideWithValue(revealService),
        gameEndgameServiceProvider.overrideWithValue(endgameService),
        wordCheckServiceProvider.overrideWithValue(wordCheckService),

        // Ensure we have a selected puzzle ID so the loader doesn't throw "No puzzle selected"
        selectedPuzzleIdProvider.overrideWith(
          () => FakeSelectedPuzzleIdNotifier(board.id),
        ),
      ],
    );

    addTearDown(container.dispose);

    return UncontrolledProviderScope(
      container: container,
      child: Sizer(
        builder:
            (context, orientation, deviceType) => MaterialApp(
              home: Scaffold(
                body: CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
              ),
            ),
      ),
    );
  }

  testWidgets('shows Ukrainian keyboard when language is "uk"', (tester) async {
    final ukBoard = emptyBoard.copyWith(language: 'uk');
    await tester.pumpWidget(createSubject(ukBoard));
    await tester.pumpAndSettle();

    expect(find.text('Ї'), findsOneWidget);
    expect(find.text('Є'), findsOneWidget);
    expect(find.text('Ґ'), findsOneWidget);

    expect(find.text('Q'), findsNothing);
    expect(find.text('W'), findsNothing);
  });

  testWidgets('shows Ukrainian keyboard when language is "ua"', (tester) async {
    final uaBoard = emptyBoard.copyWith(language: 'ua');
    await tester.pumpWidget(createSubject(uaBoard));
    await tester.pumpAndSettle();

    expect(find.text('Ї'), findsOneWidget);
  });

  testWidgets('shows Ukrainian keyboard when language is "ru"', (tester) async {
    final ruBoard = emptyBoard.copyWith(language: 'ru');
    await tester.pumpWidget(createSubject(ruBoard));
    await tester.pumpAndSettle();

    expect(find.text('Й'), findsOneWidget);
    expect(find.text('Ї'), findsOneWidget);
  });

  testWidgets('shows QWERTY/AZERTY when language is "en"', (tester) async {
    final enBoard = emptyBoard.copyWith(language: 'en');
    await tester.pumpWidget(createSubject(enBoard));
    await tester.pumpAndSettle();

    expect(find.text('Q'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);

    expect(find.text('Ї'), findsNothing);
  });
}
