// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Croiz';

  @override
  String get welcome => 'Bienvenue sur Croiz';

  @override
  String get puzzles => 'Mots croisés';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageUkrainian => 'Ukrainien';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get selectAWord => 'Sélectionnez un mot';

  @override
  String get menu => 'Menu';

  @override
  String get clear => 'Effacer';

  @override
  String get close => 'Fermer';

  @override
  String get restart => 'Recommencer';

  @override
  String get view => 'Regarder';

  @override
  String get reveal => 'Révéler';

  @override
  String get revealLetterOption => 'Révéler la lettre';

  @override
  String get revealWordOption => 'Révéler le mot';

  @override
  String get revealAllOption => 'Tout révéler';

  @override
  String get congratulations => 'Félicitations!';

  @override
  String get loading => 'Chargement...';

  @override
  String get clearIncorrectLetters => 'Effacer les lettres incorrectes';

  @override
  String get switchKeyboardLayout => 'Changer la disposition du clavier';

  @override
  String letterLabel(Object letter) {
    return 'Lettre $letter';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get home => 'Accueil';

  @override
  String get keyboardSizeLabel => 'Taille du clavier';

  @override
  String get keyboardStyle => 'Style du clavier';

  @override
  String get muteSounds => 'Couper le son';

  @override
  String get darkTheme => 'Thème sombre';

  @override
  String get help => 'Aide';

  @override
  String get about => 'À propos';

  @override
  String get loadingPuzzle => 'Chargement...';

  @override
  String get pleaseWait => 'Veuillez patienter';

  @override
  String get errorLoading => 'Erreur de chargement';

  @override
  String get subtitle => 'Mots croisés';

  @override
  String get ready => 'Prêt !';

  @override
  String get loadingSounds => 'Chargement des sons...';

  @override
  String get starting => 'Démarrage...';

  @override
  String get small => 'Petit';

  @override
  String get medium => 'Moyen';

  @override
  String get large => 'Grand';

  @override
  String get azerty => 'AZERTY';

  @override
  String get qwerty => 'QWERTY';

  @override
  String get generatorTitle => 'Générateur de Puzzle';

  @override
  String get topicLabel => 'Thème (ex: Bretagne, Cuisine...)';

  @override
  String get topicHint => 'Entrez un thème';

  @override
  String get languageLabel => 'Langue';

  @override
  String get difficultyLabel => 'Difficulté';

  @override
  String get sizeLabel => 'Taille de la grille';

  @override
  String get generateButton => 'GÉNÉRER';

  @override
  String get generating => 'Génération...';

  @override
  String get successMessage => 'Puzzle généré avec succès !';

  @override
  String get playButton => 'JOUER';

  @override
  String get errorTopicMissing => 'Veuillez entrer un thème';

  @override
  String get quick => 'Rapide';

  @override
  String get standard => 'Standard';

  @override
  String get continuePlaying => 'Continuer';

  @override
  String get noPuzzlesInProgress => 'Aucun puzzle en cours';

  @override
  String get across => 'Horizontal';

  @override
  String get down => 'Vertical';

  @override
  String get easy => 'Facile';

  @override
  String get hard => 'Difficile';

  @override
  String get expert => 'Expert';

  @override
  String get pro => 'Pro';

  @override
  String semanticCellRowColumn(Object col, Object row) {
    return 'Case ligne $row, colonne $col';
  }

  @override
  String semanticCellNumber(Object number) {
    return 'numéro $number';
  }

  @override
  String semanticCellLetter(Object letter) {
    return 'lettre $letter';
  }

  @override
  String get semanticCellEmpty => 'vide';

  @override
  String get semanticCellSelected => 'sélectionnée';

  @override
  String semanticClueAcross(Object clue) {
    return 'Horizontal : $clue';
  }

  @override
  String semanticClueDown(Object clue) {
    return 'Vertical : $clue';
  }

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get revealAllConfirmationTitle => 'Confirmer Tout Révéler';

  @override
  String get revealAllConfirmationMessage =>
      'Êtes-vous sûr de vouloir révéler tout le puzzle ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get completedFilter => 'Terminés';

  @override
  String get deletePuzzle => 'Supprimer le puzzle';

  @override
  String get deletePuzzleConfirmation =>
      'Voulez-vous vraiment supprimer ce puzzle ? Cette action est irréversible.';

  @override
  String get cancel => 'Annuler';
}
