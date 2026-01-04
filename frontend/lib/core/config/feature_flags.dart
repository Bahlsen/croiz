/// Centralize feature flags for the application.
/// This allows enabling/disabling features easily during development or for different environments.
class FeatureFlags {
  const FeatureFlags._();

  /// Whether the puzzle generation feature (Gemini + Local generator) is enabled.
  /// When disabled, the generation button and related filters are hidden.
  static const bool isGenerationEnabled = false;

  /// Whether to show the debug console/logs for generation.
  static const bool showGenerationLogs = true;
}
