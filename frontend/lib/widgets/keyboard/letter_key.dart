import 'package:flutter/material.dart';

/// A single letter key for the virtual keyboard.
class LetterKey extends StatelessWidget {
  const LetterKey({
    required this.label,
    required this.height,
    required this.enabled,
    required this.onPressed,
    required this.borderRadius,
    required this.keyColor,
    required this.disabledKeyColor,
    super.key,
  });

  final String label;
  final double height;
  final bool enabled;
  final VoidCallback? onPressed;
  final BorderRadius borderRadius;
  final Color? keyColor;
  final Color? disabledKeyColor;

  // Performance: cache style lookup
  static const _letterTextStyle = TextStyle(
    letterSpacing: 1.2,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );
  static const _zeroPadding = EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Performance: avoid recreating ButtonStyle on every build.
    // Use resolve methods for theme-dependent colors.
    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledKeyColor ?? scheme.onSurface.withAlpha(20);
        }
        return keyColor ?? scheme.surfaceContainerHighest.withAlpha(82);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withAlpha(97);
        }
        return scheme.onSurface;
      }),
      padding: const WidgetStatePropertyAll(_zeroPadding),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: borderRadius),
      ),
    );

    return SizedBox(
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: style,
        child: Text(label, style: _letterTextStyle),
      ),
    );
  }
}
