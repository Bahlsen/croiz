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
  String get revealAllConfirmationMessage => 'Sei sicuro di voler rivelare l\'intero puzzle?';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get completedFilter => 'Completato';

  @override
  String get deletePuzzle => 'Elimina Puzzle Generato';

  @override
  String get deletePuzzleConfirmation => 'Sei sicuro di voler eliminare questo puzzle? L\'azione non può essere annullata.';

  @override
  String get deleteSuccessMessage => 'Puzzle eliminato con successo';

  @override
  String get cancel => 'Annulla';
}
