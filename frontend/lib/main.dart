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
  // Ensure audio service has a chance to preload assets before first input.
  try {
    final audioService = container.read(gameAudioServiceProvider);
    // Wait for initialization to complete (success or failure) so first taps can play.
    await audioService.ready;
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

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Croiz',
    theme: ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    ),
    darkTheme: ThemeData.dark().copyWith(
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
    ),
    themeMode: ThemeMode.dark,
    routerConfig: appRouter,
    debugShowCheckedModeBanner: false,
  );
}
