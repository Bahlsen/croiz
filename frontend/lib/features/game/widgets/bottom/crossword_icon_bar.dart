import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CrosswordIconBar extends StatelessWidget {
  const CrosswordIconBar({
    required this.onClear,
    required this.onMenu,
    Key? key,
  }) : super(key: key);

  final VoidCallback onClear;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    const controlHeight = 35.0;
    return SizedBox(
      height: controlHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Menu icon (far left)
          Semantics(
            label: 'Menu',
            button: true,
            child: IconButton(
              key: const Key('menu_button'),
              tooltip: 'Menu',
              onPressed: onMenu,
              icon: const Icon(Icons.menu),
            ),
          ),
          const Spacer(),
          Semantics(
            label: 'Clear incorrect letters',
            button: true,
            child: IconButton(
              key: const Key('clear_button'),
              tooltip: 'Clear errors',
              onPressed: () {
                try {
                  onClear();
                } on Object catch (e, st) {
                  if (kDebugMode) {
                    debugPrint('clearIncorrectLetters failed: $e\n$st');
                  }
                }
              },
              icon: const Icon(Icons.cleaning_services_outlined),
            ),
          ),
          // Keyboard style is now controlled from the menu.
        ],
      ),
    );
  }
}
