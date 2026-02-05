// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Croiz';

  @override
  String get welcome => 'Bienvenido a Croiz';

  @override
  String get puzzles => 'Puzzles';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageUkrainian => 'Ucraniano';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get selectAWord => 'Selecciona una palabra';

  @override
  String get menu => 'Menú';

  @override
  String get clear => 'Limpiar';

  @override
  String get close => 'Cerrar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get view => 'Ver';

  @override
  String get reveal => 'Revelar';

  @override
  String get revealLetterOption => 'Revelar letra';

  @override
  String get revealWordOption => 'Revelar palabra';

  @override
  String get revealAllOption => 'Revelar todo';

  @override
  String get congratulations => '¡Felicidades!';

  @override
  String get loading => 'Cargando...';

  @override
  String get clearIncorrectLetters => 'Limpiar letras incorrectas';

  @override
  String get switchKeyboardLayout => 'Cambiar teclado';

  @override
  String letterLabel(Object letter) {
    return 'Letra $letter';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get home => 'Inicio';

  @override
  String get keyboardSizeLabel => 'Tamaño del teclado';

  @override
  String get keyboardStyle => 'Estilo del teclado';

  @override
  String get muteSounds => 'Silenciar sonidos';

  @override
  String get darkTheme => 'Tema oscuro';

  @override
  String get help => 'Ayuda';

  @override
  String get about => 'Acerca de';

  @override
  String get loadingPuzzle => 'Cargando puzzle...';

  @override
  String get pleaseWait => 'Por favor espere';

  @override
  String get errorLoading => 'Error al cargar el puzzle';

  @override
  String get subtitle => 'Crucigramas';

  @override
  String get ready => '¡Listo!';

  @override
  String get loadingSounds => 'Cargando sonidos...';

  @override
  String get starting => 'Iniciando...';

  @override
  String get small => 'Pequeño';

  @override
  String get medium => 'Mediano';

  @override
  String get large => 'Grande';

  @override
  String get azerty => 'AZERTY';

  @override
  String get qwerty => 'QWERTY';

  @override
  String get generatorTitle => 'Generador de Puzzles';

  @override
  String get topicLabel => 'Tema (ej. Ciencia, Viajes...)';

  @override
  String get topicHint => 'Introduce un tema';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get difficultyLabel => 'Dificultad';

  @override
  String get sizeLabel => 'Tamaño de cuadrícula';

  @override
  String get generateButton => 'GENERAR';

  @override
  String get generating => 'Generando...';

  @override
  String get successMessage => '¡Puzzle generado con éxito!';

  @override
  String get playButton => 'JUGAR';

  @override
  String get errorTopicMissing => 'Por favor introduce un tema';

  @override
  String get quick => 'Rápido';

  @override
  String get standard => 'Estándar';

  @override
  String get continuePlaying => 'Continuar Jugando';

  @override
  String get noPuzzlesInProgress => 'No hay puzzles en curso';

  @override
  String get across => 'Horizontal';

  @override
  String get down => 'Vertical';

  @override
  String get easy => 'Fácil';

  @override
  String get hard => 'Difícil';

  @override
  String get expert => 'Experto';

  @override
  String get pro => 'Pro';

  @override
  String semanticCellRowColumn(Object col, Object row) {
    return 'Celda fila $row, columna $col';
  }

  @override
  String semanticCellNumber(Object number) {
    return 'número $number';
  }

  @override
  String semanticCellLetter(Object letter) {
    return 'letra $letter';
  }

  @override
  String get semanticCellEmpty => 'vacía';

  @override
  String get semanticCellSelected => 'seleccionada';

  @override
  String semanticClueAcross(Object clue) {
    return 'Horizontal: $clue';
  }

  @override
  String semanticClueDown(Object clue) {
    return 'Vertical: $clue';
  }

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get revealAllConfirmationTitle => 'Confirmar Revelar Todo';

  @override
  String get revealAllConfirmationMessage => '¿Estás seguro de que quieres revelar todo el crucigrama?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get completedFilter => 'Completado';

  @override
  String get deletePuzzle => 'Eliminar Crucigrama Generado';

  @override
  String get deletePuzzleConfirmation => '¿Estás seguro de que quieres eliminar este crucigrama? Esta acción no se puede deshacer.';

  @override
  String get deleteSuccessMessage => 'Puzzle eliminado con éxito';

  @override
  String get cancel => 'Cancelar';

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

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String get continueButton => 'Continue';

  @override
  String get achievement_firstPuzzle_title => 'Getting Started';

  @override
  String get achievement_firstPuzzle_desc => 'Complete your first crossword puzzle.';

  @override
  String get achievement_tenPuzzles_title => 'Daily Solver';

  @override
  String get achievement_tenPuzzles_desc => 'Complete 10 crossword puzzles.';

  @override
  String get achievement_hundredPuzzles_title => 'Crossword Master';

  @override
  String get achievement_hundredPuzzles_desc => 'Complete 100 crossword puzzles.';

  @override
  String get achievement_weekStreak_title => 'On Fire!';

  @override
  String get achievement_weekStreak_desc => 'Keep a 7-day completion streak.';

  @override
  String get achievement_monthStreak_title => 'Unstoppable';

  @override
  String get achievement_monthStreak_desc => 'Keep a 30-day completion streak.';

  @override
  String get achievement_speedDemon_title => 'Speed Demon';

  @override
  String get achievement_speedDemon_desc => 'Complete a puzzle in under 3 minutes.';

  @override
  String get achievement_perfectPuzzle_title => 'Perfect Play';

  @override
  String get achievement_perfectPuzzle_desc => 'Complete a puzzle without hints and 100% accuracy.';

  @override
  String get achievement_polyglot_title => 'Polyglot';

  @override
  String get achievement_polyglot_desc => 'Complete puzzles in 3 different languages.';

  @override
  String get achievement_generator_title => 'The Creator';

  @override
  String get achievement_generator_desc => 'Generate and complete 5 custom puzzles.';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get reportProblemSubject => 'Problem Report - Croiz';

  @override
  String get reportProblemBody => '[Describe your problem here]';

  @override
  String get watchAdTitle => 'Watch Ad?';

  @override
  String get watchAdMessage => 'Watch a short ad to get more reveals?';

  @override
  String get revealAllAdMessage => 'To reveal the entire puzzle, you must watch a short ad. Continue?';
}
