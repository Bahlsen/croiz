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

    const bannerHeight = 48.0;
    const gapBetween = 10.0;
    const controlHeight = 32.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final maxHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : media.size.height;
        final usableHeight = (maxHeight - media.padding.bottom).clamp(0.0, double.infinity);

        // compute a safe keyboard height
        var keyboardHeight = (usableHeight - bannerHeight - gapBetween - controlHeight).clamp(0.0, double.infinity);
        keyboardHeight = keyboardHeight.clamp(0.0, usableHeight * 0.6);

        if (kDebugMode) {
          debugPrint('CrosswordKeyboardBar: usable=$usableHeight keyboard=$keyboardHeight');
        }

        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: bannerHeight,
                child: CrosswordClueBanner(key: ValueKey('clue-banner')),
              ),
              const SizedBox(height: gapBetween),
              SizedBox(
                height: controlHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Clear incorrect letters button (uses provider directly so
                    // tests can override the provider and verify behaviour).
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
        );
      },
    );
  }
}
