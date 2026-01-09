import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import '../helpers/test_helpers.dart';
import '../helpers/fake_audio_service.dart';

class FakeAudioMutedNotifier extends AudioMutedNotifier {
  FakeAudioMutedNotifier({required this.initialValue});

  final bool initialValue;

  @override
  bool build() => initialValue;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('revealLetterAt should play reveal sound', () async {
    final board = GameBoard(
      id: 't',
      title: 't',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: [
        [null, null, null],
        [null, null, null],
        [null, null, null],
      ],
      clues: {},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 1,
      entries: const [],
      solutionGrid: [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final fakeAudio = FakeAudioService();

    final container = createTestContainer(
      audioService: fakeAudio,
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        gameAudioMutedProvider.overrideWith(
          () => FakeAudioMutedNotifier(initialValue: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Call revealLetterAt
    container.read(gameBoardProvider.notifier).revealLetterAt(0, 0);

    // Verify
    expect(fakeAudio.revealCount, equals(1));
  });

  test('revealLetterAt should NOT play reveal sound if muted', () async {
    final board = GameBoard(
      id: 't',
      title: 't',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: [
        [null, null, null],
        [null, null, null],
        [null, null, null],
      ],
      clues: {},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 1,
      entries: const [],
      solutionGrid: [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final fakeAudio = FakeAudioService();

    final container = createTestContainer(
      audioService: fakeAudio,
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        gameAudioMutedProvider.overrideWith(
          () => FakeAudioMutedNotifier(initialValue: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Call revealLetterAt
    container.read(gameBoardProvider.notifier).revealLetterAt(0, 0);

    // Verify
    expect(fakeAudio.revealCount, equals(0));
  });
}
