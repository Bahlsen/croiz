import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('uk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Croiz'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Croiz'**
  String get welcome;

  /// No description provided for @puzzles.
  ///
  /// In en, this message translates to:
  /// **'Puzzles'**
  String get puzzles;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get languageUkrainian;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @selectAWord.
  ///
  /// In en, this message translates to:
  /// **'Select a word'**
  String get selectAWord;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @reveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get reveal;

  /// No description provided for @revealLetterOption.
  ///
  /// In en, this message translates to:
  /// **'Reveal letter'**
  String get revealLetterOption;

  /// No description provided for @revealWordOption.
  ///
  /// In en, this message translates to:
  /// **'Reveal word'**
  String get revealWordOption;

  /// No description provided for @revealAllOption.
  ///
  /// In en, this message translates to:
  /// **'Reveal all'**
  String get revealAllOption;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @clearIncorrectLetters.
  ///
  /// In en, this message translates to:
  /// **'Clear incorrect letters'**
  String get clearIncorrectLetters;

  /// No description provided for @switchKeyboardLayout.
  ///
  /// In en, this message translates to:
  /// **'Switch keyboard layout'**
  String get switchKeyboardLayout;

  /// No description provided for @letterLabel.
  ///
  /// In en, this message translates to:
  /// **'Letter {letter}'**
  String letterLabel(Object letter);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @keyboardSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Keyboard size'**
  String get keyboardSizeLabel;

  /// No description provided for @keyboardStyle.
  ///
  /// In en, this message translates to:
  /// **'Keyboard style'**
  String get keyboardStyle;

  /// No description provided for @muteSounds.
  ///
  /// In en, this message translates to:
  /// **'Mute sounds'**
  String get muteSounds;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @loadingPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Loading puzzle...'**
  String get loadingPuzzle;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading puzzle'**
  String get errorLoading;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Crossword Puzzles'**
  String get subtitle;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready!'**
  String get ready;

  /// No description provided for @loadingSounds.
  ///
  /// In en, this message translates to:
  /// **'Loading sounds...'**
  String get loadingSounds;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get starting;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @azerty.
  ///
  /// In en, this message translates to:
  /// **'AZERTY'**
  String get azerty;

  /// No description provided for @qwerty.
  ///
  /// In en, this message translates to:
  /// **'QWERTY'**
  String get qwerty;

  /// No description provided for @generatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Puzzle Generator'**
  String get generatorTitle;

  /// No description provided for @topicLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic (e.g. Science, Travel...)'**
  String get topicLabel;

  /// No description provided for @topicHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a topic'**
  String get topicHint;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grid Size'**
  String get sizeLabel;

  /// No description provided for @generateButton.
  ///
  /// In en, this message translates to:
  /// **'GENERATE'**
  String get generateButton;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @successMessage.
  ///
  /// In en, this message translates to:
  /// **'Puzzle generated successfully!'**
  String get successMessage;

  /// No description provided for @playButton.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get playButton;

  /// No description provided for @errorTopicMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a topic'**
  String get errorTopicMissing;

  /// No description provided for @quick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get quick;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @continuePlaying.
  ///
  /// In en, this message translates to:
  /// **'Continue Playing'**
  String get continuePlaying;

  /// No description provided for @noPuzzlesInProgress.
  ///
  /// In en, this message translates to:
  /// **'No puzzles in progress'**
  String get noPuzzlesInProgress;

  /// No description provided for @across.
  ///
  /// In en, this message translates to:
  /// **'Across'**
  String get across;

  /// No description provided for @down.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get down;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pro;

  /// No description provided for @semanticCellRowColumn.
  ///
  /// In en, this message translates to:
  /// **'Cell row {row}, column {col}'**
  String semanticCellRowColumn(Object col, Object row);

  /// No description provided for @semanticCellNumber.
  ///
  /// In en, this message translates to:
  /// **'number {number}'**
  String semanticCellNumber(Object number);

  /// No description provided for @semanticCellLetter.
  ///
  /// In en, this message translates to:
  /// **'letter {letter}'**
  String semanticCellLetter(Object letter);

  /// No description provided for @semanticCellEmpty.
  ///
  /// In en, this message translates to:
  /// **'empty'**
  String get semanticCellEmpty;

  /// No description provided for @semanticCellSelected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get semanticCellSelected;

  /// No description provided for @semanticClueAcross.
  ///
  /// In en, this message translates to:
  /// **'Across: {clue}'**
  String semanticClueAcross(Object clue);

  /// No description provided for @semanticClueDown.
  ///
  /// In en, this message translates to:
  /// **'Down: {clue}'**
  String semanticClueDown(Object clue);

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @revealAllConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reveal All'**
  String get revealAllConfirmationTitle;

  /// No description provided for @revealAllConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reveal the entire puzzle?'**
  String get revealAllConfirmationMessage;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @completedFilter.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedFilter;

  /// No description provided for @deletePuzzle.
  ///
  /// In en, this message translates to:
  /// **'Delete Generated Puzzle'**
  String get deletePuzzle;

  /// No description provided for @deletePuzzleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this puzzle? This action cannot be undone.'**
  String get deletePuzzleConfirmation;

  /// No description provided for @deleteSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Puzzle deleted successfully'**
  String get deleteSuccessMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'A modern crossword puzzle game with AI-powered generation, multiple languages, and beautiful design.'**
  String get appDescription;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @howToPlayBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get howToPlayBasics;

  /// No description provided for @helpBasic1.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell to select it and see the clue'**
  String get helpBasic1;

  /// No description provided for @helpBasic2.
  ///
  /// In en, this message translates to:
  /// **'Type letters using the on-screen keyboard or your device keyboard'**
  String get helpBasic2;

  /// No description provided for @helpBasic3.
  ///
  /// In en, this message translates to:
  /// **'Tap the selected cell again to switch between across/down'**
  String get helpBasic3;

  /// No description provided for @helpBasic4.
  ///
  /// In en, this message translates to:
  /// **'Completed words turn green automatically'**
  String get helpBasic4;

  /// No description provided for @controls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get controls;

  /// No description provided for @helpControl1.
  ///
  /// In en, this message translates to:
  /// **'Tap cells to navigate the grid'**
  String get helpControl1;

  /// No description provided for @helpControl2.
  ///
  /// In en, this message translates to:
  /// **'Use arrow buttons to move between cells'**
  String get helpControl2;

  /// No description provided for @helpControl3.
  ///
  /// In en, this message translates to:
  /// **'Backspace deletes the current letter'**
  String get helpControl3;

  /// No description provided for @helpControl4.
  ///
  /// In en, this message translates to:
  /// **'Menu button (⋮) opens settings'**
  String get helpControl4;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @helpFeature1.
  ///
  /// In en, this message translates to:
  /// **'🔍 Reveal: Show letters for a word or the entire puzzle'**
  String get helpFeature1;

  /// No description provided for @helpFeature2.
  ///
  /// In en, this message translates to:
  /// **'🔄 Reset: Clear all your answers and start over'**
  String get helpFeature2;

  /// No description provided for @helpFeature3.
  ///
  /// In en, this message translates to:
  /// **'🎨 Themes: Switch between light and dark mode'**
  String get helpFeature3;

  /// No description provided for @helpFeature4.
  ///
  /// In en, this message translates to:
  /// **'🌍 Languages: Play puzzles in multiple languages'**
  String get helpFeature4;

  /// No description provided for @helpFeature5.
  ///
  /// In en, this message translates to:
  /// **'✨ Generate: Create custom puzzles'**
  String get helpFeature5;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @helpTip1.
  ///
  /// In en, this message translates to:
  /// **'Start with shorter words - they\'re usually easier'**
  String get helpTip1;

  /// No description provided for @helpTip2.
  ///
  /// In en, this message translates to:
  /// **'Look for common letter patterns and word endings'**
  String get helpTip2;

  /// No description provided for @helpTip3.
  ///
  /// In en, this message translates to:
  /// **'Use crossing words to help solve difficult clues'**
  String get helpTip3;

  /// No description provided for @helpTip4.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved automatically'**
  String get helpTip4;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No puzzles found'**
  String get noResults;

  /// No description provided for @noResultsDesc.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters.'**
  String get noResultsDesc;

  /// No description provided for @zeroPuzzles.
  ///
  /// In en, this message translates to:
  /// **'No puzzles yet'**
  String get zeroPuzzles;

  /// No description provided for @zeroPuzzlesDesc.
  ///
  /// In en, this message translates to:
  /// **'Select a puzzle to start playing!'**
  String get zeroPuzzlesDesc;

  /// No description provided for @generateFirst.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get generateFirst;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Croiz'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Play thousands of crosswords from top publishers.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingBasicTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get onboardingBasicTitle;

  /// No description provided for @onboardingBasicDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap any cell to select it, then type letters to fill the grid.'**
  String get onboardingBasicDesc;

  /// No description provided for @onboardingDirectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch Direction'**
  String get onboardingDirectionTitle;

  /// No description provided for @onboardingDirectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the selected cell again (or double-tap) to switch between Across and Down.'**
  String get onboardingDirectionDesc;

  /// No description provided for @onboardingCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Word Completion'**
  String get onboardingCompletionTitle;

  /// No description provided for @onboardingCompletionDesc.
  ///
  /// In en, this message translates to:
  /// **'When a word is correct, it will glow green. Finish the whole puzzle for a celebration!'**
  String get onboardingCompletionDesc;

  /// No description provided for @onboardingFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get onboardingFinishTitle;

  /// No description provided for @onboardingFinishDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose from thousands of puzzles in multiple languages.'**
  String get onboardingFinishDesc;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingDone.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingDone;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @totalPuzzles.
  ///
  /// In en, this message translates to:
  /// **'Total Puzzles'**
  String get totalPuzzles;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @recentCompletions.
  ///
  /// In en, this message translates to:
  /// **'Recent Completions'**
  String get recentCompletions;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @hints.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get hints;

  /// No description provided for @statsSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get statsSummary;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @weeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivity;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Day} other{{count} Days}}'**
  String dayStreak(int count);

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @achievement_firstPuzzle_title.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get achievement_firstPuzzle_title;

  /// No description provided for @achievement_firstPuzzle_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first crossword puzzle.'**
  String get achievement_firstPuzzle_desc;

  /// No description provided for @achievement_tenPuzzles_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Solver'**
  String get achievement_tenPuzzles_title;

  /// No description provided for @achievement_tenPuzzles_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 crossword puzzles.'**
  String get achievement_tenPuzzles_desc;

  /// No description provided for @achievement_hundredPuzzles_title.
  ///
  /// In en, this message translates to:
  /// **'Crossword Master'**
  String get achievement_hundredPuzzles_title;

  /// No description provided for @achievement_hundredPuzzles_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 crossword puzzles.'**
  String get achievement_hundredPuzzles_desc;

  /// No description provided for @achievement_weekStreak_title.
  ///
  /// In en, this message translates to:
  /// **'On Fire!'**
  String get achievement_weekStreak_title;

  /// No description provided for @achievement_weekStreak_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep a 7-day completion streak.'**
  String get achievement_weekStreak_desc;

  /// No description provided for @achievement_monthStreak_title.
  ///
  /// In en, this message translates to:
  /// **'Unstoppable'**
  String get achievement_monthStreak_title;

  /// No description provided for @achievement_monthStreak_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep a 30-day completion streak.'**
  String get achievement_monthStreak_desc;

  /// No description provided for @achievement_speedDemon_title.
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get achievement_speedDemon_title;

  /// No description provided for @achievement_speedDemon_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete a puzzle in under 3 minutes.'**
  String get achievement_speedDemon_desc;

  /// No description provided for @achievement_perfectPuzzle_title.
  ///
  /// In en, this message translates to:
  /// **'Perfect Play'**
  String get achievement_perfectPuzzle_title;

  /// No description provided for @achievement_perfectPuzzle_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete a puzzle without hints and 100% accuracy.'**
  String get achievement_perfectPuzzle_desc;

  /// No description provided for @achievement_polyglot_title.
  ///
  /// In en, this message translates to:
  /// **'Polyglot'**
  String get achievement_polyglot_title;

  /// No description provided for @achievement_polyglot_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete puzzles in 3 different languages.'**
  String get achievement_polyglot_desc;

  /// No description provided for @achievement_generator_title.
  ///
  /// In en, this message translates to:
  /// **'The Creator'**
  String get achievement_generator_title;

  /// No description provided for @achievement_generator_desc.
  ///
  /// In en, this message translates to:
  /// **'Generate and complete 5 custom puzzles.'**
  String get achievement_generator_desc;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAds;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblem;

  /// No description provided for @reportProblemSubject.
  ///
  /// In en, this message translates to:
  /// **'Problem Report - Croiz'**
  String get reportProblemSubject;

  /// No description provided for @reportProblemBody.
  ///
  /// In en, this message translates to:
  /// **'[Describe your problem here]'**
  String get reportProblemBody;

  /// No description provided for @watchAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad?'**
  String get watchAdTitle;

  /// No description provided for @watchAdMessage.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to get more reveals?'**
  String get watchAdMessage;

  /// No description provided for @revealAllAdMessage.
  ///
  /// In en, this message translates to:
  /// **'To reveal the entire puzzle, you must watch a short ad. Continue?'**
  String get revealAllAdMessage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'pt', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'pt': return AppLocalizationsPt();
    case 'uk': return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
