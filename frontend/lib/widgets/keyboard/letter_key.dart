import 'package:flutter/material.dart';

/// A single letter key for the virtual keyboard.
class LetterKey extends StatelessWidget {
  const LetterKey({
    required this.label,
    required this.height,
    required this.enabled,
    required this.onPressed,
    required this.fontSize,
    required this.borderRadius,
    required this.keyColor,
    required this.disabledKeyColor,
    super.key,
  });

  final String label;
  final double height;
  final bool enabled;
  final VoidCallback? onPressed;
  final double fontSize;
  final BorderRadius borderRadius;
  final Color? keyColor;
  final Color? disabledKeyColor;

  // Performance: cache style lookup
  static const _letterTextStyle = TextStyle(
    letterSpacing: 1.2,
    fontWeight: FontWeight.w500,
  );
  static const _zeroPadding = EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Performance: avoid recreating ButtonStyle on every build.
    // Use resolve methods for theme-dependent colors. Use `surface` as
    // default background so keys are solid white in the light theme.
    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledKeyColor ??
              scheme.onSurface.withAlpha((0.12 * 255).round());
        }
        return keyColor ?? scheme.surface;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withAlpha((0.6 * 255).round());
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
        child: Text(label, style: _letterTextStyle.copyWith(fontSize: fontSize)),
      ),
    );
  }
}
