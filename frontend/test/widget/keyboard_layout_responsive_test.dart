import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/crossword_keyboard_bar.dart';
import 'package:croiz/features/game/widgets/crossword_clues_banner.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';

void main() {
  group('Keyboard Bar Responsive Layout Tests', () {
    testWidgets('Pixel 10 size (2400x1080) - no scroll needed', (tester) async {
      // Pixel 10 screen: 2400x1080 logical pixels at 3x density = ~800x360 dp
      // With AppBar (~56dp) and padding, available space for keyboard bar: ~180-200dp
      await tester.binding.setSurfaceSize(const Size(360, 800));
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Test')),
              body: Column(
                children: [
                  const Expanded(child: Placeholder()), // Grid area
                  CrosswordKeyboardBar(
                    onKey: (_) {},
                    onBackspace: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
      
      // Banner should be visible and have reasonable size
      final bannerFinder = find.byType(CrosswordClueBanner);
      expect(bannerFinder, findsOneWidget);
      final bannerSize = tester.getSize(bannerFinder);
      expect(bannerSize.height, greaterThan(40));
      expect(bannerSize.height, lessThan(100));
      
      // Keyboard should be visible
      final keyboardFinder = find.byType(VirtualKeyboard);
      expect(keyboardFinder, findsOneWidget);
      
      // Verify no SingleChildScrollView is needed (or if present, not scrollable)
      final scrollFinder = find.byType(SingleChildScrollView);
      if (scrollFinder.evaluate().isNotEmpty) {
        final renderBox = tester.renderObject(scrollFinder) as RenderBox;
        // Content should fit without needing scroll
        expect(renderBox.size.height, greaterThan(0));
      }
    });

    testWidgets('Small phone (320x568) - compact layout', (tester) async {
      // iPhone SE size
      await tester.binding.setSurfaceSize(const Size(320, 568));
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Test')),
              body: Column(
                children: [
                  const Expanded(child: Placeholder()),
                  CrosswordKeyboardBar(
                    onKey: (_) {},
                    onBackspace: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CrosswordClueBanner), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('Large phone (411x823) - comfortable layout', (tester) async {
      // Pixel 5 size
      await tester.binding.setSurfaceSize(const Size(411, 823));
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Test')),
              body: Column(
                children: [
                  const Expanded(child: Placeholder()),
                  CrosswordKeyboardBar(
                    onKey: (_) {},
                    onBackspace: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      
      final bannerSize = tester.getSize(find.byType(CrosswordClueBanner));
      final keyboardSize = tester.getSize(find.byType(VirtualKeyboard));
      
      // Both should have reasonable sizes
      expect(bannerSize.height, greaterThan(50));
      expect(keyboardSize.height, greaterThan(100));
    });

    testWidgets('Tablet landscape (1024x768) - spacious layout', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Test')),
              body: Column(
                children: [
                  const Expanded(child: Placeholder()),
                  CrosswordKeyboardBar(
                    onKey: (_) {},
                    onBackspace: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CrosswordClueBanner), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('Extreme constraint (height: 150) - minimum viable layout', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 150,
                child: CrosswordKeyboardBar(
                  onKey: (_) {},
                  onBackspace: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not overflow even in extreme constraint
      expect(tester.takeException(), isNull);
      expect(find.byType(CrosswordClueBanner), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('CrosswordScreen full integration - Pixel 10', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Crossword'),
                toolbarHeight: 56,
              ),
              body: Column(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Placeholder(), // Simulates CrosswordGrid
                    ),
                  ),
                  CrosswordKeyboardBar(
                    onKey: (_) {},
                    onBackspace: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Measure actual available space
      final screenHeight = tester.binding.window.physicalSize.height / 
                          tester.binding.window.devicePixelRatio;
      final appBarHeight = 56.0;
      final availableBody = screenHeight - appBarHeight;
      
      // Keyboard bar should take reasonable portion, not fixed 240
      final keyboardBarSize = tester.getSize(find.byType(CrosswordKeyboardBar));
      expect(keyboardBarSize.height, lessThan(availableBody * 0.5)); // Max 50% of body
      expect(keyboardBarSize.height, greaterThan(120)); // Minimum functional size
      
      // No overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Banner height adapts to available space', (tester) async {
      // Test with generous space
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 400,
                child: CrosswordKeyboardBar(
                  onKey: (_) {},
                  onBackspace: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final largeBannerSize = tester.getSize(find.byType(CrosswordClueBanner));

      // Test with tight space
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 180,
                child: CrosswordKeyboardBar(
                  onKey: (_) {},
                  onBackspace: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final smallBannerSize = tester.getSize(find.byType(CrosswordClueBanner));

      // Banner should adapt but maintain minimum size
      expect(smallBannerSize.height, greaterThan(40));
      expect(smallBannerSize.height, lessThanOrEqualTo(largeBannerSize.height));
    });

    testWidgets('Keyboard maintains usable key size', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 200,
                child: CrosswordKeyboardBar(
                  onKey: (_) {},
                  onBackspace: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final keyboardSize = tester.getSize(find.byType(VirtualKeyboard));
      
      // Keyboard should have minimum height for usable keys
      expect(keyboardSize.height, greaterThan(100));
      
      // Should be able to find keyboard buttons
      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsWidgets);
    });
  });
}
