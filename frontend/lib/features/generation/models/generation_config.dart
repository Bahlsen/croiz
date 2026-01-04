/// Centralized configuration for crossword puzzle generation.
///
/// All tunable parameters are defined here for easy adjustment and consistency.
/// See GENERATION_DOCUMENTATION.md for rationale behind each value.
class GenerationConfig {
  const GenerationConfig({
    // Grid Structure
    this.targetBlackRatio = 0.18,
    this.minWordLength = 3,

    // Attempt Limits
    this.maxAttempts = 150,
    this.maxSkeletonAttempts = 10,
    this.maxBacktracks = 50000,

    // Adaptive Difficulty
    this.adaptiveRelaxChance = 0.3,
    this.relaxedBlackRatio = 0.22,

    // Quality Thresholds
    this.minDensityRatio = 0.35,
    this.minThemeRetentionRatio = 0.5,

    // CSP Solver Tuning
    this.lcvThreshold = 500,
    this.lcvSampleLimit = 100,
  });

  // --- Grid Structure ---

  /// Target ratio of black squares to total cells.
  /// Professional standard is 16-18%.
  final double targetBlackRatio;

  /// Minimum length for word slots.
  /// Standard crosswords use 3+.
  final int minWordLength;

  // --- Attempt Limits ---

  /// Maximum number of full generation attempts.
  final int maxAttempts;

  /// Maximum skeleton (theme placement) retries per attempt.
  final int maxSkeletonAttempts;

  /// Maximum backtracking steps for CSP solver.
  final int maxBacktracks;

  // --- Adaptive Difficulty ---

  /// Probability of using relaxed constraints.
  final double adaptiveRelaxChance;

  /// Black ratio to use when relaxing constraints.
  final double relaxedBlackRatio;

  // --- Quality Thresholds ---

  /// Minimum ratio of placed words to grid cells.
  /// 0.35 = 35% = ~79 words for 15x15.
  final double minDensityRatio;

  /// Minimum ratio of theme words that must be placed.
  /// 0.5 = at least 50% of theme words.
  final double minThemeRetentionRatio;

  // --- CSP Solver Tuning ---

  /// Domain size threshold for LCV heuristic.
  /// LCV sorting is skipped for domains larger than this.
  final int lcvThreshold;

  /// Sample limit for LCV neighbor checking.
  final int lcvSampleLimit;

  /// Default configuration optimized for dense, professional-quality puzzles.
  static const GenerationConfig defaultConfig = GenerationConfig();

  /// Relaxed configuration for difficult theme words.
  static const GenerationConfig relaxed = GenerationConfig(
    targetBlackRatio: 0.22,
    relaxedBlackRatio: 0.28,
    adaptiveRelaxChance: 0.5,
    minDensityRatio: 0.25,
  );

  /// Quick configuration for testing.
  static const GenerationConfig quick = GenerationConfig(
    maxAttempts: 20,
    maxSkeletonAttempts: 3,
    maxBacktracks: 5000,
  );

  @override
  String toString() =>
      'GenerationConfig('
      'blackRatio: $targetBlackRatio, '
      'attempts: $maxAttempts, '
      'skeletonRetries: $maxSkeletonAttempts, '
      'backtracking: $maxBacktracks, '
      'minDensity: ${(minDensityRatio * 100).toInt()}%)';
}
