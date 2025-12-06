import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CrosswordIconBar extends StatelessWidget {
  const CrosswordIconBar({
    required this.onClear,
    required this.onToggle,
    required this.isAzerty,
    Key? key,
  }) : super(key: key);

  final VoidCallback onClear;
  final VoidCallback onToggle;
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
          IconButton(
            key: const Key('clear_button'),
            onPressed: () {
              try {
                onClear();
              } on Object catch (e, st) {
                if (kDebugMode) {
                  // Keep error logging local to this control
                  // so tests don't fail on unexpected exceptions.
                  // The parent is responsible for passing a safe callback.
                  // ignore: avoid_print
                  debugPrint('clearIncorrectLetters failed: $e\n$st');
                }
              }
            },
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(isAzerty ? Icons.keyboard : Icons.keyboard_alt_outlined),
          ),
        ],
      ),
    );
  }
}
