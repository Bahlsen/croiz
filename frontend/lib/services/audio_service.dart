/// Abstract interface for audio services.
///
/// This allows for easy mocking in tests and potential future
/// implementations with different audio backends.
abstract class AudioService {
  /// Plays the typing sound effect.
  Future<void> playType();

  /// Plays the delete/backspace sound effect.
  Future<void> playDelete();

  /// Plays the word completion success sound effect.
  Future<void> playSuccess();

  /// Plays the game completion victory sound effect.
  Future<void> playVictory();

  /// Future that completes when the service is fully initialized.
  Future<void> get ready;
}
