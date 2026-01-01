import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State for puzzle filtering.
class PuzzleFilterState {
  const PuzzleFilterState({
    this.selectedDifficulties = const {1, 2, 3, 4, 5},
    this.selectedLanguages = const {},
    this.availableLanguages = const {'en'},
    this.showCompleted = true,
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

  /// Whether any filter is active (not default).
  bool get hasActiveFilters =>
      selectedDifficulties.length < 5 ||
      !showCompleted ||
      selectedLanguages.isNotEmpty;

  /// Create a copy with optional field overrides.
  PuzzleFilterState copyWith({
    Set<int>? selectedDifficulties,
    Set<String>? selectedLanguages,
    Set<String>? availableLanguages,
    bool? showCompleted,
  }) => PuzzleFilterState(
    selectedDifficulties: selectedDifficulties ?? this.selectedDifficulties,
    selectedLanguages: selectedLanguages ?? this.selectedLanguages,
    availableLanguages: availableLanguages ?? this.availableLanguages,
    showCompleted: showCompleted ?? this.showCompleted,
  );
}

/// Provider for puzzle filter state.
final puzzleFilterProvider =
    NotifierProvider<PuzzleFilterNotifier, PuzzleFilterState>(
      PuzzleFilterNotifier.new,
    );

/// Notifier for managing puzzle filter state.
class PuzzleFilterNotifier extends Notifier<PuzzleFilterState> {
  static const _keyDifficulties = 'puzzle_filter_difficulties';
  static const _keyLanguages = 'puzzle_filter_languages';
  static const _keyShowCompleted = 'puzzle_filter_show_completed';

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
  void toggleLanguage(String language) {
    var current = Set<String>.from(state.selectedLanguages);

    // If empty (All), and we are toggling one OFF (assuming UI shows checks),
    // wait. The UI will likely call this when a user UNCHECKS something that was implicitly checked.
    // Or CHECKS something that was unchecked.

    // Logic:
    // If empty, it means ALL are selected.
    // If we call toggleLanguage('fr'):
    // Does it mean "Deselect FR" or "Select FR"?
    // Standard Toggle:
    // If 'fr' is IN the set -> Remove it.
    // If 'fr' is NOT in the set -> Add it.

    // BUT 'empty' means ALL. So 'fr' is effectively IN the set.
    // So we should Remove it. To remove it from "All", we must materialize "All - {fr}".

    if (current.isEmpty) {
      // Materialize all
      current = Set<String>.from(state.availableLanguages);
    }

    if (current.contains(language)) {
      current.remove(language);
    } else {
      current.add(language);
    }

    // Optimization: If we selected everything, go back to empty (implicit All)
    if (current.length == state.availableLanguages.length &&
        state.availableLanguages.isNotEmpty) {
      current = {};
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
    } on Object {
      // Ignore errors persisting preferences
    }
  }
}
