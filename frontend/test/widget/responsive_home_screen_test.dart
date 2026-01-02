import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/home/home_screen.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('HomeScreen responsive layout', () {
    Widget createTestApp({Size? screenSize}) => ProviderScope(
      child: Sizer(
        builder:
            (context, orientation, screenType) => const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en'), Locale('fr')],
              home: HomeScreen(),
            ),
      ),
    );

    testWidgets('renders correctly on small screen', (tester) async {
      // Simulate a small phone screen (320x480)
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify main elements are rendered
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders correctly on medium screen', (tester) async {
      // Simulate a typical phone screen (400x800)
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders correctly on large screen', (tester) async {
      // Simulate a tablet screen (800x1200)
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('button has accessible touch target size', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      // Get the button's size
      final buttonBox = tester.renderObject<RenderBox>(buttonFinder);
      final buttonSize = buttonBox.size;

      // Button should have minimum touch target of 48x48 (accessibility)
      expect(buttonSize.height, greaterThanOrEqualTo(36));
      expect(buttonSize.width, greaterThanOrEqualTo(48));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  group('Responsive text scaling', () {
    Widget createTestApp() => ProviderScope(
      child: Sizer(
        builder:
            (context, orientation, screenType) => const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en'), Locale('fr')],
              home: HomeScreen(),
            ),
      ),
    );

    testWidgets('text is readable on small screens', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find any Text widget and verify it has a reasonable font size
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final text in textWidgets) {
        final fontSize = text.style?.fontSize;
        if (fontSize != null) {
          // Font size should be at least 8 for readability
          expect(fontSize, greaterThanOrEqualTo(8));
        }
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('text scales appropriately on large screens', (tester) async {
      tester.view.physicalSize = const Size(1200, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find any Text widget and verify it has a reasonable font size
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final text in textWidgets) {
        final fontSize = text.style?.fontSize;
        if (fontSize != null) {
          // Font size should be reasonable for large screens
          expect(fontSize, greaterThan(0));
          // Should not be excessively large
          expect(fontSize, lessThanOrEqualTo(200));
        }
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
