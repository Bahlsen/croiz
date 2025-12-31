import 'package:sizer/sizer.dart';

/// Extension methods for responsive sizing using sizer package.
/// This module provides consistent responsive sizing utilities across the app.
///
/// Usage:
/// - `.h` - percentage of screen height (e.g., 50.h = 50% of height)
/// - `.w` - percentage of screen width (e.g., 50.w = 50% of width)
/// - `.sp` - scaled pixels for text (respects screen density)
/// - `.dp` - device-independent pixels

/// Responsive spacing constants based on screen percentage.
class ResponsiveSpacing {
  ResponsiveSpacing._();

  /// Extra small spacing (0.5% of screen height)
  static double get xs => 0.5.h;

  /// Small spacing (1% of screen height)
  static double get sm => 1.h;

  /// Medium spacing (2% of screen height)
  static double get md => 2.h;

  /// Large spacing (3% of screen height)
  static double get lg => 3.h;

  /// Extra large spacing (4% of screen height)
  static double get xl => 4.h;

  /// Extra extra large spacing (6% of screen height)
  static double get xxl => 6.h;
}

/// Responsive font sizes based on screen percentage.
class ResponsiveFontSize {
  ResponsiveFontSize._();

  /// Caption text size
  static double get caption => 10.sp;

  /// Body small text size
  static double get bodySmall => 12.sp;

  /// Body medium text size
  static double get bodyMedium => 14.sp;

  /// Body large text size
  static double get bodyLarge => 16.sp;

  /// Title small text size
  static double get titleSmall => 18.sp;

  /// Title medium text size
  static double get titleMedium => 20.sp;

  /// Title large text size
  static double get titleLarge => 22.sp;

  /// Headline small text size
  static double get headlineSmall => 24.sp;

  /// Headline medium text size
  static double get headlineMedium => 28.sp;

  /// Headline large text size
  static double get headlineLarge => 32.sp;

  /// Display small text size
  static double get displaySmall => 36.sp;

  /// Display medium text size
  static double get displayMedium => 45.sp;

  /// Display large text size
  static double get displayLarge => 57.sp;
}

/// Responsive icon sizes.
class ResponsiveIconSize {
  ResponsiveIconSize._();

  /// Extra small icon (3% of screen width)
  static double get xs => 3.w;

  /// Small icon (4% of screen width)
  static double get sm => 4.w;

  /// Medium icon (5% of screen width)
  static double get md => 5.w;

  /// Large icon (6% of screen width)
  static double get lg => 6.w;

  /// Extra large icon (8% of screen width)
  static double get xl => 8.w;
}

/// Responsive padding values.
class ResponsivePadding {
  ResponsivePadding._();

  /// Extra small padding (0.5% of screen width)
  static double get xs => 0.5.w;

  /// Small padding (1% of screen width)
  static double get sm => 1.w;

  /// Medium padding (2% of screen width)
  static double get md => 2.w;

  /// Large padding (3% of screen width)
  static double get lg => 3.w;

  /// Extra large padding (4% of screen width)
  static double get xl => 4.w;
}

/// Responsive border radius values.
class ResponsiveBorderRadius {
  ResponsiveBorderRadius._();

  /// Extra small radius (0.5% of screen width)
  static double get xs => 0.5.w;

  /// Small radius (1% of screen width)
  static double get sm => 1.w;

  /// Medium radius (2% of screen width)
  static double get md => 2.w;

  /// Large radius (3% of screen width)
  static double get lg => 3.w;

  /// Extra large radius (4% of screen width)
  static double get xl => 4.w;
}

/// Responsive button dimensions.
class ResponsiveButton {
  ResponsiveButton._();

  /// Small button height (5% of screen height)
  static double get heightSmall => 5.h;

  /// Medium button height (6% of screen height)
  static double get heightMedium => 6.h;

  /// Large button height (7% of screen height)
  static double get heightLarge => 7.h;

  /// Minimum touch target size (48dp as per accessibility guidelines)
  static double get minTouchTarget => 12.w;
}

/// Responsive keyboard dimensions for the virtual keyboard.
class ResponsiveKeyboard {
  ResponsiveKeyboard._();

  /// Small key height
  static double get keyHeightSmall => 5.5.h;

  /// Medium key height
  static double get keyHeightMedium => 7.h;

  /// Large key height
  static double get keyHeightLarge => 9.h;

  /// Small letter font size
  static double get letterFontSmall => 12.sp;

  /// Medium letter font size
  static double get letterFontMedium => 14.sp;

  /// Large letter font size
  static double get letterFontLarge => 17.sp;
}

/// Responsive grid dimensions for the crossword grid.
class ResponsiveGrid {
  ResponsiveGrid._();

  /// Cell spacing (0.4% of screen width)
  static double get cellSpacing => 0.4.w;

  /// Cell border width
  static double get borderWidth => 0.25.w;
}

/// Responsive overlay dimensions.
class ResponsiveOverlay {
  ResponsiveOverlay._();

  /// Dialog width (80% of screen width, max 300)
  static double get dialogWidth => 80.w.clamp(250, 350);

  /// Dialog padding
  static double get dialogPadding => 5.w;
}
