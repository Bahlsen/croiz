import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clues_banner.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_icon_bar.dart';
import 'package:croiz/features/game/game_providers.dart';

// Renamed from CrosswordKeyboardBar to better reflect that this widget
// composes multiple controls: the clue banner, the control icon row,
// and the virtual keyboard.
class CrosswordControlsBar extends ConsumerStatefulWidget {
  const CrosswordControlsBar({
    required this.onKey,
    required this.onBackspace,
    Key? key,
  }) : super(key: key);

  final void Function(String) onKey;
  final VoidCallback onBackspace;

  @override
  ConsumerState<CrosswordControlsBar> createState() => _CrosswordControlsBarState();
}

class _CrosswordControlsBarState extends ConsumerState<CrosswordControlsBar> {
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
        final bottomInset = media.viewInsets.bottom;
        final screenAvailable = (media.size.height - media.padding.bottom - bottomInset).clamp(0.0, double.infinity);
        final maxHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : (screenAvailable * 0.4);
        final usableHeight = (maxHeight - media.padding.bottom - bottomInset).clamp(0.0, double.infinity);

        final parentTight = constraints.hasTightHeight;
        final bannerPercent = parentTight ? 0.3 : 0.15;
        var bannerHeight = (usableHeight * bannerPercent).clamp(minBannerHeight, usableHeight * 0.6);

        const minTotalForStacked = minBannerHeight + minKeyboardHeight + gapBetween + controlHeight;
        final useOverlayBanner = usableHeight < minTotalForStacked;

        double keyboardHeight;
        if (useOverlayBanner) {
          keyboardHeight = usableHeight.clamp(minKeyboardHeight, usableHeight);
        } else {
          var remaining = (usableHeight - bannerHeight - gapBetween - controlHeight).clamp(0.0, double.infinity);
          if (remaining < minKeyboardHeight) {
            final needed = minKeyboardHeight - remaining;
            final reduced = (bannerHeight - needed).clamp(minBannerHeight, bannerHeight);
            bannerHeight = reduced;
            remaining = (usableHeight - bannerHeight - gapBetween - controlHeight).clamp(0.0, double.infinity);
          }
          keyboardHeight = remaining.clamp(0.0, usableHeight * 0.8);
        }

        if (kDebugMode) {
          debugPrint('CrosswordControlsBar: usable=$usableHeight banner=$bannerHeight keyboard=$keyboardHeight');
        }

        if (useOverlayBanner) {
          return SafeArea(
            top: false,
            child: SizedBox(
              height: usableHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: VirtualKeyboard(
                      layout: layout,
                      onKey: widget.onKey,
                      onBackspace: widget.onBackspace,
                      availableHeight: keyboardHeight,
                    ),
                  ),
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
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CrosswordIconBar(
                              isAzerty: _isAzerty,
                              onClear: () {
                                try {
                                  ref.read(gameBoardProvider.notifier).clearIncorrectLetters();
                                } on Object catch (e, st) {
                                  if (kDebugMode) {
                                    developer.log('clearIncorrectLetters failed: $e', stackTrace: st);
                                  }
                                }
                              },
                              onToggle: () {
                                setState(() {
                                  _isAzerty = !_isAzerty;
                                });
                              },
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
                CrosswordIconBar(
                  isAzerty: _isAzerty,
                  onClear: () {
                    try {
                      ref.read(gameBoardProvider.notifier).clearIncorrectLetters();
                    } on Object catch (e, st) {
                      if (kDebugMode) {
                        developer.log('clearIncorrectLetters failed: $e', stackTrace: st);
                      }
                    }
                  },
                  onToggle: () {
                    setState(() {
                      _isAzerty = !_isAzerty;
                    });
                  },
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
