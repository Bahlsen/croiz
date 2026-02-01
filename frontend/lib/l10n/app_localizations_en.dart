// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Croiz';

  @override
  String get welcome => 'Welcome to Croiz';

  @override
  String get puzzles => 'Puzzles';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageUkrainian => 'Ukrainian';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get selectAWord => 'Select a word';

  @override
  String get menu => 'Menu';

  @override
  String get clear => 'Clear';

  @override
  String get close => 'Close';

  @override
  String get restart => 'Restart';

  @override
  String get view => 'View';

  @override
  String get reveal => 'Reveal';

  @override
  String get revealLetterOption => 'Reveal letter';

  @override
  String get revealWordOption => 'Reveal word';

  @override
  String get revealAllOption => 'Reveal all';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get loading => 'Loading...';

  @override
  String get clearIncorrectLetters => 'Clear incorrect letters';

  @override
  String get switchKeyboardLayout => 'Switch keyboard layout';

  @override
  String letterLabel(Object letter) {
    return 'Letter $letter';
  }

  @override
  String get delete => 'Delete';

  @override
  String get home => 'Home';

  @override
  String get keyboardSizeLabel => 'Keyboard size';

  @override
  String get keyboardStyle => 'Keyboard style';

  @override
  String get muteSounds => 'Mute sounds';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get loadingPuzzle => 'Loading puzzle...';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get errorLoading => 'Error loading puzzle';

  @override
  String get subtitle => 'Crossword Puzzles';

  @override
  String get ready => 'Ready!';

  @override
  String get loadingSounds => 'Loading sounds...';

  @override
  String get starting => 'Starting...';

  @override
  String get small => 'Small';

  @override
  String get medium => 'Medium';

  @override
  String get large => 'Large';

  @override
  String get azerty => 'AZERTY';

  @override
  String get qwerty => 'QWERTY';

  @override
  String get generatorTitle => 'Puzzle Generator';

  @override
  String get topicLabel => 'Topic (e.g. Science, Travel...)';

  @override
  String get topicHint => 'Enter a topic';

  @override
  String get languageLabel => 'Language';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get sizeLabel => 'Grid Size';

  @override
  String get generateButton => 'GENERATE';

  @override
  String get generating => 'Generating...';

  @override
  String get successMessage => 'Puzzle generated successfully!';

  @override
  String get playButton => 'PLAY';

  @override
  String get errorTopicMissing => 'Please enter a topic';

  @override
  String get quick => 'Quick';

  @override
  String get standard => 'Standard';

  @override
  String get continuePlaying => 'Continue Playing';

  @override
  String get noPuzzlesInProgress => 'No puzzles in progress';

  @override
  String get across => 'Across';

  @override
  String get down => 'Down';

  @override
  String get easy => 'Easy';

  @override
  String get hard => 'Hard';

  @override
  String get expert => 'Expert';

  @override
  String get pro => 'Pro';

  @override
  String semanticCellRowColumn(Object col, Object row) {
    return 'Cell row $row, column $col';
  }

  @override
  String semanticCellNumber(Object number) {
    return 'number $number';
  }

  @override
  String semanticCellLetter(Object letter) {
    return 'letter $letter';
  }

  @override
  String get semanticCellEmpty => 'empty';

  @override
  String get semanticCellSelected => 'selected';

  @override
  String semanticClueAcross(Object clue) {
    return 'Across: $clue';
  }

  @override
  String semanticClueDown(Object clue) {
    return 'Down: $clue';
  }

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get revealAllConfirmationTitle => 'Confirm Reveal All';

  @override
  String get revealAllConfirmationMessage => 'Are you sure you want to reveal the entire puzzle?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get completedFilter => 'Completed';

  @override
  String get deletePuzzle => 'Delete Generated Puzzle';

  @override
  String get deletePuzzleConfirmation => 'Are you sure you want to delete this puzzle? This action cannot be undone.';

  @override
  String get deleteSuccessMessage => 'Puzzle deleted successfully';

  @override
  String get cancel => 'Cancel';

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
}
