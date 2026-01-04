/// Simple word index for crossword generation.
///
/// This is a memory-efficient replacement for GADDAG.
/// GADDAG was designed for Scrabble (finding words from tiles in hand),
/// but for crossword generation we only need pattern matching.
///
/// Memory comparison:
/// - GADDAG: O(n * k²) nodes where n = words, k = avg length
/// - WordIndex: O(n) - just stores words in lists by length
///
/// This results in ~10-50x less memory usage.
class WordIndex {
  /// Words indexed by length for O(1) length lookup
  final Map<int, List<String>> _wordsByLength = {};

  /// All words for quick existence check
  final Set<String> _allWords = {};

  /// Build the index from a list of words.
  void build(List<String> words) {
    _wordsByLength.clear();
    _allWords.clear();
    words.forEach(addWord);
  }

  /// Add a single word to the index.
  void addWord(String word) {
    final cleaned = word.trim().toUpperCase();
    if (cleaned.isEmpty || _allWords.contains(cleaned)) {
      return;
    }

    _allWords.add(cleaned);
    _wordsByLength.putIfAbsent(cleaned.length, () => []).add(cleaned);
  }

  /// Check if a word exists in the index.
  bool containsWord(String word) => _allWords.contains(word.toUpperCase());

  /// Get all words of a specific length.
  List<String> findWordsByLength(int length) =>
      _wordsByLength[length] ?? const [];

  /// Find all words matching a pattern.
  ///
  /// Pattern uses '_' as wildcard for any single character.
  /// Example: "_A_E_" matches "PAPER", "WATER", "TABLE", etc.
  ///
  /// Time complexity: O(n) where n = words of that length.
  /// For crossword generation with ~100-500 words per length, this is fast.
  List<String> findMatches(String pattern) {
    final upperPattern = pattern.toUpperCase();
    final candidates = _wordsByLength[pattern.length];
    if (candidates == null || candidates.isEmpty) {
      return const [];
    }

    return candidates
        .where((word) => _matchesPattern(word, upperPattern))
        .toList();
  }

  /// Check if a word matches a pattern with wildcards.
  bool _matchesPattern(String word, String pattern) {
    if (word.length != pattern.length) {
      return false;
    }

    for (var i = 0; i < word.length; i++) {
      if (pattern[i] != '_' && pattern[i] != word[i]) {
        return false;
      }
    }
    return true;
  }

  /// Find words that can be formed with given letters at specific positions.
  ///
  /// [constraints] maps position index to required letter.
  /// Example: {1: 'A', 3: 'E'} finds 5-letter words with A at pos 1, E at pos 3.
  List<String> findWordsWithConstraints(
    int length,
    Map<int, String> constraints,
  ) {
    final candidates = _wordsByLength[length];
    if (candidates == null || candidates.isEmpty) {
      return const [];
    }

    // If no constraints, return all words of that length
    if (constraints.isEmpty) {
      return candidates;
    }

    return candidates.where((word) {
      for (final entry in constraints.entries) {
        final pos = entry.key;
        final letter = entry.value;
        if (pos < 0 || pos >= word.length || word[pos] != letter) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Get total number of words in the index.
  int get wordCount => _allWords.length;

  /// Get all words in the index.
  Set<String> get allWords => _allWords;

  /// Get statistics about the index.
  Map<String, dynamic> getStats() => {
    'totalWords': _allWords.length,
    'wordsByLength': _wordsByLength.map(
      (length, words) => MapEntry(length.toString(), words.length),
    ),
  };
}
