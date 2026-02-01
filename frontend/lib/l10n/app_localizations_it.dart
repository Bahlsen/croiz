// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Croiz';

  @override
  String get welcome => 'Benvenuto in Croiz';

  @override
  String get puzzles => 'Puzzle';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageUkrainian => 'Ucraino';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get selectAWord => 'Seleziona una parola';

  @override
  String get menu => 'Menu';

  @override
  String get clear => 'Cancella';

  @override
  String get close => 'Chiudi';

  @override
  String get restart => 'Ricomincia';

  @override
  String get view => 'Visualizza';

  @override
  String get reveal => 'Rivela';

  @override
  String get revealLetterOption => 'Rivela lettera';

  @override
  String get revealWordOption => 'Rivela parola';

  @override
  String get revealAllOption => 'Rivela tutto';

  @override
  String get congratulations => 'Congratulazioni!';

  @override
  String get loading => 'Caricamento...';

  @override
  String get clearIncorrectLetters => 'Cancella lettere errate';

  @override
  String get switchKeyboardLayout => 'Cambia layout tastiera';

  @override
  String letterLabel(Object letter) {
    return 'Lettera $letter';
  }

  @override
  String get delete => 'Elimina';

  @override
  String get home => 'Home';

  @override
  String get keyboardSizeLabel => 'Dimensione tastiera';

  @override
  String get keyboardStyle => 'Stile tastiera';

  @override
  String get muteSounds => 'Disattiva suoni';

  @override
  String get darkTheme => 'Tema scuro';

  @override
  String get help => 'Aiuto';

  @override
  String get about => 'Informazioni';

  @override
  String get loadingPuzzle => 'Caricamento puzzle...';

  @override
  String get pleaseWait => 'Attendere prego';

  @override
  String get errorLoading => 'Errore nel caricamento del puzzle';

  @override
  String get subtitle => 'Parole crociate';

  @override
  String get ready => 'Pronto!';

  @override
  String get loadingSounds => 'Caricamento suoni...';

  @override
  String get starting => 'Avvio...';

  @override
  String get small => 'Piccolo';

  @override
  String get medium => 'Medio';

  @override
  String get large => 'Grande';

  @override
  String get azerty => 'AZERTY';

  @override
  String get qwerty => 'QWERTY';

  @override
  String get generatorTitle => 'Generatore di Puzzle';

  @override
  String get topicLabel => 'Argomento (es. Scienza, Viaggi...)';

  @override
  String get topicHint => 'Inserisci un argomento';

  @override
  String get languageLabel => 'Lingua';

  @override
  String get difficultyLabel => 'Difficoltà';

  @override
  String get sizeLabel => 'Dimensione griglia';

  @override
  String get generateButton => 'GENERA';

  @override
  String get generating => 'Generazione...';

  @override
  String get successMessage => 'Puzzle generato con successo!';

  @override
  String get playButton => 'GIOCA';

  @override
  String get errorTopicMissing => 'Inserisci un argomento';

  @override
  String get quick => 'Rapido';

  @override
  String get standard => 'Standard';

  @override
  String get continuePlaying => 'Continua a giocare';

  @override
  String get noPuzzlesInProgress => 'Nessun puzzle in corso';

  @override
  String get across => 'Orizzontali';

  @override
  String get down => 'Verticali';

  @override
  String get easy => 'Facile';

  @override
  String get hard => 'Difficile';

  @override
  String get expert => 'Esperto';

  @override
  String get pro => 'Pro';

  @override
  String semanticCellRowColumn(Object col, Object row) {
    return 'Cella riga $row, colonna $col';
  }

  @override
  String semanticCellNumber(Object number) {
    return 'numero $number';
  }

  @override
  String semanticCellLetter(Object letter) {
    return 'lettera $letter';
  }

  @override
  String get semanticCellEmpty => 'vuota';

  @override
  String get semanticCellSelected => 'selezionata';

  @override
  String semanticClueAcross(Object clue) {
    return 'Orizzontale: $clue';
  }

  @override
  String semanticClueDown(Object clue) {
    return 'Verticale: $clue';
  }

  @override
  String get clearFilters => 'Cancella filtri';

  @override
  String get revealAllConfirmationTitle => 'Conferma Rivela Tutto';

  @override
  String get revealAllConfirmationMessage =>
      'Sei sicuro di voler rivelare l\'intero puzzle?';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get completedFilter => 'Completato';

  @override
  String get deletePuzzle => 'Elimina Puzzle Generato';

  @override
  String get deletePuzzleConfirmation =>
      'Sei sicuro di voler eliminare questo puzzle? L\'azione non può essere annullata.';

  @override
  String get deleteSuccessMessage => 'Puzzle eliminato con successo';

  @override
  String get cancel => 'Annulla';

  @override
  String get appDescription =>
      'A modern crossword puzzle game with AI-powered generation, multiple languages, and beautiful design.';

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
  String get helpBasic2 =>
      'Type letters using the on-screen keyboard or your device keyboard';

  @override
  String get helpBasic3 =>
      'Tap the selected cell again to switch between across/down';

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
  String get helpFeature1 =>
      '🔍 Reveal: Show letters for a word or the entire puzzle';

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
  String get onboardingWelcomeDesc =>
      'Play thousands of crosswords from top publishers.';

  @override
  String get onboardingBasicTitle => 'How to Play';

  @override
  String get onboardingBasicDesc =>
      'Tap any cell to select it, then type letters to fill the grid.';

  @override
  String get onboardingDirectionTitle => 'Switch Direction';

  @override
  String get onboardingDirectionDesc =>
      'Tap the selected cell again (or double-tap) to switch between Across and Down.';

  @override
  String get onboardingCompletionTitle => 'Word Completion';

  @override
  String get onboardingCompletionDesc =>
      'When a word is correct, it will glow green. Finish the whole puzzle for a celebration!';

  @override
  String get onboardingFinishTitle => 'You\'re All Set!';

  @override
  String get onboardingFinishDesc =>
      'Choose from thousands of puzzles in multiple languages.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingDone => 'Get Started';
}
