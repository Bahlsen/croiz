import 'package:flutter/material.dart';
import 'crossword_theme_colors.dart';

class AppTheme {
  static ThemeData lightTheme() => ThemeData(
    useMaterial3: true,
    // Use a seed color but tweak a few container/surface values so
    // small UI elements (keyboard keys, grid cells) have better contrast
    // under the light theme.
    // Use a standard grey scaffold background for light theme.
    scaffoldBackgroundColor: Colors.grey,
    colorScheme:
        (() {
          final base = ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          );
          return base.copyWith(
            // Slightly darker container for keys/cells so alpha overlays are visible
            // For light theme we want keys to be white and text to be black.
            surfaceContainerHighest: Colors.white,
            surfaceContainerHigh: Colors.white,
            surfaceContainer: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          );
        })(),
    typography: Typography.material2021(platform: TargetPlatform.android),
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    // Improve default filled button visuals (used by keys) to be slightly
    // more contrasted on light backgrounds.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    // Provide crossword-specific colors for the light theme as well.
    extensions: const <ThemeExtension<dynamic>>[
      CrosswordThemeColors.lightDefaults,
    ],
  );

  static ThemeData darkTheme() => ThemeData(
    useMaterial3: true,
    // Ensure dark theme uses a true black app background per request
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      brightness: Brightness.dark,
    ),
    typography: Typography.material2021(platform: TargetPlatform.android),
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
    // Provide crossword-specific colors for the dark theme via a ThemeExtension
    // Use `darkDefaults` so normal cells remain white while scaffold is dark.
    extensions: const <ThemeExtension<dynamic>>[
      CrosswordThemeColors.darkDefaults,
    ],
  );
}
