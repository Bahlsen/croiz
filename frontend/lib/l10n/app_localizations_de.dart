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
  String get revealAllConfirmationMessage =>
      'Sind Sie sicher, dass Sie das gesamte Rätsel aufdecken möchten?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get completedFilter => 'Abgeschlossen';

  @override
  String get deletePuzzle => 'Generiertes Rätsel löschen';

  @override
  String get deletePuzzleConfirmation =>
      'Sind Sie sicher, dass Sie dieses Rätsel löschen möchten? Dieser Vorgang kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';
}
