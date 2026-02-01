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
  String get revealAllConfirmationMessage => 'Êtes-vous sûr de vouloir révéler tout le puzzle ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get completedFilter => 'Terminés';

  @override
  String get deletePuzzle => 'Supprimer le puzzle';

  @override
  String get deletePuzzleConfirmation => 'Voulez-vous vraiment supprimer ce puzzle ? Cette action est irréversible.';

  @override
  String get deleteSuccessMessage => 'Puzzle supprimé avec succès';

  @override
  String get cancel => 'Annuler';

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
  String get statisticsTitle => 'Statistiques';

  @override
  String get totalPuzzles => 'Total Puzzles';

  @override
  String get currentStreak => 'Série actuelle';

  @override
  String get longestStreak => 'Meilleure série';

  @override
  String get totalTime => 'Temps total';

  @override
  String get recentCompletions => 'Puzzles récents';

  @override
  String get accuracy => 'Précision';

  @override
  String get hints => 'Indices';

  @override
  String get statsSummary => 'Résumé';

  @override
  String get activityLevel => 'Niveau d\'activité';

  @override
  String get weeklyActivity => 'Activité hebdomadaire';

  @override
  String get achievements => 'Succès';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }
}
