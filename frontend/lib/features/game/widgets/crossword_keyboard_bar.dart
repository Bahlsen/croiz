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

          if (available < (desiredBanner + desiredControls + desiredKeyboard)) {
            // Simpler, more robust approach: first try to scale banner and keyboard
            // proportionally, while respecting minimums. After that, assign the
            // remaining space to controls. As a final safety net, ensure the
            // three heights sum exactly to `available` so no overflow can occur.
            final contentDesired = desiredBanner + desiredKeyboard;
            final contentAvailable = (available - desiredControls).clamp(minBanner + minKeyboard, double.infinity);
            final scale = contentAvailable / contentDesired;

            bannerH = (desiredBanner * scale).clamp(minBanner, desiredBanner);
            keyboardH = (desiredKeyboard * scale).clamp(minKeyboard, double.infinity);

            controlsH = (available - bannerH - keyboardH).clamp(minControls, double.infinity);

            // Safety adjustment: if rounding/clamping left a gap or overflow,
            // put the remainder into the keyboard so the sum equals available.
            final sum = bannerH + controlsH + keyboardH;
            if ((sum - available).abs() > 0.1) {
              keyboardH = (available - bannerH - controlsH).clamp(0.0, double.infinity);
            }
          }

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: minBanner, maxHeight: bannerH),
                child: SizedBox(height: bannerH, child: const CrosswordClueBanner()),
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
                    keyHeight: 44,
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
