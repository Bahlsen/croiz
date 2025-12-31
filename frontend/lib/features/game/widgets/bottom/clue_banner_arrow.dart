import 'package:flutter/material.dart';
import 'package:croiz/core/responsive/responsive.dart';

class ClueBannerArrow extends StatelessWidget {
  const ClueBannerArrow({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: 22.w,
      height: 12.h,
      child: Center(
        child: Icon(
          icon,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha((0.9 * 255).round()),
          size: 20.w,
        ),
      ),
    ),
  );
}
