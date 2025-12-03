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
          // Desired dimensions (increased so clue banner can show two lines)
          const desiredBanner = 120.0;
          const desiredControls = 44.0;
          const desiredKeyboard = 160.0;
          const desiredTotal = desiredBanner + desiredControls + desiredKeyboard;

          // Minimum dimensions to keep UI usable on very small screens
          const minBanner = 64.0;
          const minControls = 32.0;
          const minKeyboard = 100.0;

          final maxH = constraints.maxHeight.isFinite ? constraints.maxHeight : desiredTotal;

          double bannerH = desiredBanner;
          double controlsH = desiredControls;
          double keyboardH = desiredKeyboard;

          if (maxH < desiredTotal) {
            // Scale down proportionally but respect minimums. We reduce banner
            // and keyboard but keep controls at least minControls.
            final scale = maxH / desiredTotal;
            bannerH = (desiredBanner * scale).clamp(minBanner, desiredBanner);
            keyboardH = (desiredKeyboard * scale).clamp(minKeyboard, desiredKeyboard);
            // Controls take remaining space but not less than minControls.
            controlsH = (maxH - bannerH - keyboardH).clamp(minControls, desiredControls);

            // If remaining is still too small, shrink keyboard further.
            if (controlsH < minControls) {
              final deficit = minControls - controlsH;
              final shrinkable = keyboardH - minKeyboard;
              final shrink = shrinkable >= deficit ? deficit : shrinkable;
              keyboardH = keyboardH - shrink;
              controlsH = (maxH - bannerH - keyboardH).clamp(minControls, desiredControls);
            }
          }

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: bannerH, child: const CrosswordClueBanner()),

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

              SizedBox(
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
            ],
          );
        },
      ),
    );
  }
}
