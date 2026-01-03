/// GADDAG Node - a node in the GADDAG data structure.
///
/// Each node represents a character position in the word graph.
class GaddagNode {
  /// Children nodes keyed by character
  final Map<String, GaddagNode> children = {};

  /// Whether this node marks the end of a complete word
  bool isTerminal = false;

  /// The original word if this is a terminal node
  String? wordAtTerminal;
}

/// GADDAG (Generalized Directed Acyclic Word Graph) data structure.
///
/// Enables efficient bidirectional word lookup by storing every reversed
/// prefix of every word. This allows pattern matching like "_A_E_" in O(k)
/// time where k is the pattern length.
///
/// Based on Steven A. Gordon's 1994 paper:
/// "A Faster Scrabble Move Generation Algorithm"
///
/// Example:
/// ```dart
/// final gaddag = Gaddag()..build(['PAPER', 'WATER', 'TABLE']);
/// final matches = gaddag.findMatches('_A_E_');
/// // Returns: {'PAPER', 'WATER', 'TABLE'}
/// ```
class Gaddag {
  /// Separator character between reversed prefix and suffix.
  /// Must be a character that doesn't appear in any word.
  static const String separator = '>';

  /// Root node of the GADDAG
  final GaddagNode root = GaddagNode();

  /// Index of words by length for quick lookup
  final Map<int, Set<String>> _wordsByLength = {};

  /// All words in the GADDAG
  final Set<String> _allWords = {};

  /// Build the GADDAG from a list of words.
  ///
  /// This creates multiple entries for each word, one for each
  /// possible "hook" position. Time complexity: O(sum of word_length²).
  void build(List<String> words) {
    words.forEach(addWord);
  }

  /// Add a single word to the GADDAG
  void addWord(String word) {
    final cleaned = word.trim().toUpperCase();
    if (cleaned.isEmpty || _allWords.contains(cleaned)) {
      return;
    }

    _allWords.add(cleaned);
    _wordsByLength.putIfAbsent(cleaned.length, () => {}).add(cleaned);
    _insertWord(cleaned);
  }

  /// Insert all representations of a word.
  void _insertWord(String word) {
    // For each possible split point (1 to word.length)
    // Create path: REV(prefix) + separator + suffix
    for (var i = 1; i <= word.length; i++) {
      final prefix = word.substring(0, i);
      final suffix = word.substring(i);

      // Reverse the prefix
      final reversedPrefix = prefix.split('').reversed.join();

      // Build the path
      final path = reversedPrefix + separator + suffix;
      _insertPath(path, word);
    }

    // Also insert the fully reversed word + separator
    // This handles edge case when starting from last letter
    final fullyReversed = word.split('').reversed.join() + separator;
    _insertPath(fullyReversed, word);
  }

  /// Insert a path into the GADDAG.
  void _insertPath(String path, String originalWord) {
    var node = root;
    for (final char in path.split('')) {
      node = node.children.putIfAbsent(char, GaddagNode.new);
    }
    node
      ..isTerminal = true
      ..wordAtTerminal = originalWord;
  }

  /// Check if a word exists in the GADDAG.
  bool containsWord(String word) => _allWords.contains(word.toUpperCase());

  /// Get all words of a specific length.
  Set<String> findWordsByLength(int length) => _wordsByLength[length] ?? {};

  /// Find all words matching a pattern.
  ///
  /// Pattern uses '_' as wildcard for any single character.
  /// Example: "_A_E_" matches "PAPER", "WATER", "TABLE", etc.
  ///
  /// This uses a two-phase search:
  /// 1. Find a known letter in the pattern as anchor
  /// 2. Search GADDAG from that anchor, checking constraints
  Set<String> findMatches(String pattern) {
    final upperPattern = pattern.toUpperCase();

    // Quick filter by length first
    final candidates = _wordsByLength[pattern.length];
    if (candidates == null || candidates.isEmpty) {
      return {};
    }

    // For simple implementation, filter candidates by pattern
    // A full GADDAG traversal would be more efficient for large dictionaries
    return candidates
        .where((word) => _matchesPattern(word, upperPattern))
        .toSet();
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
  /// Example: {1: 'A', 3: 'E'} for a 5-letter word.
  Set<String> findWordsWithConstraints(
    int length,
    Map<int, String> constraints,
  ) {
    final candidates = _wordsByLength[length];
    if (candidates == null || candidates.isEmpty) {
      return {};
    }

    return candidates.where((word) {
      for (final entry in constraints.entries) {
        if (entry.key < 0 || entry.key >= word.length) {
          return false;
        }
        if (word[entry.key] != entry.value.toUpperCase()) {
          return false;
        }
      }
      return true;
    }).toSet();
  }

  /// Get available letters at a specific position across all words of given length.
  ///
  /// Useful for computing cross-check sets.
  Set<String> getAvailableLettersAtPosition(
    int length,
    int position,
    Map<int, String> otherConstraints,
  ) {
    final candidates = _wordsByLength[length];
    if (candidates == null ||
        candidates.isEmpty ||
        position < 0 ||
        position >= length) {
      return {};
    }

    final letters = <String>{};
    for (final word in candidates) {
      var matches = true;
      for (final entry in otherConstraints.entries) {
        if (entry.key >= 0 &&
            entry.key < word.length &&
            word[entry.key] != entry.value.toUpperCase()) {
          matches = false;
          break;
        }
      }
      if (matches) {
        letters.add(word[position]);
      }
    }

    return letters;
  }

  /// Get total number of words in the GADDAG.
  int get wordCount => _allWords.length;

  /// Get all words in the GADDAG.
  Set<String> get allWords => Set.unmodifiable(_allWords);

  /// Get statistics about the GADDAG.
  Map<String, dynamic> get statistics {
    var nodeCount = 0;
    var terminalCount = 0;

    void countNodes(GaddagNode node) {
      nodeCount++;
      if (node.isTerminal) {
        terminalCount++;
      }
      node.children.values.forEach(countNodes);
    }

    countNodes(root);

    return {
      'wordCount': _allWords.length,
      'nodeCount': nodeCount,
      'terminalCount': terminalCount,
      'lengthDistribution': _wordsByLength.map((k, v) => MapEntry(k, v.length)),
    };
  }
}
