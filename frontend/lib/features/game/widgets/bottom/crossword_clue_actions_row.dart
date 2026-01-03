import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_actions.dart';
import 'package:croiz/core/responsive/responsive.dart';

class CrosswordClueActionsRow extends StatelessWidget {
  const CrosswordClueActionsRow({
    this.onMenu,
    this.onReveal,
    this.onClear,
    this.title,
    super.key,
  });

  final VoidCallback? onMenu;
  final VoidCallback? onReveal;
  final VoidCallback? onClear;
  final String? title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (onMenu != null)
        SizedBox(
          width: 12.w,
          height: 5.h,
          child: Center(child: ClueHeaderMenuButton(onPressed: onMenu)),
        )
      else
        SizedBox(width: 12.w),
      if (title != null)
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsivePadding.xs),
            child: Text(
              title!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveFontSize.bodyMedium,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        )
      else
        const Spacer(),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onReveal != null)
            SizedBox(
              width: 10.w,
              height: 4.5.h,
              child: Center(child: ClueHeaderRevealButton(onPressed: onReveal)),
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
  );
}
