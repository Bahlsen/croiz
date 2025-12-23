import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/routes/app_router.dart';
import 'package:flutter/services.dart';
import 'package:croiz/services/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Create a ProviderContainer so we can eagerly initialize services
  final container = ProviderContainer();
  
  // Performance: Start audio initialization but don't await it.
  // Let the app render while audio loads in the background.
  // First taps may not play sounds, but the UI will be responsive.
  try {
    container.read(gameAudioServiceProvider);
    // Don't await ready - let initialization happen in background
  } on Object catch (e, st) {
    developer.log(
      'GameAudioService initialization failed while waiting in main',
      error: e,
      stackTrace: st,
    );
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const CroizApp()),
  );
}

class CroizApp extends StatelessWidget {
  const CroizApp({Key? key}) : super(key: key);

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
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Croiz',
    theme: _lightTheme,
    darkTheme: _darkTheme,
    themeMode: ThemeMode.dark,
    routerConfig: appRouter,
    debugShowCheckedModeBanner: false,
  );
}
