import 'package:flutter/material.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/core/responsive/responsive.dart';

/// Small reusable action buttons used by the clue header.
class ClueHeaderMenuButton extends StatelessWidget {
  const ClueHeaderMenuButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: AppLocalizations.of(context)?.menu ?? 'Menu',
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withAlpha(isDark ? 80 : 150),
          borderRadius: BorderRadius.circular(ResponsiveBorderRadius.md),
        ),
        child: IconButton(
          key: const Key('menu_button'),
          tooltip: AppLocalizations.of(context)?.menu ?? 'Menu',
          onPressed: onPressed,
          icon: Icon(
            Icons.menu,
            size: ResponsiveIconSize.md,
            color: colorScheme.onSurface,
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class ClueHeaderClearButton extends StatelessWidget {
  const ClueHeaderClearButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label:
          AppLocalizations.of(context)?.clearIncorrectLetters ??
          'Clear incorrect letters',
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withAlpha(isDark ? 60 : 120),
          borderRadius: BorderRadius.circular(ResponsiveBorderRadius.md),
        ),
        child: IconButton(
          key: const Key('clear_button'),
          tooltip:
              AppLocalizations.of(context)?.clearIncorrectLetters ??
              'Clear incorrect letters',
          onPressed: onPressed,
          icon: Icon(
            Icons.cleaning_services_rounded,
            size: ResponsiveIconSize.md,
            color: colorScheme.onErrorContainer,
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class ClueHeaderRevealButton extends StatelessWidget {
  const ClueHeaderRevealButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: AppLocalizations.of(context)?.reveal ?? 'Reveal',
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withAlpha(isDark ? 60 : 120),
          borderRadius: BorderRadius.circular(ResponsiveBorderRadius.md),
        ),
        child: IconButton(
          key: const Key('reveal_button'),
          tooltip: AppLocalizations.of(context)?.reveal ?? 'Reveal',
          onPressed: onPressed,
          icon: Icon(
            Icons.lightbulb_rounded,
            size: ResponsiveIconSize.md,
            color: colorScheme.onSecondaryContainer,
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
