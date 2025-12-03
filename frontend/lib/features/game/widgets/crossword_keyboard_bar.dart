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

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Handle infinite constraints (shouldn't happen in normal usage but safe guard)
          if (!constraints.hasBoundedHeight || constraints.maxHeight == double.infinity) {
            // Fallback to intrinsic sizing - let children determine their size
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CrosswordClueBanner(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: const Key('clear_button'),
                          tooltip: 'Clear incorrect letters',
                          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white70),
                          visualDensity: VisualDensity.compact,
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
                          visualDensity: VisualDensity.compact,
                          onPressed: () => setState(() => _isAzerty = !_isAzerty),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: VirtualKeyboard(
                    layout: layout,
                    onKey: widget.onKey,
                    onBackspace: widget.onBackspace,
                    enableFeedback: true,
                    keyHeight: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            );
          }
          
          // Get available height from parent (Flexible in CrosswordScreen)
          final availableHeight = constraints.maxHeight;
          
          // Define proportions and constraints (all relative to available space)
          // These are ideal proportions that will be adjusted based on minimums
          const bannerProportion = 0.35; // 35% for clue banner
          const controlsProportion = 0.15; // 15% for control buttons
          const keyboardProportion = 0.50; // 50% for keyboard
          
          // Define absolute minimums (in logical pixels)
          const minBannerHeight = 48.0;
          const minControlsHeight = 40.0;
          const minKeyboardHeight = 100.0;
          
          // Calculate ideal heights
          double bannerHeight = availableHeight * bannerProportion;
          double controlsHeight = availableHeight * controlsProportion;
          double keyboardHeight = availableHeight * keyboardProportion;
          
          // Ensure minimums are respected
          if (bannerHeight < minBannerHeight) bannerHeight = minBannerHeight;
          if (controlsHeight < minControlsHeight) controlsHeight = minControlsHeight;
          if (keyboardHeight < minKeyboardHeight) keyboardHeight = minKeyboardHeight;
          
          // Adjust if total exceeds available (prioritize keyboard usability)
          double totalHeight = bannerHeight + controlsHeight + keyboardHeight;
          
          if (totalHeight > availableHeight) {
            // Scale down proportionally, but keep keyboard at minimum
            final excess = totalHeight - availableHeight;
            
            // Try to reduce banner first
            final bannerReduction = (bannerHeight - minBannerHeight).clamp(0.0, excess);
            bannerHeight -= bannerReduction;
            final remainingExcess = excess - bannerReduction;
            
            if (remainingExcess > 0) {
              // Then reduce controls
              final controlsReduction = (controlsHeight - minControlsHeight).clamp(0.0, remainingExcess);
              controlsHeight -= controlsReduction;
              final finalExcess = remainingExcess - controlsReduction;
              
              if (finalExcess > 0) {
                // Last resort: reduce keyboard slightly
                keyboardHeight = (keyboardHeight - finalExcess).clamp(minKeyboardHeight, keyboardHeight);
              }
            }
          }
          
          // Calculate key height for keyboard (4 rows typically)
          final keyHeight = (keyboardHeight * 0.9 / 4).clamp(32.0, 48.0);
          
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Clue Banner
              SizedBox(
                height: bannerHeight,
                child: const CrosswordClueBanner(),
              ),
              
              // Control buttons
              SizedBox(
                height: controlsHeight,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: const Key('clear_button'),
                          tooltip: 'Clear incorrect letters',
                          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white70),
                          visualDensity: VisualDensity.compact,
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
                          visualDensity: VisualDensity.compact,
                          onPressed: () => setState(() => _isAzerty = !_isAzerty),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Keyboard
              SizedBox(
                height: keyboardHeight,
                child: VirtualKeyboard(
                  layout: layout,
                  onKey: widget.onKey,
                  onBackspace: widget.onBackspace,
                  enableFeedback: true,
                  keyHeight: keyHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
