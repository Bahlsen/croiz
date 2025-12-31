import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/core/responsive/responsive_extensions.dart';

void main() {
  group('ResponsiveSpacing', () {
    testWidgets('provides consistent spacing values', (tester) async {
      // Set up a medium-sized device (400x800)
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      // Verify spacing values are computed (not zero)
      expect(ResponsiveSpacing.xs, greaterThan(0));
      expect(ResponsiveSpacing.sm, greaterThan(0));
      expect(ResponsiveSpacing.md, greaterThan(0));
      expect(ResponsiveSpacing.lg, greaterThan(0));
      expect(ResponsiveSpacing.xl, greaterThan(0));
      expect(ResponsiveSpacing.xxl, greaterThan(0));

      // Verify ordering (smaller values should be smaller than larger)
      expect(ResponsiveSpacing.xs, lessThan(ResponsiveSpacing.sm));
      expect(ResponsiveSpacing.sm, lessThan(ResponsiveSpacing.md));
      expect(ResponsiveSpacing.md, lessThan(ResponsiveSpacing.lg));
      expect(ResponsiveSpacing.lg, lessThan(ResponsiveSpacing.xl));
      expect(ResponsiveSpacing.xl, lessThan(ResponsiveSpacing.xxl));
    });
  });

  group('ResponsiveFontSize', () {
    testWidgets('provides consistent font size values', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      // Verify font sizes are computed (not zero)
      expect(ResponsiveFontSize.caption, greaterThan(0));
      expect(ResponsiveFontSize.bodySmall, greaterThan(0));
      expect(ResponsiveFontSize.bodyMedium, greaterThan(0));
      expect(ResponsiveFontSize.bodyLarge, greaterThan(0));
      expect(ResponsiveFontSize.titleSmall, greaterThan(0));
      expect(ResponsiveFontSize.titleMedium, greaterThan(0));
      expect(ResponsiveFontSize.titleLarge, greaterThan(0));
      expect(ResponsiveFontSize.headlineSmall, greaterThan(0));
      expect(ResponsiveFontSize.headlineMedium, greaterThan(0));
      expect(ResponsiveFontSize.headlineLarge, greaterThan(0));
      expect(ResponsiveFontSize.displaySmall, greaterThan(0));
      expect(ResponsiveFontSize.displayMedium, greaterThan(0));
      expect(ResponsiveFontSize.displayLarge, greaterThan(0));

      // Verify ordering (smaller categories should be smaller than larger)
      expect(ResponsiveFontSize.caption, lessThan(ResponsiveFontSize.bodySmall));
      expect(
        ResponsiveFontSize.bodySmall,
        lessThan(ResponsiveFontSize.bodyMedium),
      );
      expect(
        ResponsiveFontSize.bodyMedium,
        lessThan(ResponsiveFontSize.bodyLarge),
      );
      expect(
        ResponsiveFontSize.bodyLarge,
        lessThan(ResponsiveFontSize.titleSmall),
      );
      expect(
        ResponsiveFontSize.headlineSmall,
        lessThan(ResponsiveFontSize.headlineMedium),
      );
      expect(
        ResponsiveFontSize.displaySmall,
        lessThan(ResponsiveFontSize.displayMedium),
      );
    });
  });

  group('ResponsiveIconSize', () {
    testWidgets('provides consistent icon size values', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      // Verify icon sizes are computed (not zero)
      expect(ResponsiveIconSize.xs, greaterThan(0));
      expect(ResponsiveIconSize.sm, greaterThan(0));
      expect(ResponsiveIconSize.md, greaterThan(0));
      expect(ResponsiveIconSize.lg, greaterThan(0));
      expect(ResponsiveIconSize.xl, greaterThan(0));

      // Verify ordering
      expect(ResponsiveIconSize.xs, lessThan(ResponsiveIconSize.sm));
      expect(ResponsiveIconSize.sm, lessThan(ResponsiveIconSize.md));
      expect(ResponsiveIconSize.md, lessThan(ResponsiveIconSize.lg));
      expect(ResponsiveIconSize.lg, lessThan(ResponsiveIconSize.xl));
    });
  });

  group('ResponsivePadding', () {
    testWidgets('provides consistent padding values', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      // Verify padding values are computed (not zero)
      expect(ResponsivePadding.xs, greaterThan(0));
      expect(ResponsivePadding.sm, greaterThan(0));
      expect(ResponsivePadding.md, greaterThan(0));
      expect(ResponsivePadding.lg, greaterThan(0));
      expect(ResponsivePadding.xl, greaterThan(0));

      // Verify ordering
      expect(ResponsivePadding.xs, lessThan(ResponsivePadding.sm));
      expect(ResponsivePadding.sm, lessThan(ResponsivePadding.md));
      expect(ResponsivePadding.md, lessThan(ResponsivePadding.lg));
      expect(ResponsivePadding.lg, lessThan(ResponsivePadding.xl));
    });
  });

  group('ResponsiveBorderRadius', () {
    testWidgets('provides consistent border radius values', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      // Verify border radius values are computed (not zero)
      expect(ResponsiveBorderRadius.xs, greaterThan(0));
      expect(ResponsiveBorderRadius.sm, greaterThan(0));
      expect(ResponsiveBorderRadius.md, greaterThan(0));
      expect(ResponsiveBorderRadius.lg, greaterThan(0));
      expect(ResponsiveBorderRadius.xl, greaterThan(0));

      // Verify ordering
      expect(ResponsiveBorderRadius.xs, lessThan(ResponsiveBorderRadius.sm));
      expect(ResponsiveBorderRadius.sm, lessThan(ResponsiveBorderRadius.md));
      expect(ResponsiveBorderRadius.md, lessThan(ResponsiveBorderRadius.lg));
      expect(ResponsiveBorderRadius.lg, lessThan(ResponsiveBorderRadius.xl));
    });
  });

  group('ResponsiveButton', () {
    testWidgets('provides consistent button dimensions', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      // Verify button heights are computed (not zero)
      expect(ResponsiveButton.heightSmall, greaterThan(0));
      expect(ResponsiveButton.heightMedium, greaterThan(0));
      expect(ResponsiveButton.heightLarge, greaterThan(0));
      expect(ResponsiveButton.minTouchTarget, greaterThan(0));

      // Verify ordering
      expect(
        ResponsiveButton.heightSmall,
        lessThan(ResponsiveButton.heightMedium),
      );
      expect(
        ResponsiveButton.heightMedium,
        lessThan(ResponsiveButton.heightLarge),
      );
    });
  });

  group('ResponsiveKeyboard', () {
    testWidgets('provides consistent keyboard dimensions', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      // Verify keyboard heights
      expect(ResponsiveKeyboard.keyHeightSmall, greaterThan(0));
      expect(ResponsiveKeyboard.keyHeightMedium, greaterThan(0));
      expect(ResponsiveKeyboard.keyHeightLarge, greaterThan(0));

      // Verify keyboard font sizes
      expect(ResponsiveKeyboard.letterFontSmall, greaterThan(0));
      expect(ResponsiveKeyboard.letterFontMedium, greaterThan(0));
      expect(ResponsiveKeyboard.letterFontLarge, greaterThan(0));

      // Verify ordering for heights
      expect(
        ResponsiveKeyboard.keyHeightSmall,
        lessThan(ResponsiveKeyboard.keyHeightMedium),
      );
      expect(
        ResponsiveKeyboard.keyHeightMedium,
        lessThan(ResponsiveKeyboard.keyHeightLarge),
      );

      // Verify ordering for font sizes
      expect(
        ResponsiveKeyboard.letterFontSmall,
        lessThan(ResponsiveKeyboard.letterFontMedium),
      );
      expect(
        ResponsiveKeyboard.letterFontMedium,
        lessThan(ResponsiveKeyboard.letterFontLarge),
      );
    });
  });

  group('ResponsiveGrid', () {
    testWidgets('provides consistent grid dimensions', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      expect(ResponsiveGrid.cellSpacing, greaterThan(0));
      expect(ResponsiveGrid.borderWidth, greaterThan(0));
    });
  });

  group('ResponsiveOverlay', () {
    testWidgets('provides consistent overlay dimensions', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      expect(ResponsiveOverlay.dialogWidth, greaterThan(0));
      expect(ResponsiveOverlay.dialogPadding, greaterThan(0));
      // Dialog width should be reasonable (between 250-350)
      expect(ResponsiveOverlay.dialogWidth, greaterThanOrEqualTo(250));
      expect(ResponsiveOverlay.dialogWidth, lessThanOrEqualTo(350));
    });
  });

  group('Screen size adaptability', () {
    testWidgets('values scale with different screen sizes', (tester) async {
      // Test with a small screen (320x480)
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      final smallScreenSpacing = ResponsiveSpacing.md;
      final smallScreenFontSize = ResponsiveFontSize.bodyMedium;

      // Reset to larger screen (800x1200)
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, screenType) => const MaterialApp(
            home: Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      final largeScreenSpacing = ResponsiveSpacing.md;
      final largeScreenFontSize = ResponsiveFontSize.bodyMedium;

      // Values should scale with screen size
      // (larger screen = larger absolute values for percentage-based sizes)
      expect(largeScreenSpacing, greaterThan(smallScreenSpacing));
      // Font sizes are based on sp which may not scale linearly with screen size
      // but should still be reasonable values
      expect(smallScreenFontSize, greaterThan(0));
      expect(largeScreenFontSize, greaterThan(0));

      // Reset view size to avoid affecting other tests
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
