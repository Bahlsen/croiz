import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/routes/app_router.dart';
import 'package:flutter/services.dart';
import 'package:croiz/features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const ProviderScope(child: CroizApp()));
}

class CroizApp extends StatefulWidget {
  const CroizApp({super.key});

  @override
  State<CroizApp> createState() => _CroizAppState();
}

class _CroizAppState extends State<CroizApp> {
  bool _initialized = false;

  void _onInitialized() {
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  // Performance: cache theme data to avoid recreation on every build
  static final _lightTheme = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );

  static final _darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
  );

  @override
  Widget build(BuildContext context) {
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
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
