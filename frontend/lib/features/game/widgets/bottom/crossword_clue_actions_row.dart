import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_actions.dart';
import 'package:croiz/core/responsive/responsive.dart';

class CrosswordClueActionsRow extends StatelessWidget {
  const CrosswordClueActionsRow({
    this.onMenu,
    this.onReveal,
    this.onClear,
    super.key,
  });

  final VoidCallback? onMenu;
  final VoidCallback? onReveal;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: ResponsiveSpacing.xs),
    child: Row(
      children: [
        if (onMenu != null)
          SizedBox(
            width: 12.w,
            height: 5.h,
            child: Center(child: ClueHeaderMenuButton(onPressed: onMenu)),
          )
        else
          SizedBox(width: 12.w),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onReveal != null)
              SizedBox(
                width: 10.w,
                height: 4.5.h,
                child: Center(
                  child: ClueHeaderRevealButton(onPressed: onReveal),
                ),
              ),
            if (onReveal != null && onClear != null)
              SizedBox(width: ResponsivePadding.sm),
            if (onClear != null)
              SizedBox(
                width: 10.w,
                height: 4.5.h,
                child: Center(child: ClueHeaderClearButton(onPressed: onClear)),
              ),
          ],
        ),
      ],
    ),
  );
}
