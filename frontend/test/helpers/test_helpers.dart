import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/persistence/storage_provider.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/providers/game_board_notifier.dart';
import 'package:croiz/services/audio_service.dart';
import 'package:croiz/services/persistence/puzzle_progress_service.dart';
import 'fake_puzzle_storage.dart';
import 'fake_audio_service.dart';

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
}) => [
    puzzleStorageProvider.overrideWithValue(storage ?? FakePuzzleStorage()),
    gameAudioServiceProvider.overrideWithValue(
      audioService ?? FakeAudioService(),
    ),
    preferencePersistenceServiceProvider.overrideWithValue(
      preferences ?? FakePreferencePersistenceService(),
    ),
    flashClearDelayProvider.overrideWithValue(Duration.zero),
    wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
  ];

/// Creates a [ProviderContainer] for testing with common overrides.
ProviderContainer createTestContainer({
  PuzzleStorageInterface? storage,
  AudioService? audioService,
  PreferencePersistenceService? preferences,
  List<dynamic> overrides = const [],
}) => ProviderContainer(
    overrides: [
      ...commonOverrides(
        storage: storage,
        audioService: audioService,
        preferences: preferences,
      ),
      ...overrides,
    ],
  );
