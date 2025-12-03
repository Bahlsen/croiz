import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/features/game/widgets/crossword_clues_banner.dart';

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
  bool _isAzerty = true; // Default AZERTY

  @override
  Widget build(BuildContext context) {
    final layout = _isAzerty
      ? VirtualKeyboard.azertyLayout
      : VirtualKeyboard.qwertyLayout;

    // Constrain the whole keyboard bar to a reasonable max height and make
    // its internal content scrollable when necessary. This prevents the
    // Column from overflowing in headless test environments while keeping
    // normal runtime behavior intact.
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Desired and minimum sizes
          const desiredBanner = 120.0;
          const desiredControls = 44.0;
          const desiredKeyboard = 160.0;

          const minBanner = 64.0;
          const minControls = 24.0;
          const minKeyboard = 80.0;

          final available = constraints.maxHeight.isFinite ? constraints.maxHeight : (desiredBanner + desiredControls + desiredKeyboard);

          double bannerH = desiredBanner;
          double controlsH = desiredControls;
          double keyboardH = desiredKeyboard;

          // If there's less space than desired, allocate deterministically:
          // 1. Reserve the minimum for controls.
          // 2. Split the remaining space between banner and keyboard according
          //    to their desired proportions, but don't go below their minima.
          // 3. If rounding/clamping creates a mismatch, reduce keyboard first,
          //    then banner, to make the sum == available. If there's extra
          //    space, give it to the keyboard.
          final totalDesired = desiredBanner + desiredControls + desiredKeyboard;
          if (available < totalDesired) {
            controlsH = minControls;

            final remainingForContent = (available - controlsH).clamp(minBanner + minKeyboard, double.infinity);
            final contentDesired = desiredBanner + desiredKeyboard;
            final bannerShare = desiredBanner / contentDesired;
            final keyboardShare = desiredKeyboard / contentDesired;

            bannerH = (remainingForContent * bannerShare).clamp(minBanner, desiredBanner);
            keyboardH = (remainingForContent * keyboardShare).clamp(minKeyboard, desiredKeyboard);

            // Now fix any mismatch so that bannerH + controlsH + keyboardH == available
            double sum = bannerH + controlsH + keyboardH;
            if (sum > available) {
              double overflow = sum - available;
              // Reduce keyboard first, down to minKeyboard
              final reduceKb = (keyboardH - minKeyboard).clamp(0.0, overflow);
              keyboardH -= reduceKb;
              overflow -= reduceKb;

              if (overflow > 0) {
                final reduceBanner = (bannerH - minBanner).clamp(0.0, overflow);
                bannerH -= reduceBanner;
                overflow -= reduceBanner;
              }

              if (overflow > 0) {
                // As a last resort, shrink controls (can go to 0 if truly tiny)
                controlsH = (controlsH - overflow).clamp(0.0, controlsH);
              }
            } else if (sum < available) {
              // Give extra space to keyboard (preferred) so keys remain usable
              final deficit = available - sum;
              keyboardH += deficit;
            }
          }

          // Final safety: ensure the three values sum to `available` (within a
          // tiny epsilon) by adjusting keyboard. This avoids layout overflow.
          final finalSum = bannerH + controlsH + keyboardH;
          if ((finalSum - available).abs() > 0.1) {
            keyboardH = (available - bannerH - controlsH).clamp(0.0, double.infinity);
          }

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: minBanner, maxHeight: bannerH),
                child: SizedBox(
                  height: bannerH,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: const CrosswordClueBanner(),
                  ),
                ),
              ),

              SizedBox(
                height: controlsH,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: const Key('clear_button'),
                        tooltip: 'Clear incorrect letters',
                        icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white70),
                        onPressed: () {
                          try {
                            ref.read(gameBoardProvider.notifier).clearIncorrectLetters();
                          } on Object catch (e, st) {
                            debugPrint('clearIncorrectLetters failed: $e\n$st');
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: 'Basculer AZERTY/QWERTY',
                        icon: const Icon(Icons.keyboard_alt, color: Colors.white70),
                        onPressed: () => setState(() => _isAzerty = !_isAzerty),
                      ),
                    ],
                  ),
                ),
              ),

              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 0, maxHeight: keyboardH),
                child: SizedBox(
                  height: keyboardH,
                  child: VirtualKeyboard(
                    layout: layout,
                    onKey: widget.onKey,
                    onBackspace: widget.onBackspace,
                    enableFeedback: true,
                    keyHeight: 48,
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
