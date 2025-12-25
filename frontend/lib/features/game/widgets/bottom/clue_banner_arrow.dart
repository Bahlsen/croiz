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
      width: 40,
      height: null, // Constrain height dynamically
      child: Icon(icon, color: Colors.white70, size: 26),
    ),
  );
}
