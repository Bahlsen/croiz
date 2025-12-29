import 'package:flutter/material.dart';
import 'package:croiz/l10n/app_localizations.dart';

/// Small reusable action buttons used by the clue header.
class ClueHeaderMenuButton extends StatelessWidget {
  const ClueHeaderMenuButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context)?.menu ?? 'Menu',
    button: true,
    child: IconButton(
      key: const Key('menu_button'),
      tooltip: AppLocalizations.of(context)?.menu ?? 'Menu',
      onPressed: onPressed,
      icon: Icon(
        Icons.menu,
        size: 32,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      visualDensity: VisualDensity.standard,
      padding: EdgeInsets.zero,
    ),
  );
}

class ClueHeaderClearButton extends StatelessWidget {
  const ClueHeaderClearButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        AppLocalizations.of(context)?.clearIncorrectLetters ??
        'Clear incorrect letters',
    button: true,
    child: IconButton(
      key: const Key('clear_button'),
      tooltip:
          AppLocalizations.of(context)?.clearIncorrectLetters ??
          'Clear incorrect letters',
      onPressed: onPressed,
      icon: Icon(
        Icons.cleaning_services_outlined,
        size: 32,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      visualDensity: VisualDensity.standard,
      padding: EdgeInsets.zero,
    ),
  );
}

class ClueHeaderRevealButton extends StatelessWidget {
  const ClueHeaderRevealButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context)?.reveal ?? 'Reveal',
    button: true,
    child: IconButton(
      key: const Key('reveal_button'),
      tooltip: AppLocalizations.of(context)?.reveal ?? 'Reveal',
      onPressed: onPressed,
      icon: Icon(
        Icons.visibility_outlined,
        size: 26,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      visualDensity: VisualDensity.standard,
      padding: EdgeInsets.zero,
    ),
  );
}
