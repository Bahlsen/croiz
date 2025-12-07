import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clues_banner.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_icon_bar.dart';
import 'package:croiz/features/game/game_providers.dart';

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
  ConsumerState<CrosswordControlsBar> createState() => _CrosswordControlsBarState();
}

class _CrosswordControlsBarState extends ConsumerState<CrosswordControlsBar> {
  bool _isAzerty = true;

  @override
  Widget build(BuildContext context) {
    final layout = _isAzerty ? VirtualKeyboard.azertyLayout : VirtualKeyboard.qwertyLayout;

    const minBannerHeight = 64.0;
    const gapBetween = 2.0;
    const controlHeight = 35.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Prefer parent-provided constraints; fall back to a reasonable
        // default when unconstrained to avoid zero/NaN sizes.
        final total = (constraints.maxHeight.isFinite && constraints.maxHeight > 0)
            ? constraints.maxHeight
            : 240.0;

        // Percentage-based simple layout (KISS):
        const gap = gapBetween;
        final bannerTarget = total * 0.22;
        final bannerCap = total * 0.30;
        double bannerHeight = bannerTarget.clamp(minBannerHeight, bannerCap);

        final iconsTarget = total * 0.08;
        const minIcons = controlHeight; // 35.0
        final controlsH = math.max(minIcons, iconsTarget);

        double keyboardHeight = total - bannerHeight - controlsH - gap;
        if (keyboardHeight < 0) {
          final deficit = -keyboardHeight;
          final reduce = math.min(deficit, bannerHeight - minBannerHeight);
          bannerHeight = math.max(minBannerHeight, bannerHeight - reduce);
          keyboardHeight = total - bannerHeight - controlsH - gap;
        }

        if (kDebugMode) {
          debugPrint('CrosswordControlsBar (KISS): total=$total banner=$bannerHeight keyboard=$keyboardHeight');
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (bannerHeight > 0)
              SizedBox(
                height: bannerHeight,
                child: const CrosswordClueBanner(key: ValueKey('clue-banner')),
              ),
            if (bannerHeight > 0) const SizedBox(height: gap),

            SizedBox(
              height: controlsH,
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
        );
      },
    );
  }
}
