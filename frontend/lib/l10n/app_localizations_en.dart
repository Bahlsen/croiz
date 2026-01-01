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
}
