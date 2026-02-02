import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/persistence/storage_provider.dart';
import 'package:croiz/features/game/providers/game_audio_provider.dart';
import 'package:croiz/services/persistence/preference_persistence_service.dart';
import 'package:croiz/features/game/providers/game_board_notifier.dart';
import 'package:croiz/services/audio_service.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';
import 'fake_puzzle_storage.dart';
import 'fake_audio_service.dart';
import 'fake_statistics_service.dart';
import 'package:croiz/features/statistics/providers/statistics_providers.dart';
import 'package:croiz/features/statistics/providers/achievement_notifier.dart';

/// A fake implementation of PreferencePersistenceService that uses in-memory storage.
class FakePreferencePersistenceService implements PreferencePersistenceService {
  final Map<String, dynamic> _data = {};

  @override
  Future<void> setBool(String key, {required bool value}) async {
    _data[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _data[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }
}

/// Returns a list of common provider overrides for testing.
List<dynamic> commonOverrides({
  PuzzleStorageInterface? storage,
  AudioService? audioService,
  PreferencePersistenceService? preferences,
  Duration? flashClearDelay,
  Duration? wordCheckDebounceDelay,
}) => [
  puzzleStorageProvider.overrideWithValue(storage ?? FakePuzzleStorage()),
  gameAudioServiceProvider.overrideWithValue(
    audioService ?? FakeAudioService(),
  ),
  preferencePersistenceServiceProvider.overrideWithValue(
    preferences ?? FakePreferencePersistenceService(),
  ),
  flashClearDelayProvider.overrideWithValue(flashClearDelay ?? Duration.zero),
  wordCheckDebounceDelayProvider.overrideWithValue(
    wordCheckDebounceDelay ?? Duration.zero,
  ),
  statisticsServiceProvider.overrideWith((ref) => FakeStatisticsService()),
  achievementServiceProvider.overrideWith((ref) => FakeAchievementService([])),
  achievementNotifier.overrideWith(AchievementNotifier.new),
];

/// Creates a [ProviderContainer] for testing with common overrides.
ProviderContainer createTestContainer({
  PuzzleStorageInterface? storage,
  AudioService? audioService,
  PreferencePersistenceService? preferences,
  Duration? flashClearDelay,
  Duration? wordCheckDebounceDelay,
  List<dynamic> overrides = const [],
}) => ProviderContainer(
  overrides: [
    ...commonOverrides(
      storage: storage,
      audioService: audioService,
      preferences: preferences,
      flashClearDelay: flashClearDelay,
      wordCheckDebounceDelay: wordCheckDebounceDelay,
    ),
    ...overrides,
  ],
);
