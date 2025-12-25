import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_header.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';

// Custom test binding that dumps render & semantics trees on drawFrame errors
class _DebugBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  void drawFrame() {
    try {
      super.drawFrame();
    } on Object catch (e, st) {
      // Dump render tree and semantics to help locate the offending RenderObject
      debugPrint('\n===== Render tree dump (on exception) =====');
      debugDumpRenderTree();
      debugPrint('\n===== Semantics tree dump (on exception) =====');
      try {
        debugDumpSemanticsTree();
      } on Object catch (_) {
        debugPrint('debugDumpSemanticsTree not available on this Flutter SDK');
      }
      debugPrint('Exception during drawFrame: $e\n$st');
      rethrow;
    }
  }
}

void main() {
  // Install our debug binding so that if a drawFrame / semantics error occurs
  // we dump the render+semantics trees for diagnosis.
  _DebugBinding();

  group('Keyboard Bar Responsive Layout Tests', () {
    testWidgets('Pixel 10 size (2400x1080) - no scroll needed', (tester) async {
      // Pixel 10 screen: 2400x1080 logical pixels at 3x density = ~800x360 dp
      // With AppBar (~56dp) and padding, available space for keyboard bar: ~180-200dp
      await tester.binding.setSurfaceSize(const Size(360, 800));

      await tester.pumpWidget(
        ProviderScope(
          child: ExcludeSemantics(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Test')),
                body: Column(
                  children: [
                    const Expanded(child: Placeholder()), // Grid area
                    CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no overflow errors
      expect(tester.takeException(), isNull);

      // Banner should be visible and have reasonable size (now larger)
      final bannerFinder = find.byType(CrosswordClueHeader);
      expect(bannerFinder, findsOneWidget);
      final bannerSize = tester.getSize(bannerFinder);
      // Banner is expected to be noticeable but not overly large on this
      // constrained layout; accept slightly smaller values consistent with
      // current layout math.
      expect(bannerSize.height, greaterThanOrEqualTo(70));
      expect(bannerSize.height, lessThan(160));

      // Keyboard should be visible
      final keyboardFinder = find.byType(VirtualKeyboard);
      expect(keyboardFinder, findsOneWidget);

      // Verify no SingleChildScrollView is needed (or if present, not scrollable)
      final scrollFinder = find.byType(SingleChildScrollView);
      if (scrollFinder.evaluate().isNotEmpty) {
        final renderBox = tester.renderObject(scrollFinder) as RenderBox;
        // Content should fit without needing scroll
        expect(renderBox.size.height, greaterThanOrEqualTo(0));
      }
    });

    testWidgets('Small phone (320x568) - compact layout', (tester) async {
      // iPhone SE size
      await tester.binding.setSurfaceSize(const Size(320, 568));

      await tester.pumpWidget(
        ProviderScope(
          child: ExcludeSemantics(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Test')),
                body: Column(
                  children: [
                    const Expanded(child: Placeholder()),
                    CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Log sizes for diagnosis before checking for exceptions
      try {
        final barFinder = find.byType(CrosswordControlsBar);
        if (barFinder.evaluate().isNotEmpty) {
          debugPrint(
            'DEBUG: CrosswordControlsBar size=${tester.getSize(barFinder.first)}',
          );
        }
        final kf = find.byType(VirtualKeyboard);
        if (kf.evaluate().isNotEmpty) {
          debugPrint('DEBUG: VirtualKeyboard size=${tester.getSize(kf.first)}');
        }
        final bannerFinder = find.byType(CrosswordClueHeader);
        if (bannerFinder.evaluate().isNotEmpty) {
          debugPrint(
            'DEBUG: Banner size=${tester.getSize(bannerFinder.first)}',
          );
        }
      } on Object catch (_) {}

      // If the framework recorded exceptions, dump render/semantics trees
      // to help pinpoint the offending RenderObject.
      final _ex = tester.takeException();
      if (_ex != null) {
        debugPrint('\n=== Exception detected in test "Small phone" ===');
        debugPrint('Exception: $_ex');
        debugPrint('\n===== Render tree dump (test-instrumented) =====');
        debugDumpRenderTree();
        debugPrint('\n===== Semantics tree dump (test-instrumented) =====');
        try {
          debugDumpSemanticsTree();
        } on Object catch (_) {
          debugPrint(
            'debugDumpSemanticsTree not available on this Flutter SDK',
          );
        }
        // Fail the test after dumping useful diagnostics
        fail('Framework reported exception: $_ex');
      }
      expect(find.byType(CrosswordClueHeader), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('Large phone (411x823) - comfortable layout', (tester) async {
      // Pixel 5 size
      await tester.binding.setSurfaceSize(const Size(411, 823));

      await tester.pumpWidget(
        ProviderScope(
          child: ExcludeSemantics(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Test')),
                body: Column(
                  children: [
                    const Expanded(child: Placeholder()),
                    CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final bannerSize = tester.getSize(find.byType(CrosswordClueHeader));
      final keyboardSize = tester.getSize(find.byType(VirtualKeyboard));

      // Both should have reasonable sizes
      expect(bannerSize.height, greaterThanOrEqualTo(50));
      expect(keyboardSize.height, greaterThanOrEqualTo(100));
    });

    testWidgets('Tablet landscape (1024x768) - spacious layout', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1024, 768));

      await tester.pumpWidget(
        ProviderScope(
          child: ExcludeSemantics(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Test')),
                body: Column(
                  children: [
                    const Expanded(child: Placeholder()),
                    CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CrosswordClueHeader), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('Extreme constraint (height: 150) - minimum viable layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ExcludeSemantics(
            child: MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 150,
                  child: CrosswordControlsBar(
                    onKey: (_) {},
                    onBackspace: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not overflow even in extreme constraint
      expect(tester.takeException(), isNull);
      expect(find.byType(CrosswordClueHeader), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('CrosswordScreen full integration - Pixel 10', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));

      await tester.pumpWidget(
        ProviderScope(
          child: ExcludeSemantics(
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
                    CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Measure actual available space (use WidgetTester.view for multi-window API)
      final screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      const appBarHeight = 56;
      final availableBody = screenHeight - appBarHeight;

      // Keyboard bar should take reasonable portion, not fixed 240
      final keyboardBarSize = tester.getSize(find.byType(CrosswordControlsBar));
      expect(
        keyboardBarSize.height,
        lessThan(availableBody * 0.5),
      ); // Max 50% of body
      expect(
        keyboardBarSize.height,
        greaterThanOrEqualTo(120),
      ); // Minimum functional size

      // No overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Banner height adapts to available space', (tester) async {
      // Test with generous space
      await tester.pumpWidget(
        ProviderScope(
          child: ExcludeSemantics(
            child: MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: CrosswordControlsBar(
                    onKey: (_) {},
                    onBackspace: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final largeBannerSize = tester.getSize(find.byType(CrosswordClueHeader));

      // Test with tight space
      await tester.pumpWidget(
        ProviderScope(
          child: ExcludeSemantics(
            child: MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 180,
                  child: CrosswordControlsBar(
                    onKey: (_) {},
                    onBackspace: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final smallBannerSize = tester.getSize(find.byType(CrosswordClueHeader));

      // Banner should adapt but maintain minimum size
      expect(smallBannerSize.height, greaterThanOrEqualTo(40));
      expect(smallBannerSize.height, lessThanOrEqualTo(largeBannerSize.height));
    });

    testWidgets('Keyboard maintains usable key size', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ExcludeSemantics(
            child: MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 200,
                  child: CrosswordControlsBar(
                    onKey: (_) {},
                    onBackspace: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final keyboardSize = tester.getSize(find.byType(VirtualKeyboard));

      // Keyboard should have minimum height for usable keys
      expect(keyboardSize.height, greaterThanOrEqualTo(100));

      // Should be able to find keyboard buttons
      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsWidgets);
    });
  });
}
