import 'package:flutter/material.dart';

class ClueBannerArrow extends StatelessWidget {
  const ClueBannerArrow({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: 88,
      height: 100,
      child: Center(
        child: Icon(
          icon,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha((0.9 * 255).round()),
          size: 90,
        ),
      ),
    ),
  );
}
