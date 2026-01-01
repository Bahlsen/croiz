import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/bottom/clue_banner_container.dart';

class ClueBannerArrow extends StatelessWidget {
  const ClueBannerArrow({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final VoidCallback onTap;

  /// Fixed width for the arrow button.
  ///
  /// This is a constant to ensure the Row in CrosswordClueHeader
  /// can calculate space correctly without overflow issues.
  static const double fixedWidth = 64;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: fixedWidth,
      height: ClueBannerContainer.fixedHeight,
      child: Center(
        child: Icon(
          icon,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha((0.9 * 255).round()),
          size: 44,
        ),
      ),
    ),
  );
}
