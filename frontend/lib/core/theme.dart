import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'crossword_theme_colors.dart';

class AppTheme {
  /// Creates a custom text theme combining Outfit (headings) and Inter (body).
  /// This gives the app a modern, premium feel distinct from default Material.
  static TextTheme _buildTextTheme(TextTheme base) => base.copyWith(
    // Display styles - Outfit (large, impactful text)
    displayLarge: GoogleFonts.outfit(textStyle: base.displayLarge),
    displayMedium: GoogleFonts.outfit(textStyle: base.displayMedium),
    displaySmall: GoogleFonts.outfit(textStyle: base.displaySmall),

    // Headline styles - Outfit (section headers, titles)
    headlineLarge: GoogleFonts.outfit(textStyle: base.headlineLarge),
    headlineMedium: GoogleFonts.outfit(textStyle: base.headlineMedium),
    headlineSmall: GoogleFonts.outfit(textStyle: base.headlineSmall),

    // Title styles - Outfit (card titles, list items)
    titleLarge: GoogleFonts.outfit(textStyle: base.titleLarge),
    titleMedium: GoogleFonts.outfit(textStyle: base.titleMedium),
    titleSmall: GoogleFonts.outfit(textStyle: base.titleSmall),

    // Body styles - Inter (main content, readable text)
    bodyLarge: GoogleFonts.inter(textStyle: base.bodyLarge),
    bodyMedium: GoogleFonts.inter(textStyle: base.bodyMedium),
    bodySmall: GoogleFonts.inter(textStyle: base.bodySmall),

    // Label styles - Inter (buttons, chips, small UI elements)
    labelLarge: GoogleFonts.inter(textStyle: base.labelLarge),
    labelMedium: GoogleFonts.inter(textStyle: base.labelMedium),
    labelSmall: GoogleFonts.inter(textStyle: base.labelSmall),
  );

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
    textTheme: _buildTextTheme(
      Typography.material2021(platform: TargetPlatform.android).black,
    ),
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
    textTheme: _buildTextTheme(
      Typography.material2021(platform: TargetPlatform.android).white,
    ),
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
    // Provide crossword-specific colors for the dark theme via a ThemeExtension
    // Use `darkDefaults` so normal cells remain white while scaffold is dark.
    extensions: const <ThemeExtension<dynamic>>[
      CrosswordThemeColors.darkDefaults,
    ],
  );
}
