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
  String get revealAllConfirmationMessage => 'Ви впевнені, що хочете розкрити весь кросворд?';

  @override
  String get yes => 'Так';

  @override
  String get no => 'Ні';
}
