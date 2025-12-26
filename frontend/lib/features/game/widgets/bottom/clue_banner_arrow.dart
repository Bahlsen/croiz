import 'package:flutter/material.dart';

class ClueBannerArrow extends StatelessWidget {
  const ClueBannerArrow({required this.icon, required this.onTap, Key? key})
    : super(key: key);

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
          size: 36,
        ),
      ),
    ),
  );
}
