import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_header.dart';
// Icons moved into the clue banner; no separate icon bar import needed.
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';

// Simple, robust controls bar: banner, icon row, and keyboard.
//
// IMPORTANT: This widget expects its parent to provide the vertical
// space it should occupy. The layout contract is:
// - Parent (e.g. `CrosswordScreen`) must size this widget using
//   `Expanded` (or an explicit SizedBox) so that the controls take the
//   remaining height of the screen.
// - The controls bar will compute internal splits (banner / icons /
//   keyboard) from the given height and will NOT perform top-level
//   calculations that assume the full device height. Keeping sizing
//   responsibility in the parent avoids overlaps and keeps the layout
//   dynamic across screen sizes.
class CrosswordControlsBar extends ConsumerStatefulWidget {
  const CrosswordControlsBar({
    required this.onKey,
    required this.onBackspace,
    this.heightFactor = 0.4,
    Key? key,
  }) : super(key: key);

  final void Function(String) onKey;
  final VoidCallback onBackspace;
  final double heightFactor;

  @override
  ConsumerState<CrosswordControlsBar> createState() =>
      _CrosswordControlsBarState();
}

class _CrosswordControlsBarState extends ConsumerState<CrosswordControlsBar> {
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    final isAzerty = ref.watch(gameKeyboardLayoutProvider);
    final isMuted = ref.watch(gameAudioMutedProvider);
    final isDark = ref.watch(appIsDarkProvider);

    final layout = isAzerty
        ? VirtualKeyboard.azertyLayout
        : VirtualKeyboard.qwertyLayout;

    const gapBetween = 2.0;
    const controlHeight = 35.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the vertical space to work with. If the parent gives a
        // finite height use it. If unconstrained, fall back to device
        // height * heightFactor so callers can request a portion of screen.
        final total =
            (constraints.maxHeight.isFinite && constraints.maxHeight > 0)
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * widget.heightFactor;

        // Minimum desired sizes (prioritized):
        // Increase the minimum banner so it remains visually prominent.
        // Reduced from 50 to 40 to make the banner less tall by default.
        const desiredMinBanner = 40.0;
        const desiredMinKeyboard = 100.0;
        // Controls can be reduced to zero in extremely tight constraints so
        // banner and keyboard minima can be satisfied.
        const desiredMinControls = 0.0;

        // Percentage-based simple layout targets
        const gap = gapBetween;
        // Favor a moderate banner: allocate a smaller portion of the
        // available space so the keyboard gets more room by default.
        final bannerTarget = total * 0.30;
        final bannerCap = total * 0.50;

        // Starting banner height: prefer target but cap it. Allow clamp even
        // when bannerCap < desiredMinBanner (we'll rebalance below).
        final bannerMinLimit = math.min(desiredMinBanner, bannerCap);
        final bannerMaxLimit = math.max(desiredMinBanner, bannerCap);
        var bannerHeight = bannerTarget.clamp(bannerMinLimit, bannerMaxLimit);

        final iconsTarget = total * 0.08;
        var controlsH = math
            .max(math.max(desiredMinControls, controlHeight), iconsTarget)
            .toDouble();

        // Allocate remaining height to keyboard, then rebalance if keyboard
        // can't meet its minimum. We prioritize keyboard minimum first,
        // then banner, then controls.
        var keyboardHeight = total - bannerHeight - controlsH - gap;

        if (keyboardHeight < desiredMinKeyboard) {
          var shortage = desiredMinKeyboard - keyboardHeight;

          // Prefer reducing the controls first (they can shrink to zero),
          // then reduce the banner as a last resort. This keeps the banner
          // close to its desired minimum while still ensuring a usable
          // keyboard when possible.
          final availableFromControls = math.max(
            0,
            controlsH - desiredMinControls,
          );
          final takeFromControls = math.min(shortage, availableFromControls);
          controlsH = math.max(
            desiredMinControls,
            controlsH - takeFromControls,
          );
          shortage -= takeFromControls;

          if (shortage > 0) {
            final availableFromBanner = math.max(0, bannerHeight - 0);
            final takeFromBanner = math.min(shortage, availableFromBanner);
            bannerHeight = math.max(0, bannerHeight - takeFromBanner);
            shortage -= takeFromBanner;
          }

          keyboardHeight = total - bannerHeight - controlsH - gap;
          keyboardHeight = math.max(0, keyboardHeight).toDouble();
        }

        if (kDebugMode) {
          debugPrint(
            'CrosswordControlsBar: total=$total banner=$bannerHeight controls=$controlsH keyboard=$keyboardHeight',
          );
        }

        return Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Single banner that also renders the control icons (menu/clear).
                SizedBox(
                  height: bannerHeight,
                  child: CrosswordClueHeader(
                    key: const ValueKey('clue-banner'),
                    onClear: () {
                      try {
                        ref
                            .read(gameBoardProvider.notifier)
                            .clearIncorrectLetters();
                      } on Object catch (e, st) {
                        if (kDebugMode) {
                          developer.log(
                            'clearIncorrectLetters failed: $e',
                            stackTrace: st,
                          );
                        }
                      }
                    },
                    onMenu: () {
                      setState(() {
                        _showMenu = true;
                      });
                    },
                  ),
                ),
                if (bannerHeight > 0) const SizedBox(height: gap),
                if (keyboardHeight > 0)
                  SizedBox(
                    height: keyboardHeight,
                    child: VirtualKeyboard(
                      layout: layout,
                      onKey: widget.onKey,
                      onBackspace: widget.onBackspace,
                      availableHeight: keyboardHeight,
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
            if (_showMenu)
              CrosswordControlsMenu(
                onClose: () => setState(() => _showMenu = false),
                onToggleKeyboard: (v) =>
                    ref.read(gameKeyboardLayoutProvider.notifier).isAzerty = v,
                isAzerty: isAzerty,
                onToggleMute: (v) =>
                    ref.read(gameAudioMutedProvider.notifier).muted = v,
                isMuted: isMuted,
                onToggleTheme: (v) =>
                    ref.read(appIsDarkProvider.notifier).isDark = v,
                isDark: isDark,
              ),
          ],
        );
      },
    );
  }
}
