// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Кроіз';

  @override
  String get welcome => 'Ласкаво просимо до Кроіз';

  @override
  String get puzzles => 'Головоломки';

  @override
  String get languageEnglish => 'Англійська';

  @override
  String get languageFrench => 'Французька';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get selectLanguage => 'Виберіть мову';

  @override
  String get selectAWord => 'Виберіть слово';

  @override
  String get menu => 'Меню';

  @override
  String get clear => 'Очистити';

  @override
  String get close => 'Закрити';

  @override
  String get restart => 'Почати спочатку';

  @override
  String get view => 'Переглянути';

  @override
  String get reveal => 'Розкрити';

  @override
  String get revealLetterOption => 'Розкрити літеру';

  @override
  String get revealWordOption => 'Розкрити слово';

  @override
  String get revealAllOption => 'Розкрити все';

  @override
  String get congratulations => 'Вітаємо!';

  @override
  String get loading => 'Завантаження...';

  @override
  String get clearIncorrectLetters => 'Очистити неправильні літери';

  @override
  String get switchKeyboardLayout => 'Змінити розклад клавіатури';

  @override
  String letterLabel(Object letter) {
    return 'Літера $letter';
  }

  @override
  String get delete => 'Видалити';

  @override
  String get home => 'Головна';

  @override
  String get keyboardSizeLabel => 'Розмір клавіатури';

  @override
  String get keyboardStyle => 'Стиль клавіатури';

  @override
  String get muteSounds => 'Відключити звук';

  @override
  String get darkTheme => 'Темна тема';

  @override
  String get help => 'Допомога';

  @override
  String get about => 'Про додаток';

  @override
  String get loadingPuzzle => 'Завантаження...';

  @override
  String get pleaseWait => 'Зачекайте будь ласка';

  @override
  String get errorLoading => 'Помилка завантаження';

  @override
  String get subtitle => 'Кросворди';

  @override
  String get ready => 'Готово!';

  @override
  String get loadingSounds => 'Завантаження звуків...';

  @override
  String get starting => 'Запуск...';

  @override
  String get small => 'Малий';

  @override
  String get medium => 'Середньо';

  @override
  String get large => 'Великий';

  @override
  String get azerty => 'AZERTY';

  @override
  String get qwerty => 'QWERTY';

  @override
  String get generatorTitle => 'Генератор головоломок';

  @override
  String get topicLabel => 'Тема (напр. Наука, Подорожі...)';

  @override
  String get topicHint => 'Введіть тему';

  @override
  String get languageLabel => 'Мова';

  @override
  String get difficultyLabel => 'Складність';

  @override
  String get sizeLabel => 'Розмір сітки';

  @override
  String get generateButton => 'ЗГЕНЕРУВАТИ';

  @override
  String get generating => 'Генерація...';

  @override
  String get successMessage => 'Головоломку успішно створено!';

  @override
  String get playButton => 'ГРАТИ';

  @override
  String get errorTopicMissing => 'Будь ласка, введіть тему';

  @override
  String get quick => 'Швидкий';

  @override
  String get standard => 'Стандартний';

  @override
  String get continuePlaying => 'Продовжити';

  @override
  String get noPuzzlesInProgress => 'Немає розпочатих головоломок';

  @override
  String get across => 'По горизонталі';

  @override
  String get down => 'По вертикалі';

  @override
  String get easy => 'Легко';

  @override
  String get hard => 'Складно';

  @override
  String get expert => 'Експерт';

  @override
  String get pro => 'Професійно';

  @override
  String semanticCellRowColumn(Object col, Object row) {
    return 'Комірка рядок $row, стовпчик $col';
  }

  @override
  String semanticCellNumber(Object number) {
    return 'номер $number';
  }

  @override
  String semanticCellLetter(Object letter) {
    return 'літера $letter';
  }

  @override
  String get semanticCellEmpty => 'пусто';

  @override
  String get semanticCellSelected => 'вибрано';

  @override
  String semanticClueAcross(Object clue) {
    return 'По горизонталі: $clue';
  }

  @override
  String semanticClueDown(Object clue) {
    return 'По вертикалі: $clue';
  }

  @override
  String get clearFilters => 'Очистити фільтри';

  @override
  String get revealAllConfirmationTitle => 'Підтвердити розкриття всього';

  @override
  String get revealAllConfirmationMessage =>
      'Ви впевнені, що хочете розкрити весь кросворд?';

  @override
  String get yes => 'Так';

  @override
  String get no => 'Ні';

  @override
  String get completedFilter => 'Завершені';

  @override
  String get deletePuzzle => 'Видалити згенеровану головоломку';

  @override
  String get deletePuzzleConfirmation =>
      'Ви впевнені, що хочете видалити цю головоломку? Цю дію неможливо скасувати.';

  @override
  String get deleteSuccessMessage => 'Головоломку успішно видалено';

  @override
  String get cancel => 'Скасувати';

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
