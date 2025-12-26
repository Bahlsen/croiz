// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Croiz';

  @override
  String get welcome => 'Welcome to Croiz';

  @override
  String get puzzles => 'Puzzles';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageUkrainian => 'Ukrainian';

  @override
  String get selectLanguage => 'Select language';
}
