import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import 'letter_key.dart';
import 'backspace_key.dart';
import '../virtual_keyboard.dart';

/// A single row of keyboard keys with responsive layout.
class KeyboardRow extends StatelessWidget {
  KeyboardRow({
    required this.keys,
    required this.keyHeight,
    required this.keySpacing,
    required this.letterFontSize,
    required this.onKey,
    required this.onBackspace,
    required this.onPlayClick,
    required this.onPlayDelete,
    required this.enabledLetters,
    required this.enableFeedback,
    required double keyRadius,
    required this.keyColor,
    required this.disabledKeyColor,
    super.key,
  }) : borderRadius = BorderRadius.circular(keyRadius);

  final List<String> keys;
  final double keyHeight;
  final double letterFontSize;
  final double keySpacing;
  final ValueChanged<String> onKey;
  final VoidCallback? onBackspace;
  final VoidCallback? onPlayClick;
  final VoidCallback? onPlayDelete;
  final Set<String>? enabledLetters;
  final bool enableFeedback;
  // Performance: pre-computed BorderRadius to avoid recreation in children
  final BorderRadius borderRadius;
  final Color? keyColor;
  final Color? disabledKeyColor;

  @override
  Widget build(BuildContext context) {
    // Performance: skip uppercase mapping if enabledLetters is null (common case)
    final enabledSet = enabledLetters?.map((e) => e.toUpperCase()).toSet();

    // Use Expanded with flex weights so keys fit the available row width
    // reliably (letters weight=1, backspace weight=2). This avoids manual
    // width math depending on MediaQuery and prevents overflow.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          Expanded(
            flex: keys[i] == VirtualKeyboard.backspaceToken ? 2 : 1,
            child: SizedBox(
              height: keyHeight,
              child: _buildKey(
                context,
                keys[i],
                keyHeight.toDouble(),
                enabledSet,
              ),
            ),
          ),
          if (i != keys.length - 1) SizedBox(width: keySpacing),
        ],
      ],
    );
  }

  Widget _buildKey(
    BuildContext context,
    String k,
    double height,
    Set<String>? enabledSet,
  ) {
    if (k == VirtualKeyboard.backspaceToken) {
      return BackspaceKey(
        height: height,
        onBackspace: onBackspace,
        onPlayDelete: onPlayDelete,
        enableFeedback: enableFeedback,
        borderRadius: borderRadius,
        keyColor: keyColor,
      );
    }

    final label = k.toUpperCase();
    final enabled = enabledSet == null || enabledSet.contains(label);
    return Semantics(
      label:
          AppLocalizations.of(context)?.letterLabel(label) ?? 'Letter $label',
      button: true,
      child: LetterKey(
        label: label,
        height: height,
        fontSize: letterFontSize,
        enabled: enabled,
        onPressed: enabled
            ? () {
                if (enableFeedback) {
                  HapticFeedback.selectionClick();
                }
                try {
                  onPlayClick?.call();
                } on Object catch (e, st) {
                  developer.log(
                    'GameAudioService.playType failed',
                    error: e,
                    stackTrace: st,
                  );
                }
                onKey(label);
              }
            : null,
        borderRadius: borderRadius,
        keyColor: keyColor,
        disabledKeyColor: disabledKeyColor,
      ),
    );
  }
}
