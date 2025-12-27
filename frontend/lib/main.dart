import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/routes/app_router.dart';
import 'package:flutter/services.dart';
import 'package:croiz/features/splash/splash_screen.dart';
import 'package:croiz/core/theme.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const ProviderScope(child: CroizApp()));
}

class CroizApp extends ConsumerStatefulWidget {
  const CroizApp({super.key});

  @override
  ConsumerState<CroizApp> createState() => _CroizAppState();
}

class _CroizAppState extends ConsumerState<CroizApp> {
  bool _initialized = false;

  // Called by the SplashScreen when core initialization completes.
  // Load persisted locale here so the app starts with the user's choice.
  Future<void> _onInitialized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('locale');
      if (saved != null && saved.isNotEmpty) {
        ref.read(localeProvider.notifier).locale = Locale(saved);
      }

      // Load persisted UI preferences
      final isDark = prefs.getBool('pref_is_dark');
      if (isDark != null) {
        ref.read(appIsDarkProvider.notifier).isDark = isDark;
      }

      final azerty = prefs.getBool('pref_keyboard_azerty');
      if (azerty != null) {
        ref.read(gameKeyboardLayoutProvider.notifier).isAzerty = azerty;
      }

      final ksize = prefs.getString('pref_keyboard_size');
      if (ksize != null && ksize.isNotEmpty) {
        try {
          final val = KeyboardSize.values.firstWhere((e) => e.name == ksize);
          ref.read(gameKeyboardSizeProvider.notifier).size = val;
        } on Object {
          // ignore if invalid
        }
      }

      final muted = prefs.getBool('pref_audio_muted');
      if (muted != null) {
        ref.read(gameAudioMutedProvider.notifier).muted = muted;
      }

      // Optionally restore last selected puzzle so progress restoration runs.
      final lastSelected = prefs.getString('last_selected_puzzle');
      if (lastSelected != null && lastSelected.isNotEmpty) {
        ref.read(selectedPuzzleIdProvider.notifier).value = lastSelected;
      }
    } on Exception catch (_) {
      // ignore and continue with default locale
    }

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  // Use centralized app themes from `AppTheme` to ensure consistency.
  static final _lightTheme = AppTheme.lightTheme();
  static final _darkTheme = AppTheme.darkTheme();

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(appIsDarkProvider);
    final locale = ref.watch(localeProvider);

    if (!_initialized) {
      return MaterialApp(
        title: 'Croiz',
        theme: _darkTheme,
        darkTheme: _darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(onInitialized: _onInitialized),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('fr'), Locale('uk')],
      );
    }

    return MaterialApp.router(
      title: 'Croiz',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('uk')],
    );
  }
}
