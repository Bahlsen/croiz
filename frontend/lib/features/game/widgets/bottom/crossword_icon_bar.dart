import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CrosswordIconBar extends StatelessWidget {
  const CrosswordIconBar({
    required this.onClear,
    required this.onToggle,
    required this.isAzerty,
    required this.onMenu,
    Key? key,
  }) : super(key: key);

  final VoidCallback onClear;
  final VoidCallback onToggle;
  final VoidCallback onMenu;
  final bool isAzerty;

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
          Semantics(
            label: isAzerty
                ? 'Switch to QWERTY keyboard'
                : 'Switch to AZERTY keyboard',
            button: true,
            child: IconButton(
              tooltip: isAzerty ? 'QWERTY' : 'AZERTY',
              onPressed: onToggle,
              icon: Icon(
                isAzerty ? Icons.keyboard : Icons.keyboard_alt_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
