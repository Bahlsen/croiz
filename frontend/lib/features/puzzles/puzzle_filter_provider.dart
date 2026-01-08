import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'puzzle_filter_provider.g.dart';

/// State for puzzle filtering.
class PuzzleFilterState {
  const PuzzleFilterState({
    this.selectedDifficulties = const {1, 2, 3, 4, 5},
    this.selectedLanguages = const {},
    this.availableLanguages = const {'en'},
    this.showCompleted = false,
    this.showGeneratedOnly = false,
    this.searchQuery = '',
  });

  /// Selected difficulty levels (1=Easy, 2=Medium, 3=Hard, 4=Expert, 5=Master).
  final Set<int> selectedDifficulties;

  /// Selected language codes.
  ///
  /// If empty, implies ALL available languages are selected.
  final Set<String> selectedLanguages;

  /// All available languages in the puzzle index.
  final Set<String> availableLanguages;

  /// Whether to show completed puzzles.
  final bool showCompleted;

  /// Whether to show only generated puzzles.
  final bool showGeneratedOnly;

  /// Search query for puzzle title.
  final String searchQuery;

  /// Whether any filter is active (not default).
  bool get hasActiveFilters =>
      selectedDifficulties.length < 5 ||
      showCompleted ||
      selectedLanguages.isNotEmpty ||
      showGeneratedOnly ||
      searchQuery.isNotEmpty;

  /// Create a copy with optional field overrides.
  PuzzleFilterState copyWith({
    Set<int>? selectedDifficulties,
    Set<String>? selectedLanguages,
    Set<String>? availableLanguages,
    bool? showCompleted,
    bool? showGeneratedOnly,
    String? searchQuery,
  }) => PuzzleFilterState(
    selectedDifficulties: selectedDifficulties ?? this.selectedDifficulties,
    selectedLanguages: selectedLanguages ?? this.selectedLanguages,
    availableLanguages: availableLanguages ?? this.availableLanguages,
    showCompleted: showCompleted ?? this.showCompleted,
    showGeneratedOnly: showGeneratedOnly ?? this.showGeneratedOnly,
    searchQuery: searchQuery ?? this.searchQuery,
  );
}

/// Notifier for managing puzzle filter state.
@riverpod
class PuzzleFilter extends _$PuzzleFilter {
  static const _keyDifficulties = 'puzzle_filter_difficulties';
  static const _keyLanguages = 'puzzle_filter_languages';
  static const _keyShowCompleted = 'puzzle_filter_show_completed';
  static const _keyShowGeneratedOnly = 'puzzle_filter_show_generated_only';

  @override
  PuzzleFilterState build() => const PuzzleFilterState();

  /// Toggle a difficulty level in the filter.
  void toggleDifficulty(int difficulty) {
    final current = Set<int>.from(state.selectedDifficulties);
    if (current.contains(difficulty)) {
      current.remove(difficulty);
    } else {
      current.add(difficulty);
    }
    state = state.copyWith(selectedDifficulties: current);
    _persist();
  }

  /// Toggle a language in the filter.
  ///
  /// [availableLanguages] must be passed from the UI to ensure we are toggling
  /// against the correct set of actually available languages.
  void toggleLanguage(String language, Set<String> availableLanguages) {
    var current = Set<String>.from(state.selectedLanguages);

    if (current.isEmpty) {
      // Materialize all
      current = Set<String>.from(availableLanguages);
    }

    if (current.contains(language)) {
      current.remove(language);
    } else {
      current.add(language);
    }

    // Optimization: If the new set contains ALL available languages,
    // revert to empty set (implicit All).
    if (current.length == availableLanguages.length &&
        availableLanguages.isNotEmpty) {
      if (current.containsAll(availableLanguages)) {
        current = {};
      }
    }

    state = state.copyWith(selectedLanguages: current);
    _persist();
  }

  /// Set available languages (from puzzle index).
  void setAvailableLanguages(Set<String> languages) {
    // Just update available languages.
    // If selectedLanguages is empty, it implicitly includes the new languages.
    state = state.copyWith(availableLanguages: languages);
  }

  /// Set whether to show completed puzzles.
  void setShowCompleted({required bool showCompleted}) {
    state = state.copyWith(showCompleted: showCompleted);
    _persist();
  }

  /// Toggle completed puzzles filter.
  void toggleShowCompleted() {
    state = state.copyWith(showCompleted: !state.showCompleted);
    _persist();
  }

  /// Set whether to show only generated puzzles.
  void setShowGeneratedOnly({required bool showGeneratedOnly}) {
    state = state.copyWith(showGeneratedOnly: showGeneratedOnly);
    _persist();
  }

  /// Toggle generated puzzles filter.
  void toggleShowGeneratedOnly() {
    state = state.copyWith(showGeneratedOnly: !state.showGeneratedOnly);
    _persist();
  }

  /// Set the search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    // Do not persist search query
  }

  /// Reset language filter to select all (empty set).
  void resetLanguages() {
    state = state.copyWith(selectedLanguages: const {});
    _persist();
  }

  /// Reset all filters to defaults.
  void clearFilters() {
    state = PuzzleFilterState(
      availableLanguages: state.availableLanguages,
      selectedLanguages: const {},
    );
    _persist();
  }

  /// Load filter state from SharedPreferences.
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final difficultiesRaw = prefs.getStringList(_keyDifficulties);
      final languagesRaw = prefs.getStringList(_keyLanguages);
      final showCompleted = prefs.getBool(_keyShowCompleted);
      final showGeneratedOnly = prefs.getBool(_keyShowGeneratedOnly);

      Set<int>? difficulties;
      if (difficultiesRaw != null) {
        difficulties = difficultiesRaw.map((s) => int.tryParse(s) ?? 2).toSet();
      }

      Set<String>? languages;
      if (languagesRaw != null) {
        languages = languagesRaw.toSet();
      }

      state = state.copyWith(
        selectedDifficulties: difficulties,
        selectedLanguages: languages,
        showCompleted: showCompleted,
        showGeneratedOnly: showGeneratedOnly,
      );
    } on Object {
      // Ignore errors loading preferences
    }
  }

  /// Persist filter state to SharedPreferences.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _keyDifficulties,
        state.selectedDifficulties.map((d) => d.toString()).toList(),
      );
      await prefs.setStringList(
        _keyLanguages,
        state.selectedLanguages.toList(),
      );
      await prefs.setBool(_keyShowCompleted, state.showCompleted);
      await prefs.setBool(_keyShowGeneratedOnly, state.showGeneratedOnly);
    } on Object {
      // Ignore errors persisting preferences
    }
  }
}
