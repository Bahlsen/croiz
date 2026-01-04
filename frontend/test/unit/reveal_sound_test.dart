import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/services/game_audio_service.dart';

class MockGameAudioService extends Mock implements GameAudioService {
  int playRevealCallCount = 0;

  @override
  Future<void> playReveal() async {
    playRevealCallCount++;
  }
}

class FakeAudioMutedNotifier extends AudioMutedNotifier {
  FakeAudioMutedNotifier({required this.initialValue});

  final bool initialValue;

  @override
  bool build() => initialValue;
}

void main() {
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

    final mockAudio = MockGameAudioService();

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        gameAudioServiceProvider.overrideWithValue(mockAudio),
        gameAudioMutedProvider.overrideWith(
          () => FakeAudioMutedNotifier(initialValue: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Call revealLetterAt
    container.read(gameBoardProvider.notifier).revealLetterAt(0, 0);

    // Verify
    expect(mockAudio.playRevealCallCount, equals(1));
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

    final mockAudio = MockGameAudioService();

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        gameAudioServiceProvider.overrideWithValue(mockAudio),
        gameAudioMutedProvider.overrideWith(
          () => FakeAudioMutedNotifier(initialValue: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Call revealLetterAt
    container.read(gameBoardProvider.notifier).revealLetterAt(0, 0);

    // Verify
    expect(mockAudio.playRevealCallCount, equals(0));
  });
}
