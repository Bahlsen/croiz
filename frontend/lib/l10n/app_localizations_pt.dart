// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Croiz';

  @override
  String get welcome => 'Bem-vindo ao Croiz';

  @override
  String get puzzles => 'Puzzles';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageUkrainian => 'Ucraniano';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get selectAWord => 'Selecionar uma palavra';

  @override
  String get menu => 'Menu';

  @override
  String get clear => 'Limpar';

  @override
  String get close => 'Fechar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get view => 'Ver';

  @override
  String get reveal => 'Revelar';

  @override
  String get revealLetterOption => 'Revelar letra';

  @override
  String get revealWordOption => 'Revelar palavra';

  @override
  String get revealAllOption => 'Revelar tudo';

  @override
  String get congratulations => 'Parabéns!';

  @override
  String get loading => 'Carregando...';

  @override
  String get clearIncorrectLetters => 'Limpar letras incorretas';

  @override
  String get switchKeyboardLayout => 'Alterar layout do teclado';

  @override
  String letterLabel(Object letter) {
    return 'Letra $letter';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get home => 'Início';

  @override
  String get keyboardSizeLabel => 'Tamanho do teclado';

  @override
  String get keyboardStyle => 'Estilo do teclado';

  @override
  String get muteSounds => 'Sem som';

  @override
  String get darkTheme => 'Tema escuro';

  @override
  String get help => 'Ajuda';

  @override
  String get about => 'Sobre';

  @override
  String get loadingPuzzle => 'Carregando puzzle...';

  @override
  String get pleaseWait => 'Por favor aguarde';

  @override
  String get errorLoading => 'Erro ao carregar o puzzle';

  @override
  String get subtitle => 'Palavras Cruzadas';

  @override
  String get ready => 'Pronto!';

  @override
  String get loadingSounds => 'Carregando sons...';

  @override
  String get starting => 'Iniciando...';

  @override
  String get small => 'Pequeno';

  @override
  String get medium => 'Médio';

  @override
  String get large => 'Grande';

  @override
  String get azerty => 'AZERTY';

  @override
  String get qwerty => 'QWERTY';

  @override
  String get generatorTitle => 'Gerador de Puzzles';

  @override
  String get topicLabel => 'Tópico (ex: Ciência, Viagens...)';

  @override
  String get topicHint => 'Digite um tópico';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get difficultyLabel => 'Dificuldade';

  @override
  String get sizeLabel => 'Tamanho da grade';

  @override
  String get generateButton => 'GERAR';

  @override
  String get generating => 'Gerando...';

  @override
  String get successMessage => 'Puzzle gerado com sucesso!';

  @override
  String get playButton => 'JOGAR';

  @override
  String get errorTopicMissing => 'Por favor, digite um tópico';

  @override
  String get quick => 'Rápido';

  @override
  String get standard => 'Padrão';

  @override
  String get continuePlaying => 'Continuar jogando';

  @override
  String get noPuzzlesInProgress => 'Nenhum puzzle em andamento';

  @override
  String get across => 'Horizontal';

  @override
  String get down => 'Vertical';

  @override
  String get easy => 'Fácil';

  @override
  String get hard => 'Difícil';

  @override
  String get expert => 'Expert';

  @override
  String get pro => 'Pro';

  @override
  String semanticCellRowColumn(Object col, Object row) {
    return 'Célula linha $row, coluna $col';
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
  String get semanticCellEmpty => 'vazia';

  @override
  String get semanticCellSelected => 'selecionada';

  @override
  String semanticClueAcross(Object clue) {
    return 'Horizontal: $clue';
  }

  @override
  String semanticClueDown(Object clue) {
    return 'Vertical: $clue';
  }

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get revealAllConfirmationTitle => 'Confirmar Revelar Tudo';

  @override
  String get revealAllConfirmationMessage => 'Tem certeza de que deseja revelar todo o puzzle?';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get completedFilter => 'Concluído';

  @override
  String get deletePuzzle => 'Excluir Puzzle Gerado';

  @override
  String get deletePuzzleConfirmation => 'Tem certeza de que deseja excluir este puzzle? Esta ação não pode ser desfeita.';

  @override
  String get deleteSuccessMessage => 'Puzzle excluído com sucesso';

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
}
