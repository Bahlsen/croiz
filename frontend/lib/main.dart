import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/routes/app_router.dart';
import 'package:flutter/services.dart';
import 'package:croiz/features/splash/splash_screen.dart';
import 'package:croiz/core/theme.dart';
import 'package:croiz/services/providers.dart';
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
