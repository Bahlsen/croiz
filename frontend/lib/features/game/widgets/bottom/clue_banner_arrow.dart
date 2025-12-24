import 'package:flutter/material.dart';

class ClueBannerArrow extends StatelessWidget {
  const ClueBannerArrow({
    required this.icon, required this.onTap, Key? key,
    this.compact = false,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: compact ? 34 : 40,
      height: double.infinity,
      child: Icon(icon, color: Colors.white70, size: compact ? 22 : 26),
    ),
  );
}
