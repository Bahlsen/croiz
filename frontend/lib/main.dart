import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/routes/app_router.dart';
import 'package:flutter/services.dart';
import 'package:croiz/features/splash/splash_screen.dart';
import 'package:croiz/core/theme.dart';
import 'package:croiz/services/providers.dart';

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

  void _onInitialized() {
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

    if (!_initialized) {
      return MaterialApp(
        title: 'Croiz',
        theme: _darkTheme,
        darkTheme: _darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(onInitialized: _onInitialized),
      );
    }

    return MaterialApp.router(
      title: 'Croiz',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
