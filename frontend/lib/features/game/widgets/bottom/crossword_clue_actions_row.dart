import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_actions.dart';

class CrosswordClueActionsRow extends StatelessWidget {
  const CrosswordClueActionsRow({
    this.onMenu,
    this.onReveal,
    this.onClear,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onMenu;
  final VoidCallback? onReveal;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        if (onMenu != null)
          SizedBox(
            width: 48,
            height: 40,
            child: Center(child: ClueHeaderMenuButton(onPressed: onMenu)),
          )
        else
          const SizedBox(width: 48),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onReveal != null)
              SizedBox(
                width: 40,
                height: 36,
                child: Center(
                  child: ClueHeaderRevealButton(onPressed: onReveal),
                ),
              ),
            if (onReveal != null && onClear != null) const SizedBox(width: 6),
            if (onClear != null)
              SizedBox(
                width: 40,
                height: 36,
                child: Center(child: ClueHeaderClearButton(onPressed: onClear)),
              ),
          ],
        ),
      ],
    ),
  );
}
