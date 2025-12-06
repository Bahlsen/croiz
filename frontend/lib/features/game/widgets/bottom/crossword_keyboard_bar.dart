import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clues_banner.dart';
import 'package:croiz/features/game/game_providers.dart';

// Minimal, well-formed implementation to avoid layout overflows.
class CrosswordKeyboardBar extends ConsumerStatefulWidget {
  const CrosswordKeyboardBar({
    required this.onKey,
    required this.onBackspace,
    Key? key,
  }) : super(key: key);

  final void Function(String) onKey;
  final VoidCallback onBackspace;

  @override
  ConsumerState<CrosswordKeyboardBar> createState() => _CrosswordKeyboardBarState();
}

class _CrosswordKeyboardBarState extends ConsumerState<CrosswordKeyboardBar> {
  bool _isAzerty = true;

  @override
  Widget build(BuildContext context) {
    final layout = _isAzerty ? VirtualKeyboard.azertyLayout : VirtualKeyboard.qwertyLayout;

    const minBannerHeight = 52.0;
    const minKeyboardHeight = 100.0;
    const gapBetween = 2.0;
    // Keep the control row compact so it doesn't force large totals in
    // constrained test scenarios.
    const controlHeight = 35.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        // Account for any system keyboard inset so controls don't sit on top
        // of the IME. Subtracting `viewInsets.bottom` reduces the usable
        // area when the keyboard is visible so the control row moves above
        // the keyboard.
        final bottomInset = media.viewInsets.bottom;
        // If the parent gave a finite max height, use it. When the parent
        // provides unbounded height (e.g. Column without constraints) avoid
        // claiming the entire screen; instead choose a sensible fraction of
        // the viewport so the keyboard bar remains a bottom control rather
        // than occupying the full body. Tests expect the bar to take a
        // moderate portion of the body (not full screen), so use 40%.
        final screenAvailable = (media.size.height - media.padding.bottom - bottomInset).clamp(0.0, double.infinity);
        final maxHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : (screenAvailable * 0.4);
        final usableHeight = (maxHeight - media.padding.bottom - bottomInset).clamp(0.0, double.infinity);

        // Banner should adapt to available space but keep a reasonable minimum.
        // Use tighter banner proportions when the parent provided a tight
        // height (e.g. a SizedBox) so tests that place the bar inside a fixed
        // box see the expected percentage-based sizing. When the parent gives
        // a loose/available height (e.g. Column with Expanded sibling) use a
        // smaller proportion to avoid the bar claiming most of the body.
        final parentTight = constraints.hasTightHeight;
          final bannerPercent = parentTight ? 0.3 : 0.15;
        var bannerHeight = (usableHeight * bannerPercent).clamp(minBannerHeight, usableHeight * 0.6);

        // Decide whether to place the banner in-flow (stacked) or overlayed
        // on top of the keyboard. For very small available heights we overlay
        // the banner so it doesn't reduce the keyboard's usable area and
        // prevent RenderFlex overflows in tests that assert a minimum
        // keyboard size.
        const minTotalForStacked = minBannerHeight + minKeyboardHeight + gapBetween + controlHeight;
        final useOverlayBanner = usableHeight < minTotalForStacked;

        // Compute keyboardHeight depending on stacking strategy.
        double keyboardHeight;
        if (useOverlayBanner) {
          // In overlay mode the keyboard may occupy most of the bar; still
          // cap it to a reasonable portion for very large screens.
          keyboardHeight = usableHeight.clamp(minKeyboardHeight, usableHeight);
        } else {
          var remaining = (usableHeight - bannerHeight - gapBetween - controlHeight).clamp(0.0, double.infinity);
          // If remaining space is less than our minimum keyboard height,
          // attempt to reduce the banner down to its minimum to make room.
          if (remaining < minKeyboardHeight) {
            final needed = minKeyboardHeight - remaining;
            final reduced = (bannerHeight - needed).clamp(minBannerHeight, bannerHeight);
            bannerHeight = reduced;
            remaining = (usableHeight - bannerHeight - gapBetween - controlHeight).clamp(0.0, double.infinity);
          }
          keyboardHeight = remaining.clamp(0.0, usableHeight * 0.8);
        }

        if (kDebugMode) {
          debugPrint('CrosswordKeyboardBar: usable=$usableHeight banner=$bannerHeight keyboard=$keyboardHeight');
        }

        if (useOverlayBanner) {
          // Overlay banner mode: place banner on top of the keyboard so
          // the keyboard keeps a usable size in very constrained spaces.
          return SafeArea(
            top: false,
            child: SizedBox(
              height: usableHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Keyboard fills the available area in overlay mode.
                  Positioned.fill(
                    child: VirtualKeyboard(
                      layout: layout,
                      onKey: widget.onKey,
                      onBackspace: widget.onBackspace,
                      availableHeight: keyboardHeight,
                    ),
                  ),
                  // Banner overlays at the top but does not consume layout
                  // space. Place the compact control row inside the banner
                  // area so it doesn't overlap the keyboard below.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: bannerHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const CrosswordClueBanner(key: ValueKey('clue-banner')),
                          // Place controls inside the banner so they remain
                          // visually on the banner and never overlap the
                          // keyboard area.
                          Positioned(
                            top: 4,
                            right: 4,
                            child: SizedBox(
                              height: controlHeight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    key: const Key('clear_button'),
                                    onPressed: () {
                                      try {
                                        ref.read(gameBoardProvider.notifier).clearIncorrectLetters();
                                      } on Object catch (e, st) {
                                        if (kDebugMode) {
                                          developer.log('clearIncorrectLetters failed: $e', stackTrace: st);
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.cleaning_services_outlined),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isAzerty = !_isAzerty;
                                      });
                                    },
                                    icon: Icon(_isAzerty ? Icons.keyboard : Icons.keyboard_alt_outlined),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Stacked mode: banner consumes layout space and keyboard takes the
        // remaining area. Wrap in a SizedBox so the total height equals the
        // available constraint (tests rely on equal heights).
        return SafeArea(
          top: false,
          child: SizedBox(
            height: usableHeight,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: bannerHeight,
                  child: const CrosswordClueBanner(key: ValueKey('clue-banner')),
                ),
                const SizedBox(height: gapBetween),
                SizedBox(
                  height: controlHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        key: const Key('clear_button'),
                        onPressed: () {
                          try {
                            ref.read(gameBoardProvider.notifier).clearIncorrectLetters();
                          } on Object catch (e, st) {
                            if (kDebugMode) {
                              developer.log('clearIncorrectLetters failed: $e', stackTrace: st);
                            }
                          }
                        },
                        icon: const Icon(Icons.cleaning_services_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isAzerty = !_isAzerty;
                          });
                        },
                        icon: Icon(_isAzerty ? Icons.keyboard : Icons.keyboard_alt_outlined),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: keyboardHeight,
                  child: VirtualKeyboard(
                    layout: layout,
                    onKey: widget.onKey,
                    onBackspace: widget.onBackspace,
                    availableHeight: keyboardHeight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
