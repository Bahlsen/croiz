// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

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
  String get selectAWord => 'Select a word';

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
  String get medium => 'Середній';

  @override
  String get large => 'Великий';

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
  String get standard => 'Стандарт';

  @override
  String get continuePlaying => 'Продовжити гру';

  @override
  String get noPuzzlesInProgress => 'Немає розпочатих кросвордів';
}
