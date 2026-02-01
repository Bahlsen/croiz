import 'package:flutter/material.dart';

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    required this.count,
    required this.currentPage,
    super.key,
  });

  final int count;
  final int currentPage;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(count, (index) {
      final isActive = index == currentPage;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 8,
        width: isActive ? 24 : 8,
        decoration: BoxDecoration(
          color:
              isActive
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }),
  );
}
