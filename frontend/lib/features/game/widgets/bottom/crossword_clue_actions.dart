import 'package:flutter/material.dart';

/// Small reusable action buttons used by the clue header.
class ClueHeaderMenuButton extends StatelessWidget {
  const ClueHeaderMenuButton({required this.onPressed, Key? key})
    : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Menu',
    button: true,
    child: IconButton(
      key: const Key('menu_button'),
      tooltip: 'Menu',
      onPressed: onPressed,
      icon: const Icon(Icons.menu, size: 24),
      visualDensity: VisualDensity.standard,
      padding: EdgeInsets.zero,
    ),
  );
}

class ClueHeaderClearButton extends StatelessWidget {
  const ClueHeaderClearButton({required this.onPressed, Key? key})
    : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Clear incorrect letters',
    button: true,
    child: IconButton(
      key: const Key('clear_button'),
      tooltip: 'Clear errors',
      onPressed: onPressed,
      icon: const Icon(Icons.cleaning_services_outlined, size: 24),
      visualDensity: VisualDensity.standard,
      padding: EdgeInsets.zero,
    ),
  );
}
