// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Croiz';

  @override
  String get welcome => 'Willkommen bei Croiz';

  @override
  String get puzzles => 'Rätsel';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageUkrainian => 'Ukrainisch';

  @override
  String get selectLanguage => 'Sprache wählen';

  @override
  String get selectAWord => 'Wort auswählen';

  @override
  String get menu => 'Menü';

  @override
  String get clear => 'Löschen';

  @override
  String get close => 'Schließen';

  @override
  String get restart => 'Neustart';

  @override
  String get view => 'Ansicht';

  @override
  String get reveal => 'Aufdecken';

  @override
  String get revealLetterOption => 'Buchstaben aufdecken';

  @override
  String get revealWordOption => 'Wort aufdecken';

  @override
  String get revealAllOption => 'Alle aufdecken';

  @override
  String get congratulations => 'Herzlichen Glückwunsch!';

  @override
  String get loading => 'Laden...';

  @override
  String get clearIncorrectLetters => 'Falsche Buchstaben löschen';

  @override
  String get switchKeyboardLayout => 'Tastaturlayout ändern';

  @override
  String letterLabel(Object letter) {
    return 'Buchstabe $letter';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get home => 'Home';

  @override
  String get keyboardSizeLabel => 'Tastaturgröße';

  @override
  String get keyboardStyle => 'Tastaturstil';

  @override
  String get muteSounds => 'Stummschalten';

  @override
  String get darkTheme => 'Dunkles Design';

  @override
  String get help => 'Hilfe';

  @override
  String get about => 'Über';

  @override
  String get loadingPuzzle => 'Rätsel wird geladen...';

  @override
  String get pleaseWait => 'Bitte warten';

  @override
  String get errorLoading => 'Fehler beim Laden des Rätsels';

  @override
  String get subtitle => 'Kreuzworträtsel';

  @override
  String get ready => 'Bereit!';

  @override
  String get loadingSounds => 'Töne werden geladen...';

  @override
  String get starting => 'Startet...';

  @override
  String get small => 'Klein';

  @override
  String get medium => 'Mittel';

  @override
  String get large => 'Groß';

  @override
  String get azerty => 'AZERTY';

  @override
  String get qwerty => 'QWERTY';

  @override
  String get generatorTitle => 'Rätsel-Generator';

  @override
  String get topicLabel => 'Thema (z.B. Wissenschaft, Reisen...)';

  @override
  String get topicHint => 'Thema eingeben';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get difficultyLabel => 'Schwierigkeit';

  @override
  String get sizeLabel => 'Gittergröße';

  @override
  String get generateButton => 'GENERIEREN';

  @override
  String get generating => 'Generierung...';

  @override
  String get successMessage => 'Rätsel erfolgreich generiert!';

  @override
  String get playButton => 'SPIELEN';

  @override
  String get errorTopicMissing => 'Bitte ein Thema eingeben';

  @override
  String get quick => 'Schnell';

  @override
  String get standard => 'Standard';

  @override
  String get continuePlaying => 'Weiter spielen';

  @override
  String get noPuzzlesInProgress => 'Keine Rätsel in Bearbeitung';

  @override
  String get across => 'Waagerecht';

  @override
  String get down => 'Senkrecht';

  @override
  String get easy => 'Einfach';

  @override
  String get hard => 'Schwer';

  @override
  String get expert => 'Experte';

  @override
  String get pro => 'Profi';

  @override
  String semanticCellRowColumn(Object col, Object row) {
    return 'Zelle Zeile $row, Spalte $col';
  }

  @override
  String semanticCellNumber(Object number) {
    return 'Nummer $number';
  }

  @override
  String semanticCellLetter(Object letter) {
    return 'Buchstabe $letter';
  }

  @override
  String get semanticCellEmpty => 'leer';

  @override
  String get semanticCellSelected => 'ausgewählt';

  @override
  String semanticClueAcross(Object clue) {
    return 'Waagerecht: $clue';
  }

  @override
  String semanticClueDown(Object clue) {
    return 'Senkrecht: $clue';
  }

  @override
  String get clearFilters => 'Filter löschen';

  @override
  String get revealAllConfirmationTitle => 'Bestätigung: Alles aufdecken';

  @override
  String get revealAllConfirmationMessage => 'Sind Sie sicher, dass Sie das gesamte Rätsel aufdecken möchten?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get completedFilter => 'Abgeschlossen';

  @override
  String get deletePuzzle => 'Generiertes Rätsel löschen';

  @override
  String get deletePuzzleConfirmation => 'Sind Sie sicher, dass Sie dieses Rätsel löschen möchten? Dieser Vorgang kann nicht rückgängig gemacht werden.';

  @override
  String get deleteSuccessMessage => 'Rätsel erfolgreich gelöscht';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get appDescription => 'A modern crossword puzzle game with AI-powered generation, multiple languages, and beautiful design.';

  @override
  String get credits => 'Credits';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get howToPlayBasics => 'Basics';

  @override
  String get helpBasic1 => 'Tap a cell to select it and see the clue';

  @override
  String get helpBasic2 => 'Type letters using the on-screen keyboard or your device keyboard';

  @override
  String get helpBasic3 => 'Tap the selected cell again to switch between across/down';

  @override
  String get helpBasic4 => 'Completed words turn green automatically';

  @override
  String get controls => 'Controls';

  @override
  String get helpControl1 => 'Tap cells to navigate the grid';

  @override
  String get helpControl2 => 'Use arrow buttons to move between cells';

  @override
  String get helpControl3 => 'Backspace deletes the current letter';

  @override
  String get helpControl4 => 'Menu button (⋮) opens settings';

  @override
  String get features => 'Features';

  @override
  String get helpFeature1 => '🔍 Reveal: Show letters for a word or the entire puzzle';

  @override
  String get helpFeature2 => '🔄 Reset: Clear all your answers and start over';

  @override
  String get helpFeature3 => '🎨 Themes: Switch between light and dark mode';

  @override
  String get helpFeature4 => '🌍 Languages: Play puzzles in multiple languages';

  @override
  String get helpFeature5 => '✨ Generate: Create custom puzzles';

  @override
  String get tips => 'Tips';

  @override
  String get helpTip1 => 'Start with shorter words - they\'re usually easier';

  @override
  String get helpTip2 => 'Look for common letter patterns and word endings';

  @override
  String get helpTip3 => 'Use crossing words to help solve difficult clues';

  @override
  String get helpTip4 => 'Your progress is saved automatically';

  @override
  String get noResults => 'No puzzles found';

  @override
  String get noResultsDesc => 'Try adjusting your search or filters.';

  @override
  String get zeroPuzzles => 'No puzzles yet';

  @override
  String get zeroPuzzlesDesc => 'Select a puzzle to start playing!';

  @override
  String get generateFirst => 'Get Started';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Croiz';

  @override
  String get onboardingWelcomeDesc => 'Play thousands of crosswords from top publishers.';

  @override
  String get onboardingBasicTitle => 'How to Play';

  @override
  String get onboardingBasicDesc => 'Tap any cell to select it, then type letters to fill the grid.';

  @override
  String get onboardingDirectionTitle => 'Switch Direction';

  @override
  String get onboardingDirectionDesc => 'Tap the selected cell again (or double-tap) to switch between Across and Down.';

  @override
  String get onboardingCompletionTitle => 'Word Completion';

  @override
  String get onboardingCompletionDesc => 'When a word is correct, it will glow green. Finish the whole puzzle for a celebration!';

  @override
  String get onboardingFinishTitle => 'You\'re All Set!';

  @override
  String get onboardingFinishDesc => 'Choose from thousands of puzzles in multiple languages.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingDone => 'Get Started';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get totalPuzzles => 'Total Puzzles';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get totalTime => 'Total Time';

  @override
  String get recentCompletions => 'Recent Completions';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get hints => 'Hints';

  @override
  String get statsSummary => 'Summary';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get weeklyActivity => 'Weekly Activity';

  @override
  String get achievements => 'Achievements';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Days',
      one: '1 Day',
    );
    return '$_temp0';
  }
}
